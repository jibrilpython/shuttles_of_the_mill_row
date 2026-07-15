import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _leftIndex = 0;
  int _rightIndex = 1;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final canCompare = entries.length >= 2;

    if (entries.isNotEmpty) {
      _leftIndex = _leftIndex.clamp(0, entries.length - 1);
      _rightIndex = _rightIndex.clamp(0, entries.length - 1);
      if (canCompare && _leftIndex == _rightIndex) {
        _rightIndex = (_leftIndex + 1) % entries.length;
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.h,
              bottom: 16.h,
            ),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPARISON BENCH',
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Gauge Two\nShuttles',
                      style: GoogleFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.98,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Place two fly-shuttles on the bench and inspect where fiber, timber, tip metallurgy, and loom class diverge.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                canCompare
                    ? [
                        _selectors(entries),
                        SizedBox(height: 14.h),
                        _scoreCard(entries[_leftIndex], entries[_rightIndex]),
                        SizedBox(height: 14.h),
                        _comparisonRows(
                          entries[_leftIndex],
                          entries[_rightIndex],
                        ),
                      ]
                    : [_emptyState(entries.length)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectors(List<WeavingShuttleModel> entries) {
    final left = entries[_leftIndex];
    final right = entries[_rightIndex];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _shuttleSelector('BENCH A', left, entries, true),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _shuttleSelector('BENCH B', right, entries, false),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                Icons.swap_horiz_rounded,
                'SWAP POSITIONS',
                () => setState(() {
                  final nextLeft = _rightIndex;
                  _rightIndex = _leftIndex;
                  _leftIndex = nextLeft;
                }),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionButton(
                Icons.open_in_new_rounded,
                'OPEN BENCH A',
                () => Navigator.pushNamed(
                  context,
                  '/info_screen',
                  arguments: {'index': _leftIndex},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _shuttleSelector(
    String label,
    WeavingShuttleModel entry,
    List<WeavingShuttleModel> entries,
    bool isLeft,
  ) {
    final color = getFiberColor(entry.fiberType);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: isLeft ? _leftIndex : _rightIndex,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: color),
              dropdownColor: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              selectedItemBuilder: (_) => entries
                  .map(
                    (e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.artisanHallmark.toUpperCase(),
                        style: GoogleFonts.archivo(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              items: List.generate(
                entries.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    entries[index].artisanHallmark,
                    style: GoogleFonts.ibmPlexSans(
                      color: kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  if (isLeft) {
                    _leftIndex = value;
                    if (_leftIndex == _rightIndex) {
                      _rightIndex = (_leftIndex + 1) % entries.length;
                    }
                  } else {
                    _rightIndex = value;
                    if (_leftIndex == _rightIndex) {
                      _leftIndex = (_rightIndex + 1) % entries.length;
                    }
                  }
                });
              },
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            entry.shuttleRegistryMark,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        child: Ink(
          height: 44.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kBackground, size: 17.sp),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.ibmPlexMono(
                    color: kBackground,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(WeavingShuttleModel left, WeavingShuttleModel right) {
    final score = _heritageOverlap(left, right);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            height: 72.w,
            child: CustomPaint(
              painter: _HeritageGaugePainter(score / 100),
              child: Center(
                child: Text(
                  '$score%',
                  style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HERITAGE OVERLAP',
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _scoreMessage(score),
                  style: GoogleFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Fiber · timber · tip · loom class · wear',
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonRows(WeavingShuttleModel left, WeavingShuttleModel right) {
    final rows = [
      _CompareRow('Fiber', left.fiberType.label, right.fiberType.label),
      _CompareRow(
        'Loom Class',
        left.loomApplicationClass.label,
        right.loomApplicationClass.label,
      ),
      _CompareRow(
        'Timber',
        left.timberHardwood.label,
        right.timberHardwood.label,
      ),
      _CompareRow(
        'Eyelet',
        left.threadDeliveryEyelet.label,
        right.threadDeliveryEyelet.label,
      ),
      _CompareRow(
        'Tip Metallurgy',
        left.tipMetallurgy.label,
        right.tipMetallurgy.label,
      ),
      _CompareRow(
        'Bobbin Capacity',
        left.internalBobbinCapacity,
        right.internalBobbinCapacity,
      ),
      _CompareRow(
        'Wear',
        left.trackFrictionWear.label,
        right.trackFrictionWear.label,
      ),
      _CompareRow(
        'Ground Zero',
        left.weavingGroundZero,
        right.weavingGroundZero,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(children: rows.map(_comparisonRow).toList()),
    );
  }

  Widget _comparisonRow(_CompareRow row) {
    final same = row.left == row.right && row.left.isNotEmpty;
    final color = same ? kSecondaryAccent : kAccent;
    final surface = same ? kTealSurface : kAmberSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                same
                    ? Icons.check_circle_rounded
                    : Icons.compare_arrows_rounded,
                color: color,
                size: 15.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                row.label.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: color,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _valueBlock(row.left)),
              SizedBox(width: 8.w),
              Expanded(child: _valueBlock(row.right)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueBlock(String text) {
    return Text(
      text.isEmpty ? 'Not recorded' : text,
      style: GoogleFonts.ibmPlexSans(
        color: text.isEmpty
            ? kSecondaryText.withValues(alpha: 0.55)
            : kPrimaryText,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _emptyState(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        children: [
          Icon(Icons.compare_arrows_rounded, color: kAccent, size: 42.sp),
          SizedBox(height: 14.h),
          Text(
            count == 0
                ? 'NO SHUTTLES IN THIS SHED.'
                : 'ADD ONE MORE SHUTTLE.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The comparison bench needs at least two cataloged shuttles before it can calculate heritage overlap and contrast.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Exact matches on fiber, timber, tip, loom class; wear contributes
  /// full credit on equality and half credit when both are operational
  /// or both are non-operational.
  int _heritageOverlap(WeavingShuttleModel left, WeavingShuttleModel right) {
    double score = 0;
    const weight = 20.0;

    if (left.fiberType == right.fiberType) score += weight;
    if (left.timberHardwood == right.timberHardwood) score += weight;
    if (left.tipMetallurgy == right.tipMetallurgy) score += weight;
    if (left.loomApplicationClass == right.loomApplicationClass) {
      score += weight;
    }

    if (left.trackFrictionWear == right.trackFrictionWear) {
      score += weight;
    } else if (isOperationalWear(left.trackFrictionWear) ==
        isOperationalWear(right.trackFrictionWear)) {
      score += weight * 0.5;
    }

    return score.round().clamp(0, 100);
  }

  String _scoreMessage(int score) {
    if (score >= 80) return 'Near-identical shed cousins';
    if (score >= 60) return 'Shared mill lineage';
    if (score >= 40) return 'Partial engineering overlap';
    return 'Distinct shed specimens';
  }
}

class _CompareRow {
  final String label;
  final String left;
  final String right;
  const _CompareRow(this.label, this.left, this.right);
}

class _HeritageGaugePainter extends CustomPainter {
  final double fraction;
  const _HeritageGaugePainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = kAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()
        ..color = kSecondaryAccent.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _HeritageGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
