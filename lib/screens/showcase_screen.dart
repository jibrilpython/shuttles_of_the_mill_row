import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';
import 'package:shuttles_of_the_mill_row/providers/image_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

const Color _kPersimmonWood = Color(0xFFC88E46);
const Color _kLoomIron = Color(0xFF1B1A19);
const Color _kIndigoWarp = Color(0xFF1E2E3D);
const Color _kRawCotton = Color(0xFFF6F4EE);
const Color _kOilShadow = Color(0xFF070605);
const Color _kIronTip = Color(0xFF6B6B66);

enum _RaceSide { left, right, free, locked }

class _RaceShuttle {
  final int entryIndex;
  final WeavingShuttleModel model;
  double x;
  double y;
  double vx;
  double vy;
  double angle;
  double angularVelocity;
  double mass;
  double heat;
  double threadTrail;
  double pirnSpin;
  double pirnRadius;
  double boxImpact;
  _RaceSide side;

  _RaceShuttle({
    required this.entryIndex,
    required this.model,
    required this.x,
    required this.y,
    required this.mass,
    this.vx = 0,
    this.vy = 0,
    this.angle = 0,
    this.angularVelocity = 0,
    this.heat = 0,
    this.threadTrail = 0,
    this.pirnSpin = 0,
    this.pirnRadius = 0,
    this.boxImpact = 0,
    this.side = _RaceSide.left,
  });

  bool get resting => side == _RaceSide.left || side == _RaceSide.right;
  bool get locked => side == _RaceSide.locked;
  bool get moving => side == _RaceSide.free && vx.abs() + vy.abs() > 40;
}

class _LintMote {
  double x;
  double y;
  double phase;
  double size;

  _LintMote({
    required this.x,
    required this.y,
    required this.phase,
    required this.size,
  });
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  StreamSubscription<AccelerometerEvent>? _accelerometer;

  final _rng = math.Random(42);
  final List<_RaceShuttle> _shuttles = [];
  final List<_LintMote> _motes = [];
  final List<Offset> _strikeSamples = [];

  Size _canvasSize = Size.zero;
  Duration _lastElapsed = Duration.zero;
  int _syncedVersion = -1;
  int _syncedCount = -1;
  int? _dragging;
  int? _lockedIndex;
  int? _selectedIndex;
  int? _highlightIndex;
  bool _scaleMoved = false;
  double _totalDragDistance = 0;
  Offset? _scaleStartPosition;
  Offset? _lastDragPosition;
  DateTime? _lastDragTime;
  double _raceY = 0;
  double _shedPulse = 0;
  double _warpCollapse = 0;
  double _reedFlash = 0;
  double _tilt = 0;
  double _frictionHapticGate = 0;

  static const double _boxWidth = 62;
  static const double _shuttleHalfWidth = 34;
  static const double _maxVelocity = 2500;
  static const double _centerLockRadius = 74;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    try {
      _accelerometer = accelerometerEventStream().listen((event) {
        _tilt = (-event.x / 9.8).clamp(-1.0, 1.0);
      }, onError: (_) {});
    } catch (_) {
      _accelerometer = null;
    }
  }

  @override
  void dispose() {
    _accelerometer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final entries = project.entries;

    return Scaffold(
      backgroundColor: _kOilShadow,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          _raceY = _canvasSize.height * 0.47;

          if (project.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kAccent),
            );
          }

          if (entries.isEmpty) {
            return _emptyState();
          }

          _syncShuttles(entries);
          _ensureMotes();

          return RepaintBoundary(
            child: Stack(
              key: ValueKey('raceboard$_lockedIndex$_selectedIndex'),
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: _onTapUp,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    child: CustomPaint(
                      painter: _RaceboardPainter(
                        shuttles: List<_RaceShuttle>.from(_shuttles),
                        motes: List<_LintMote>.from(_motes),
                        raceY: _raceY,
                        time: _lastElapsed.inMilliseconds / 1000,
                        shedPulse: _shedPulse,
                        warpCollapse: _warpCollapse,
                        reedFlash: _reedFlash,
                        highlightedIndex: _highlightIndex ?? _selectedIndex,
                        lockedIndex: _lockedIndex,
                        topInset: MediaQuery.of(context).padding.top,
                      ),
                    ),
                  ),
                ),
                _header(),
                if (_panelIndex != null && _panelIndex! < _shuttles.length)
                  _focusPanel(_shuttles[_panelIndex!])
                else
                  _instructions(),
              ],
            ),
          );
        },
      ),
    );
  }

  int? get _panelIndex {
    final index = _lockedIndex ?? _selectedIndex;
    if (index == null || index < 0 || index >= _shuttles.length) return null;
    return index;
  }

  Widget _emptyState() {
    return Stack(
      children: [
        _header(),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  color: _kRawCotton.withValues(alpha: 0.28),
                  size: 58.sp,
                ),
                SizedBox(height: 18.h),
                Text(
                  'NO SHUTTLES IN THE RACEBOARD.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Log a specimen first, then hurl it through the warp shed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MILL MAP / RACEBOARD',
                  style: GoogleFonts.ibmPlexMono(
                    color: _kPersimmonWood,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'The Raceboard Chase',
                  style: GoogleFonts.archivo(
                    color: _kRawCotton,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _resetRaceboard,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _kLoomIron.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: _kIndigoWarp),
              ),
              child: Text(
                'RESET',
                style: GoogleFonts.ibmPlexMono(
                  color: _kRawCotton.withValues(alpha: 0.72),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructions() {
    if (_panelIndex != null) return const SizedBox.shrink();
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: bottomNavOverlayHeight(context) + 18.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: _kLoomIron.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: _kIndigoWarp.withValues(alpha: 0.7)),
        ),
        child: Text(
          'Swipe from either shuttle box to strike. Tap a resting shuttle to eject its pirn. Drag to center and pinch to drop the pick.',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText.withValues(alpha: 0.9),
            fontSize: 9.sp,
            height: 1.45,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  String? _cachedFocusPath;
  int? _cachedFocusId;

  Widget _focusPanel(_RaceShuttle shuttle) {
    final item = shuttle.model;
    final id = item.id.hashCode;
    if (id != _cachedFocusId) {
      _cachedFocusId = id;
      _cachedFocusPath =
          ref.read(imageProvider).getImagePath(item.photoPath);
    }
    final resolved = _cachedFocusPath;

    Widget imageOrFallback;
    if (resolved != null) {
      imageOrFallback = Image.file(
        File(resolved),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            CustomPaint(painter: _MacroShuttlePainter(item)),
      );
    } else {
      imageOrFallback = CustomPaint(painter: _MacroShuttlePainter(item));
    }

    return Positioned(
      left: 14.w,
      right: 14.w,
      bottom: bottomNavOverlayHeight(context) + 10.h,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _kPersimmonWood.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _kRawCotton.withValues(alpha: 0.18)),
          boxShadow: const [kShadowFloat],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SHED LOCK INSPECTION',
                    style: GoogleFonts.ibmPlexMono(
                      color: _kLoomIron.withValues(alpha: 0.74),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _unlockInspection,
                  child: Icon(
                    Icons.close_rounded,
                    color: _kLoomIron.withValues(alpha: 0.65),
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 86.w,
                    height: 86.w,
                    color: _kLoomIron,
                    child: imageOrFallback,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.artisanHallmark.isEmpty
                            ? item.loomApplicationClass.label.toUpperCase()
                            : item.artisanHallmark.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.archivo(
                          color: _kLoomIron,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.shuttleRegistryMark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexMono(
                          color: _kLoomIron.withValues(alpha: 0.76),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _focusPill(item.loomApplicationClass.label),
                          _focusPill('${_weightFor(item).toStringAsFixed(1)} oz'),
                          _focusPill(item.era.isEmpty ? 'ERA UNKNOWN' : item.era),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _inspectionRow('Manufacturer', item.artisanHallmark),
            _inspectionRow('Instrument type', item.loomApplicationClass.label),
            _inspectionRow('Calibrated site', item.calibratedSite),
            _inspectionRow('Foundry / mill', item.weavingGroundZero),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/info_screen',
                      arguments: {'index': item.entryIndexIn(ref)},
                    ),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: _kLoomIron,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: Center(
                        child: Text(
                          'OPEN ARCHIVE CARD',
                          style: GoogleFonts.ibmPlexMono(
                            color: _kRawCotton,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _focusPill(String label) {
    final text = label.trim().isEmpty ? 'UNMARKED' : label.trim();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _kLoomIron.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: _kLoomIron.withValues(alpha: 0.75),
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _inspectionRow(String label, String value) {
    final display = value.trim().isEmpty ? 'Unrecorded' : value.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 106.w,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: _kLoomIron.withValues(alpha: 0.55),
                fontSize: 8.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: GoogleFonts.ibmPlexSans(
                color: _kLoomIron,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _syncShuttles(List<WeavingShuttleModel> entries) {
    final version = ref.read(projectProvider).stateVersion;
    if (version == _syncedVersion &&
        entries.length == _syncedCount &&
        _shuttles.length == entries.length) {
      return;
    }
    _syncedVersion = version;
    _syncedCount = entries.length;

    final previous = {for (final s in _shuttles) s.model.id: s};
    _shuttles.clear();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final old = previous[entry.id];
      if (old != null) {
        _shuttles.add(
          _RaceShuttle(
            entryIndex: i,
            model: entry,
            x: old.x.clamp(_boxWidth, _canvasSize.width - _boxWidth),
            y: old.y,
            vx: old.vx,
            vy: old.vy,
            angle: old.angle,
            angularVelocity: old.angularVelocity,
            mass: _massFor(entry),
            heat: old.heat,
            threadTrail: old.threadTrail,
            pirnSpin: old.pirnSpin,
            pirnRadius: old.pirnRadius,
            boxImpact: old.boxImpact,
            side: old.side,
          ),
        );
        continue;
      }

      final leftSide = i.isEven;
      final lane = (i ~/ 2) % 6;
      final laneOffset = (lane - 2.5) * 24.0;
      _shuttles.add(
        _RaceShuttle(
          entryIndex: i,
          model: entry,
          x: leftSide ? _boxWidth * 0.75 : _canvasSize.width - _boxWidth * 0.75,
          y: _raceY + laneOffset,
          mass: _massFor(entry),
          side: leftSide ? _RaceSide.left : _RaceSide.right,
          angle: leftSide ? 0 : math.pi,
        ),
      );
    }
  }

  void _ensureMotes() {
    if (_motes.isNotEmpty) return;
    for (var i = 0; i < 64; i++) {
      _motes.add(
        _LintMote(
          x: _rng.nextDouble() * _canvasSize.width,
          y: _rng.nextDouble() * _canvasSize.height,
          phase: _rng.nextDouble() * math.pi * 2,
          size: 0.4 + _rng.nextDouble() * 1.9,
        ),
      );
    }
  }

  void _tick(Duration elapsed) {
    if (!mounted) return;
    try {
      _doTick(elapsed);
    } catch (_) {
      setState(() {});
    }
  }

  void _doTick(Duration elapsed) {
    final dt = _deltaSeconds(elapsed);
    if (_canvasSize == Size.zero) {
      setState(() {});
      return;
    }

    _shedPulse += dt * 18;
    _reedFlash = math.max(0, _reedFlash - dt * 3.2);
    _frictionHapticGate = math.max(0, _frictionHapticGate - dt);

    final hasLock = _lockedIndex != null;
    _warpCollapse += ((hasLock ? 1.0 : 0.0) - _warpCollapse) * dt * 9;

    for (final mote in _motes) {
      mote.phase += dt * 0.7;
      mote.x += (math.sin(mote.phase) * 7 + _tilt * 10) * dt;
      mote.y -= (2 + math.cos(mote.phase) * 1.2) * dt;
      if (mote.x < -8) mote.x = _canvasSize.width + 8;
      if (mote.x > _canvasSize.width + 8) mote.x = -8;
      if (mote.y < -8) mote.y = _canvasSize.height + 8;
    }

    for (var i = 0; i < _shuttles.length; i++) {
      if (_dragging == i) continue;
      final shuttle = _shuttles[i];
      shuttle.heat = math.max(0, shuttle.heat - dt * 1.1);
      shuttle.threadTrail = math.max(0, shuttle.threadTrail - dt * 1.8);
      shuttle.boxImpact = math.max(0, shuttle.boxImpact - dt * 3.2);
      if (shuttle.pirnRadius > 0) {
        shuttle.pirnRadius = math.max(0, shuttle.pirnRadius - dt * 10);
        shuttle.pirnSpin += dt * 11;
      }

      if (shuttle.locked) {
        final center = _lockCenter;
        shuttle.x += (center.dx - shuttle.x) * dt * 9;
        shuttle.y += (center.dy - shuttle.y) * dt * 9;
        shuttle.vx = 0;
        shuttle.vy = 0;
        shuttle.angle += (0 - shuttle.angle) * dt * 8;
        continue;
      }

      if (shuttle.resting) {
        final targetX = shuttle.side == _RaceSide.left
            ? _boxWidth * 0.75
            : _canvasSize.width - _boxWidth * 0.75;
        final laneOffset = ((shuttle.entryIndex ~/ 2) % 6 - 2.5) * 24.0;
        shuttle.x += (targetX - shuttle.x) * dt * 7;
        shuttle.y += (_raceY + laneOffset - shuttle.y) * dt * 7;
        shuttle.angle += ((shuttle.side == _RaceSide.left ? 0 : math.pi) -
                shuttle.angle) *
            dt *
            8;
        continue;
      }

      _applyFlightPhysics(shuttle, dt);
    }

    setState(() {});
  }

  double _deltaSeconds(Duration elapsed) {
    final delta = _lastElapsed == Duration.zero
        ? 1 / 60
        : (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;
    return delta.clamp(0.008, 0.033);
  }

  void _applyFlightPhysics(_RaceShuttle shuttle, double dt) {
    _sanitizeShuttle(shuttle);
    final speed = math.sqrt(shuttle.vx * shuttle.vx + shuttle.vy * shuttle.vy);
    final massDrag = 0.985 - (shuttle.mass - 1) * 0.008;
    final friction = math.pow(massDrag.clamp(0.94, 0.988), dt * 60).toDouble();
    final raceSpring = (_raceY - shuttle.y) * (8 / shuttle.mass);
    final tiltForce = _tilt * 90;

    shuttle.vx += tiltForce * dt;
    shuttle.vy += raceSpring * dt;
    shuttle.vx *= friction;
    shuttle.vy *= math.pow(0.965, dt * 60).toDouble();

    if (speed > _maxVelocity) {
      final scale = _maxVelocity / speed;
      shuttle.vx *= scale;
      shuttle.vy *= scale;
    }

    shuttle.x += shuttle.vx * dt;
    shuttle.y += shuttle.vy * dt;
    shuttle.angularVelocity +=
        (math.atan2(shuttle.vy * 0.22, shuttle.vx) - shuttle.angle) * dt * 10;
    shuttle.angularVelocity *= math.pow(0.82, dt * 60).toDouble();
    shuttle.angle += shuttle.angularVelocity * dt;
    shuttle.heat = (speed / 1700).clamp(0, 1);
    shuttle.threadTrail = math.max(shuttle.threadTrail, (speed / 1800).clamp(0, 1));

    if (speed > 700 && _frictionHapticGate == 0) {
      _frictionHapticGate = 0.11;
      HapticFeedback.selectionClick();
    }

    final leftStop = _boxWidth + _shuttleHalfWidth * 0.25;
    final rightStop = _canvasSize.width - _boxWidth - _shuttleHalfWidth * 0.25;
    if (shuttle.x <= leftStop && shuttle.vx < 0) {
      _catchInBox(shuttle, _RaceSide.left);
    } else if (shuttle.x >= rightStop && shuttle.vx > 0) {
      _catchInBox(shuttle, _RaceSide.right);
    }

    final top = MediaQuery.of(context).padding.top + 88.h;
    final bottom = _canvasSize.height - 150.h;
    if (shuttle.y < top) {
      shuttle.y = top;
      shuttle.vy = shuttle.vy.abs() * 0.26;
    } else if (shuttle.y > bottom) {
      shuttle.y = bottom;
      shuttle.vy = -shuttle.vy.abs() * 0.26;
    }
    _sanitizeShuttle(shuttle);
  }

  void _sanitizeShuttle(_RaceShuttle shuttle) {
    if (!shuttle.x.isFinite) {
      shuttle.x = shuttle.side == _RaceSide.right
          ? _canvasSize.width - _boxWidth * 0.75
          : _boxWidth * 0.75;
    }
    if (!shuttle.y.isFinite) shuttle.y = _raceY;
    if (!shuttle.vx.isFinite) shuttle.vx = 0;
    if (!shuttle.vy.isFinite) shuttle.vy = 0;
    if (!shuttle.angle.isFinite) shuttle.angle = 0;
    if (!shuttle.angularVelocity.isFinite) shuttle.angularVelocity = 0;
    if (!shuttle.heat.isFinite) shuttle.heat = 0;
    if (!shuttle.threadTrail.isFinite) shuttle.threadTrail = 0;
    if (!shuttle.pirnRadius.isFinite) shuttle.pirnRadius = 0;
    if (!shuttle.pirnSpin.isFinite) shuttle.pirnSpin = 0;
    if (_canvasSize != Size.zero) {
      shuttle.x = shuttle.x.clamp(0, _canvasSize.width).toDouble();
      shuttle.y = shuttle.y.clamp(0, _canvasSize.height).toDouble();
    }
  }

  void _catchInBox(_RaceShuttle shuttle, _RaceSide side) {
    shuttle.side = side;
    shuttle.vx = 0;
    shuttle.vy = 0;
    shuttle.boxImpact = 1;
    shuttle.threadTrail = 1;
    _reedFlash = 0.65;
    HapticFeedback.heavyImpact();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_panelIndex != null) return;
    try {
      _doScaleStart(details);
    } catch (_) {}
  }

  void _doScaleStart(ScaleStartDetails details) {
    _scaleMoved = false;
    _totalDragDistance = 0;
    _scaleStartPosition = details.localFocalPoint;
    _strikeSamples
      ..clear()
      ..add(details.localFocalPoint);
    _lastDragPosition = details.localFocalPoint;
    _lastDragTime = DateTime.now();
    _dragging = _hitTest(details.localFocalPoint);
    if (_dragging != null) {
      _highlightIndex = _dragging;
      HapticFeedback.selectionClick();
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_panelIndex != null) return;
    try {
      _doScaleUpdate(details);
    } catch (_) {}
  }

  void _doScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      _tryLockPick(details.localFocalPoint);
      return;
    }

    _strikeSamples.add(details.localFocalPoint);
    if (_strikeSamples.length > 8) _strikeSamples.removeAt(0);

    final moved = _scaleStartPosition == null
        ? 0.0
        : _distance(details.localFocalPoint, _scaleStartPosition!);
    if (moved > 10) _scaleMoved = true;

    if (_lastDragPosition != null) {
      _totalDragDistance +=
          _distance(details.localFocalPoint, _lastDragPosition!);
    }

    final i = _dragging;
    if (i == null || !_scaleMoved) return;

    final now = DateTime.now();
    final shuttle = _shuttles[i];
    if (shuttle.resting) {
      shuttle.side = _RaceSide.free;
      shuttle.vx = 0;
      shuttle.vy = 0;
      _selectedIndex = null;
    }
    if (_lastDragPosition != null && _lastDragTime != null) {
      final dt =
          (now.difference(_lastDragTime!).inMicroseconds / 1000000).clamp(0.008, 0.033);
      shuttle.vx =
          ((details.localFocalPoint.dx - _lastDragPosition!.dx) / dt)
              .clamp(-_maxVelocity, _maxVelocity);
      shuttle.vy =
          ((details.localFocalPoint.dy - _lastDragPosition!.dy) / dt)
              .clamp(-900, 900);
    }
    if (_canvasSize != Size.zero) {
      shuttle.x = details.localFocalPoint.dx.clamp(
        _boxWidth * 0.6,
        _canvasSize.width - _boxWidth * 0.6,
      );
      shuttle.y = details.localFocalPoint.dy.clamp(
        MediaQuery.of(context).padding.top + 86.h,
        _canvasSize.height - 150.h,
      );
    }
    _sanitizeShuttle(shuttle);
    _lastDragPosition = details.localFocalPoint;
    _lastDragTime = now;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_panelIndex != null) return;
    try {
      _doScaleEnd(details);
    } catch (_) {
      _resetGestureState();
    }
  }

  void _doScaleEnd(ScaleEndDetails details) {
    final i = _dragging;
    final isTap = i != null && _totalDragDistance < 20;
    if (i != null) {
      final shuttle = _shuttles[i];
      if (isTap) {
        _handleShuttleTap(i);
        _resetGestureState();
        return;
      }
      final launch = details.velocity.pixelsPerSecond;
      final effectiveVelocity = Offset(
        launch.dx + shuttle.vx * 0.3,
        launch.dy * 0.22 + shuttle.vy * 0.2,
      );
      if (effectiveVelocity.dx.abs() > 180) {
        _launchShuttle(shuttle, effectiveVelocity);
      } else if (_distance(Offset(shuttle.x, shuttle.y), _lockCenter) <
          _centerLockRadius) {
        _lockPick(shuttle);
      } else {
        shuttle.side =
            shuttle.x < _canvasSize.width / 2 ? _RaceSide.left : _RaceSide.right;
      }
    } else {
      _resolvePickerStrike();
    }
    _resetGestureState();
  }

  void _resetGestureState() {
    _dragging = null;
    _highlightIndex = _selectedIndex;
    _lastDragPosition = null;
    _lastDragTime = null;
    _scaleStartPosition = null;
    _scaleMoved = false;
    _totalDragDistance = 0;
    _strikeSamples.clear();
  }

  void _onTapUp(TapUpDetails details) {
    if (_panelIndex != null) return;
    try {
      final i = _hitTest(details.localPosition);
      if (i != null) {
        _handleShuttleTap(i);
      }
    } catch (_) {}
  }

  void _resolvePickerStrike() {
    if (_strikeSamples.length < 2) return;
    final start = _strikeSamples.first;
    final end = _strikeSamples.last;
    final delta = end - start;
    if (delta.dx.abs() < 54 || delta.dx.abs() < delta.dy.abs() * 1.35) return;

    final fromLeft = delta.dx > 0;
    final candidates = _shuttles.where((s) {
      return fromLeft ? s.side == _RaceSide.left : s.side == _RaceSide.right;
    }).toList();
    if (candidates.isEmpty) return;
    candidates.sort(
      (a, b) => (a.y - start.dy).abs().compareTo((b.y - start.dy).abs()),
    );
    final shuttle = candidates.first;
    final force = Offset(delta.dx * 28, delta.dy * 2.8);
    _launchShuttle(shuttle, force);
  }

  void _launchShuttle(_RaceShuttle shuttle, Offset force) {
    final safeDx = force.dx.isFinite ? force.dx : 0.0;
    final safeDy = force.dy.isFinite ? force.dy : 0.0;
    final direction = safeDx.sign == 0 ? 1.0 : safeDx.sign;
    final strength = safeDx.abs().clamp(320, 2600).toDouble();
    shuttle.side = _RaceSide.free;
    shuttle.vx = direction * strength / shuttle.mass;
    shuttle.vy = safeDy.clamp(-420, 420).toDouble() / shuttle.mass;
    shuttle.angularVelocity = direction * 4.5 / shuttle.mass;
    shuttle.threadTrail = 1;
    shuttle.heat = 1;
    _sanitizeShuttle(shuttle);
    _selectedIndex = null;
    _reedFlash = 1;
    HapticFeedback.mediumImpact();
  }

  void _tryLockPick(Offset focalPoint) {
    final active = _dragging ?? _nearestTo(_lockCenter);
    if (active == null) return;
    final shuttle = _shuttles[active];
    if (_distance(Offset(shuttle.x, shuttle.y), _lockCenter) < _centerLockRadius ||
        _distance(focalPoint, _lockCenter) < _centerLockRadius * 1.15) {
      _lockPick(shuttle);
      _dragging = null;
    }
  }

  void _lockPick(_RaceShuttle shuttle) {
    try {
      for (final s in _shuttles) {
        if (identical(s, shuttle)) continue;
        if (s.side == _RaceSide.locked) {
          s.side = s.x < _canvasSize.width / 2 ? _RaceSide.left : _RaceSide.right;
        }
      }
      shuttle.side = _RaceSide.locked;
      shuttle.vx = 0;
      shuttle.vy = 0;
      shuttle.threadTrail = 1;
      _lockedIndex = _shuttles.indexOf(shuttle);
      _reedFlash = 1;
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void _unlockInspection() {
    final idx = _lockedIndex;
    if (idx != null && idx < _shuttles.length) {
      final shuttle = _shuttles[idx];
      shuttle.side =
          shuttle.x < _canvasSize.width / 2 ? _RaceSide.left : _RaceSide.right;
      shuttle.pirnRadius = 0;
    }
    setState(() {
      _lockedIndex = null;
      _selectedIndex = null;
      _highlightIndex = null;
      _reedFlash = 0.4;
    });
  }

  void _handleShuttleTap(int index) {
    if (index < 0 || index >= _shuttles.length) return;
    final shuttle = _shuttles[index];
    try {
      _ejectPirn(shuttle);
    } catch (_) {}
    setState(() {
      _selectedIndex = index;
      _highlightIndex = index;
      _reedFlash = 0.25;
    });
  }

  int? _hitTest(Offset point) {
    int? hit;
    var best = double.infinity;
    for (var i = 0; i < _shuttles.length; i++) {
      final shuttle = _shuttles[i];
      final d = _distance(point, Offset(shuttle.x, shuttle.y));
      if (d < 46 && d < best) {
        hit = i;
        best = d;
      }
    }
    return hit;
  }

  void _ejectPirn(_RaceShuttle shuttle) {
    if (shuttle.pirnRadius > 2) return;
    shuttle.pirnRadius = 28;
    shuttle.pirnSpin = 0;
    HapticFeedback.selectionClick();
  }

  int? _nearestTo(Offset target) {
    if (_shuttles.isEmpty) return null;
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _shuttles.length; i++) {
      final d = _distance(Offset(_shuttles[i].x, _shuttles[i].y), target);
      if (d < bestDistance) {
        best = i;
        bestDistance = d;
      }
    }
    return best;
  }

  void _resetRaceboard() {
    HapticFeedback.lightImpact();
    for (final shuttle in _shuttles) {
      shuttle.side =
          shuttle.entryIndex.isEven ? _RaceSide.left : _RaceSide.right;
      shuttle.vx = 0;
      shuttle.vy = 0;
      shuttle.pirnRadius = 0;
      shuttle.threadTrail = 0;
    }
    setState(() {
      _lockedIndex = null;
      _selectedIndex = null;
      _highlightIndex = null;
      _reedFlash = 0.5;
    });
  }

  Offset get _lockCenter => Offset(_canvasSize.width / 2, _raceY);

  double _distance(Offset a, Offset b) => (a - b).distance;

  double _massFor(WeavingShuttleModel item) {
    var mass = 1.0;
    switch (item.fiberType) {
      case FiberType.wool:
        mass += 0.45;
      case FiberType.cotton:
        mass += 0.24;
      case FiberType.linen:
        mass += 0.18;
      case FiberType.mixed:
        mass += 0.14;
      case FiberType.synthetic:
        mass += 0.05;
      case FiberType.silk:
        mass -= 0.12;
    }
    switch (item.tipMetallurgy) {
      case TipMetallurgy.hardenedToolSteel:
      case TipMetallurgy.swagedCastIron:
        mass += 0.2;
      case TipMetallurgy.wroughtIron:
      case TipMetallurgy.nickelSteelCap:
        mass += 0.12;
      case TipMetallurgy.brassFerrule:
        mass += 0.06;
      case TipMetallurgy.notTipped:
        mass -= 0.1;
    }
    return mass.clamp(0.78, 1.82);
  }

  double _weightFor(WeavingShuttleModel item) => 9.4 * _massFor(item) + 3.2;
}

extension on WeavingShuttleModel {
  int entryIndexIn(WidgetRef ref) {
    final entries = ref.read(projectProvider).entries;
    final index = entries.indexWhere((entry) => entry.id == id);
    return math.max(0, index);
  }
}

class _RaceboardPainter extends CustomPainter {
  final List<_RaceShuttle> shuttles;
  final List<_LintMote> motes;
  final double raceY;
  final double time;
  final double shedPulse;
  final double warpCollapse;
  final double reedFlash;
  final int? highlightedIndex;
  final int? lockedIndex;
  final double topInset;

  _RaceboardPainter({
    required this.shuttles,
    required this.motes,
    required this.raceY,
    required this.time,
    required this.shedPulse,
    required this.warpCollapse,
    required this.reedFlash,
    required this.highlightedIndex,
    required this.lockedIndex,
    required this.topInset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      _paintBackground(canvas, size);
      _paintWarp(canvas, size);
      _paintRaceboard(canvas, size);
      _paintBoxes(canvas, size);
      _paintMotes(canvas, size);
      for (var i = 0; i < shuttles.length; i++) {
        _paintTrail(canvas, shuttles[i], i == lockedIndex);
      }
      for (var i = 0; i < shuttles.length; i++) {
        _paintShuttle(
          canvas,
          shuttles[i],
          highlighted: i == highlightedIndex,
          locked: i == lockedIndex,
        );
      }
      if (reedFlash > 0) _paintReedFlash(canvas, size);
    } catch (_) {}
  }

  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          _kOilShadow,
          _kLoomIron,
          kBackground,
          _kOilShadow,
        ],
        const [0, 0.34, 0.72, 1],
      );
    canvas.drawRect(Offset.zero & size, paint);

    final light = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.52, topInset + 46),
        size.width * 0.75,
        [
          _kRawCotton.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Offset.zero & size, light);
  }

  void _paintWarp(Canvas canvas, Size size) {
    if (size.width < 20 || size.height < 20) return;
    final top = topInset + 72;
    final bottom = size.height - 118;
    final center = Offset(size.width / 2, raceY);
    final threadCount = (size.width / 2.2).round().clamp(120, 230);
    final spacing = size.width / threadCount;
    final collapsed = warpCollapse.clamp(0.0, 1.0);

    if (collapsed > 0.04) {
      final fabricRect = Rect.fromCenter(
        center: center,
        width: ui.lerpDouble(size.width * 0.18, size.width * 0.84, collapsed) ??
            size.width * 0.18,
        height: ui.lerpDouble(20, 182, collapsed) ?? 20,
      );
      final fabricPaint = Paint()
        ..shader = ui.Gradient.linear(
          fabricRect.topLeft,
          fabricRect.bottomRight,
          [
            _kIndigoWarp.withValues(alpha: 0.55 * collapsed),
            const Color(0xFF152331).withValues(alpha: 0.95 * collapsed),
          ],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(fabricRect, const Radius.circular(12)),
        fabricPaint,
      );
    }

    for (var i = 0; i <= threadCount; i++) {
      final x = i * spacing;
      final normalized = ((x - center.dx).abs() / (size.width / 2)).clamp(0, 1);
      final shedOpen = (1 - collapsed) * (1 - normalized);
      final phase = shedPulse + i * 0.21;
      final vibration = math.sin(phase) * (0.9 + shedOpen * 4.2);
      final split = math.sin(i * 0.42 + time * 7) * 10 * shedOpen;
      final topControl = Offset(x + vibration, top);
      final bottomControl = Offset(x - vibration * 0.7, bottom);
      final midX = x + split;
      final alpha = collapsed > 0.7
          ? 0.18 + (i.isEven ? 0.1 : 0.02)
          : 0.055 + shedOpen * 0.07;
      final paint = Paint()
        ..color = Color.lerp(_kRawCotton, _kIndigoWarp, 0.45 + collapsed * 0.45)!
            .withValues(alpha: alpha)
        ..strokeWidth = collapsed > 0.5 ? 0.75 : 0.55;

      final path = Path()
        ..moveTo(topControl.dx, topControl.dy)
        ..quadraticBezierTo(midX, raceY, bottomControl.dx, bottomControl.dy);
      canvas.drawPath(path, paint);
    }
  }

  void _paintRaceboard(Canvas canvas, Size size) {
    final board = RRect.fromRectAndRadius(
      Rect.fromLTRB(38, raceY - 25, size.width - 38, raceY + 25),
      const Radius.circular(7),
    );
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, raceY - 25),
        Offset(0, raceY + 25),
        [
          const Color(0xFF2A1E13),
          _kLoomIron,
          const Color(0xFF382719),
        ],
        const [0, 0.52, 1],
      );
    canvas.drawRRect(board, paint);
    canvas.drawRRect(
      board,
      Paint()
        ..color = _kPersimmonWood.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    final scoring = Paint()
      ..color = _kRawCotton.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var x = 72.0; x < size.width - 72; x += 28) {
      canvas.drawLine(Offset(x, raceY - 18), Offset(x, raceY + 18), scoring);
    }
  }

  void _paintBoxes(Canvas canvas, Size size) {
    _paintBox(canvas, Rect.fromLTWH(4, raceY - 78, 72, 156), left: true);
    _paintBox(
      canvas,
      Rect.fromLTWH(size.width - 76, raceY - 78, 72, 156),
      left: false,
    );
  }

  void _paintBox(Canvas canvas, Rect rect, {required bool left}) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [
          _kIndigoWarp.withValues(alpha: 0.65),
          _kLoomIron,
        ],
      );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _kRawCotton.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final label = left ? 'LEFT BOX' : 'RIGHT BOX';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: _kRawCotton.withValues(alpha: 0.34),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy + tp.width / 2);
    canvas.rotate(-math.pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _paintMotes(Canvas canvas, Size size) {
    for (final mote in motes) {
      final paint = Paint()
        ..color = _kRawCotton.withValues(
          alpha: 0.05 + math.sin(mote.phase).abs() * 0.1,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
      canvas.drawCircle(Offset(mote.x, mote.y), mote.size, paint);
    }
  }

  void _paintTrail(Canvas canvas, _RaceShuttle shuttle, bool locked) {
    final trail = math.max(shuttle.threadTrail, locked ? 0.7 : 0).toDouble();
    if (trail <= 0.02) return;
    if (!shuttle.x.isFinite ||
        !shuttle.y.isFinite ||
        !shuttle.vx.isFinite ||
        !trail.isFinite) {
      return;
    }
    final length = ((70 + shuttle.vx.abs() * 0.045) * trail)
        .clamp(12.0, 160.0)
        .toDouble();
    final dir = shuttle.vx.sign == 0 ? 1.0 : -shuttle.vx.sign;
    final start = Offset(shuttle.x, shuttle.y);
    final wobble = math.sin(time * 20).isFinite ? math.sin(time * 20) * 3 : 0.0;
    final end = Offset(shuttle.x + dir * length, shuttle.y + wobble);
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = _kPersimmonWood.withValues(alpha: 0.1 * trail)
        ..strokeWidth = (10 * trail).toDouble()
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = _kRawCotton.withValues(alpha: 0.26 * trail)
        ..strokeWidth = 2.6 + trail * 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start.translate(0, (-3 * trail).toDouble()),
      end.translate((dir * -10 * trail).toDouble(), -1),
      Paint()
        ..color = _kIndigoWarp.withValues(alpha: 0.16 * trail)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintShuttle(
    Canvas canvas,
    _RaceShuttle shuttle, {
    required bool highlighted,
    required bool locked,
  }) {
    if (!shuttle.x.isFinite || !shuttle.y.isFinite) return;
    if (!shuttle.heat.isFinite) return;
    final angle = shuttle.angle.isFinite ? shuttle.angle : 0.0;
    canvas.save();
    canvas.translate(shuttle.x, shuttle.y);
    canvas.rotate(angle);

    final heat = shuttle.heat.clamp(0.0, 1.0);
    final bodyColor = Color.lerp(
      _kPersimmonWood,
      getFiberColor(shuttle.model.fiberType),
      0.22,
    ) ?? _kPersimmonWood;

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(const Rect.fromLTWH(-32, 10, 64, 12), shadow);

    final hull = Path()
      ..moveTo(-34, 0)
      ..cubicTo(-22, -13, -9, -13, 0, -10)
      ..cubicTo(9, -13, 22, -13, 34, 0)
      ..cubicTo(22, 13, 9, 13, 0, 10)
      ..cubicTo(-9, 13, -22, 13, -34, 0)
      ..close();

    canvas.drawPath(
      hull,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -12),
          const Offset(0, 12),
          [
            bodyColor.withValues(alpha: 0.98),
            const Color(0xFF6B4724),
            bodyColor.withValues(alpha: 0.72),
          ],
          const [0, 0.58, 1],
        ),
    );

    for (var i = 0; i < 8; i++) {
      final y = -7 + i * 2.0;
      canvas.drawLine(
        Offset(-24, y),
        Offset(24, y + math.sin(i + time * 2) * 0.7),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.035)
          ..strokeWidth = 0.8,
      );
    }

    canvas.drawPath(
      hull,
      Paint()
        ..color = (highlighted || locked ? _kRawCotton : _kPersimmonWood)
            .withValues(alpha: highlighted || locked ? 0.86 : 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted || locked ? 1.8 : 1.0,
    );

    _paintTip(canvas, -35, true, heat);
    _paintTip(canvas, 35, false, heat);

    canvas.drawOval(
      const Rect.fromLTWH(-10, -4, 20, 8),
      Paint()..color = _kLoomIron.withValues(alpha: 0.48),
    );
    canvas.drawCircle(
      const Offset(-12, 0),
      2.1,
      Paint()..color = _kRawCotton.withValues(alpha: 0.6),
    );

    if (shuttle.pirnRadius > 0) {
      _paintPirn(canvas, shuttle);
    }

    canvas.restore();

    final label = shuttle.model.shuttleRegistryMark;
    final short = label.length > 17 ? '${label.substring(0, 15)}..' : label;
    final tp = TextPainter(
      text: TextSpan(
        text: short,
        style: TextStyle(
          color: _kRawCotton.withValues(alpha: locked ? 0.0 : 0.48),
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    tp.paint(canvas, Offset(shuttle.x - tp.width / 2, shuttle.y + 18));
  }

  void _paintTip(Canvas canvas, double x, bool left, double heat) {
    if (!heat.isFinite) return;
    final tip = Path()
      ..moveTo(x + (left ? -9 : 9), 0)
      ..lineTo(x + (left ? 3 : -3), -5)
      ..lineTo(x + (left ? 3 : -3), 5)
      ..close();
    canvas.drawPath(
      tip,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, -5),
          Offset(x, 5),
          [
            _kIronTip,
            Color.lerp(_kIronTip, _kRawCotton, heat * 0.55) ?? _kIronTip,
            _kLoomIron,
          ],
          const [0, 0.5, 1],
        ),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(x + (left ? 0.8 : -0.8), -2 + i * 2.0),
        0.45,
        Paint()..color = Colors.black.withValues(alpha: 0.35),
      );
    }
  }

  void _paintPirn(Canvas canvas, _RaceShuttle shuttle) {
    canvas.save();
    canvas.translate(0, -shuttle.pirnRadius);
    canvas.rotate(shuttle.pirnSpin);
    final pirn = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-14, -4, 28, 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      pirn,
      Paint()..color = _kRawCotton.withValues(alpha: 0.9),
    );
    for (var i = -10.0; i <= 10; i += 4) {
      canvas.drawLine(
        Offset(i, -4),
        Offset(i + 3, 4),
        Paint()
          ..color = _kIndigoWarp.withValues(alpha: 0.42)
          ..strokeWidth = 0.8,
      );
    }
    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()
        ..color = _kRawCotton.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _paintReedFlash(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kRawCotton.withValues(alpha: 0.12 * reedFlash)
      ..strokeWidth = 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final center = size.width / 2;
    canvas.drawLine(
      Offset(center - 34 * reedFlash, raceY - 126),
      Offset(center - 8, raceY + 126),
      paint,
    );
    canvas.drawLine(
      Offset(center + 34 * reedFlash, raceY - 126),
      Offset(center + 8, raceY + 126),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RaceboardPainter oldDelegate) => true;
}

class _MacroShuttlePainter extends CustomPainter {
  final WeavingShuttleModel item;

  _MacroShuttlePainter(this.item);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hull = Path()
      ..moveTo(size.width * 0.08, center.dy)
      ..quadraticBezierTo(size.width * 0.24, size.height * 0.22,
          size.width * 0.5, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.76, size.height * 0.22,
          size.width * 0.92, center.dy)
      ..quadraticBezierTo(size.width * 0.76, size.height * 0.78,
          size.width * 0.5, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.24, size.height * 0.78,
          size.width * 0.08, center.dy)
      ..close();

    canvas.drawPath(
      hull,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height * 0.25),
          Offset(0, size.height * 0.75),
          [
            getFiberColor(item.fiberType).withValues(alpha: 0.85),
            _kPersimmonWood,
            const Color(0xFF68431F),
          ],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawPath(
      hull,
      Paint()
        ..color = _kRawCotton.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.24,
        height: size.height * 0.16,
      ),
      Paint()..color = _kLoomIron.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _MacroShuttlePainter oldDelegate) =>
      oldDelegate.item.id != item.id;
}