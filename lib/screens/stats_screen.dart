import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _pressedMetric;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSheet(String title, List<Widget> children) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusLarge)),
          border: Border.all(color: kOutline),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: kOutline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: GoogleFonts.ibmPlexMono(
                  color: kPrimaryText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 8.h),
              const Divider(color: kOutline),
              SizedBox(height: 8.h),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Map<T, int> _countBy<T>(
    List<WeavingShuttleModel> entries,
    T Function(WeavingShuttleModel) selector,
  ) {
    final map = <T, int>{};
    for (final e in entries) {
      final key = selector(e);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final entries = project.entries;

    if (!project.isLoading && entries.isNotEmpty && !_controller.isAnimating) {
      // Replay entrance when collection grows
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _TelemetryGridPainter()),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildHeader(),
              if (project.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                )
              else if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildKeyMetrics(entries),
                      SizedBox(height: 24.h),
                      _sectionTitle('FIBER DISTRIBUTION'),
                      SizedBox(height: 12.h),
                      _buildFiberBars(entries),
                      SizedBox(height: 24.h),
                      _sectionTitle('LOOM APPLICATION CLASS'),
                      SizedBox(height: 12.h),
                      _buildLoomClassGrid(entries),
                      SizedBox(height: 24.h),
                      _sectionTitle('TRACK FRICTION WEAR'),
                      SizedBox(height: 12.h),
                      _buildWearStackedBar(entries),
                      SizedBox(height: 24.h),
                      _sectionTitle('TIMBER HARDWOOD'),
                      SizedBox(height: 12.h),
                      _buildTimberPills(entries),
                      SizedBox(height: 24.h),
                      _sectionTitle('TIP METALLURGY'),
                      SizedBox(height: 12.h),
                      _buildTipMetallurgy(entries),
                      SizedBox(height: 16.h),
                      _buildGroundZeroFooter(entries),
                    ]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18.h,
        bottom: 10.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOGBOOK',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Collection Telemetry',
                style: GoogleFonts.archivo(
                  color: kPrimaryText,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Operational pulse of the mill-row shed.',
                style: GoogleFonts.ibmPlexSans(
                  color: kSecondaryText,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(72.w, 72.w),
            painter: _EmptyRingPainter(),
          ),
          SizedBox(height: 18.h),
          Text(
            'NO TELEMETRY YET',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Catalogue shuttles to populate\nthe collection logbook.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText.withValues(alpha: 0.7),
              fontSize: 13.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 13.sp,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              color: kPrimaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(List<WeavingShuttleModel> entries) {
    final total = entries.length;
    final operational =
        entries.where((e) => isOperationalWear(e.trackFrictionWear)).length;
    final cased = total - operational;
    final opPct = total == 0 ? 0 : (operational / total * 100).round();
    final sites = entries
        .map((e) => e.weavingGroundZero)
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .length;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        return Row(
          children: [
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressedMetric = 0),
                onTapCancel: () => setState(() => _pressedMetric = null),
                onTapUp: (_) {
                  setState(() => _pressedMetric = null);
                  _showSheet('TOTAL SHUTTLES', [
                    _detailRow('Catalogue size', total.toString()),
                    _detailRow('Operational wear', operational.toString()),
                    _detailRow('Cased / held', cased.toString()),
                    _detailRow('Weaving grounds', sites.toString()),
                    SizedBox(height: 10.h),
                    Text(
                      'Registry marks tracked across Mill Row.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                  ]);
                },
                child: AnimatedScale(
                  scale: _pressedMetric == 0 ? 0.96 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    height: 132.h,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(kRadiusStandard),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          color: kBackground.withValues(alpha: 0.55),
                          size: 22.sp,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (total * t).round().toString().padLeft(2, '0'),
                              style: GoogleFonts.archivo(
                                color: kBackground,
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'TOTAL SHUTTLES',
                              style: GoogleFonts.ibmPlexMono(
                                color: kBackground.withValues(alpha: 0.75),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 132.h,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _pressedMetric = 1),
                        onTapCancel: () =>
                            setState(() => _pressedMetric = null),
                        onTapUp: (_) {
                          setState(() => _pressedMetric = null);
                          _showSheet('OPERATIONAL vs CASED', [
                            _detailRow(
                              'Operational (polished / light track)',
                              operational.toString(),
                            ),
                            _detailRow('Cased or damaged', cased.toString()),
                            _detailRow('Operational ratio', '$opPct%'),
                            SizedBox(height: 10.h),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(kRadiusPill),
                              child: SizedBox(
                                height: 10.h,
                                child: Row(
                                  children: [
                                    if (operational > 0)
                                      Expanded(
                                        flex: operational,
                                        child: Container(color: kAccent),
                                      ),
                                    if (cased > 0)
                                      Expanded(
                                        flex: cased,
                                        child: Container(
                                          color: kSecondaryAccent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ]);
                        },
                        child: AnimatedScale(
                          scale: _pressedMetric == 1 ? 0.95 : 1,
                          duration: const Duration(milliseconds: 100),
                          child: _miniMetric(
                            'OPERATIONAL',
                            '${(opPct * t).round()}%',
                            kAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _pressedMetric = 2),
                        onTapCancel: () =>
                            setState(() => _pressedMetric = null),
                        onTapUp: (_) {
                          setState(() => _pressedMetric = null);
                          _showSheet('CASED / HELD', [
                            _detailRow('Cased entries', cased.toString()),
                            _detailRow('Total', total.toString()),
                            SizedBox(height: 8.h),
                            Text(
                              cased == 0
                                  ? 'All shuttles remain on operational wear.'
                                  : 'Includes display-cased and scored/splintered stock.',
                              style: GoogleFonts.ibmPlexSans(
                                color: kSecondaryText,
                                fontSize: 12.sp,
                              ),
                            ),
                          ]);
                        },
                        child: AnimatedScale(
                          scale: _pressedMetric == 2 ? 0.95 : 1,
                          duration: const Duration(milliseconds: 100),
                          child: _miniMetric(
                            'CASED',
                            (cased * t).round().toString().padLeft(2, '0'),
                            kSecondaryAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _miniMetric(String label, String value, Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.archivo(
                color: accent,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiberBars(List<WeavingShuttleModel> entries) {
    final counts = _countBy(entries, (e) => e.fiberType);
    final total = entries.length;
    final fibers = FiberType.values
        .where((f) => (counts[f] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            children: [
              for (final fiber in fibers) ...[
                GestureDetector(
                  onTap: () {
                    final list =
                        entries.where((e) => e.fiberType == fiber).toList();
                    _showSheet('${fiber.label.toUpperCase()} FIBER', [
                      _detailRow('Count', list.length.toString()),
                      _detailRow(
                        'Share',
                        '${(list.length / total * 100).round()}%',
                      ),
                      _detailRow('Thread spec', fiberThreadSpec(fiber)),
                      SizedBox(height: 10.h),
                      ...list.take(8).map(
                            (e) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      color: getFiberColor(fiber),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      e.artisanHallmark.isEmpty
                                          ? e.shuttleRegistryMark
                                          : e.artisanHallmark,
                                      style: GoogleFonts.ibmPlexSans(
                                        color: kPrimaryText,
                                        fontSize: 13.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (list.length > 8)
                        Text(
                          '+${list.length - 8} more',
                          style: GoogleFonts.ibmPlexSans(
                            color: kSecondaryText,
                            fontSize: 11.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ]);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fiber.label,
                                style: GoogleFonts.ibmPlexSans(
                                  color: kPrimaryText,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${counts[fiber]}',
                              style: GoogleFonts.ibmPlexMono(
                                color: getFiberColor(fiber),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          child: SizedBox(
                            height: 8.h,
                            child: Stack(
                              children: [
                                Container(color: kOutline),
                                FractionallySizedBox(
                                  widthFactor: ((counts[fiber]! / total) *
                                          _animation.value)
                                      .clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          getFiberColor(fiber),
                                          getFiberColor(fiber)
                                              .withValues(alpha: 0.55),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (fibers.isEmpty)
                Text(
                  'No fiber data',
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 12.sp,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoomClassGrid(List<WeavingShuttleModel> entries) {
    final counts = _countBy(entries, (e) => e.loomApplicationClass);
    final classes = LoomApplicationClass.values.toList();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final cls = classes[index];
            final count = counts[cls] ?? 0;
            final frac = getLoomClassFraction(cls);
            return GestureDetector(
              onTap: () {
                final list = entries
                    .where((e) => e.loomApplicationClass == cls)
                    .toList();
                _showSheet(cls.label.toUpperCase(), [
                  _detailRow('Count', count.toString()),
                  _detailRow(
                    'Class weight',
                    '${(frac * 100).round()}%',
                  ),
                  SizedBox(height: 8.h),
                  if (list.isEmpty)
                    Text(
                      'No shuttles in this loom class.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                      ),
                    )
                  else
                    ...list.take(8).map(
                          (e) => _detailRow(
                            e.shuttleRegistryMark,
                            e.fiberType.label,
                          ),
                        ),
                ]);
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                  border: Border.all(
                    color: count > 0
                        ? kAccent.withValues(alpha: 0.35)
                        : kOutline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          getLoomClassIcon(cls),
                          size: 16.sp,
                          color: count > 0 ? kAccent : kSecondaryText,
                        ),
                        const Spacer(),
                        Text(
                          (count * _animation.value).round().toString(),
                          style: GoogleFonts.archivo(
                            color: count > 0 ? kPrimaryText : kSecondaryText,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      cls.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 11.sp,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    LayoutBuilder(
                      builder: (context, c) {
                        return CustomPaint(
                          size: Size(c.maxWidth, 3.h),
                          painter: _FracBarPainter(
                            fraction: frac * _animation.value,
                            color: count > 0 ? kAccent : kOutline,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWearStackedBar(List<WeavingShuttleModel> entries) {
    final counts = _countBy(entries, (e) => e.trackFrictionWear);
    final total = entries.length;
    final wears = TrackFrictionWear.values
        .where((w) => (counts[w] ?? 0) > 0)
        .toList();

    return GestureDetector(
      onTap: () {
        _showSheet('TRACK FRICTION WEAR', [
          for (final w in TrackFrictionWear.values)
            _detailRow(
              w.label,
              (counts[w] ?? 0).toString(),
            ),
          SizedBox(height: 10.h),
          Text(
            'Operational wear = polished wax or light track polish.',
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 12.sp,
            ),
          ),
        ]);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusStandard),
              border: Border.all(color: kOutline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  child: SizedBox(
                    height: 18.h,
                    child: Row(
                      children: [
                        for (final w in wears)
                          Expanded(
                            flex: math.max(
                              1,
                              ((counts[w]! / total) *
                                      100 *
                                      _animation.value)
                                  .round(),
                            ),
                            child: Container(
                              color: getConditionColor(w),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: [
                    for (final w in wears)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: getConditionColor(w),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${w.label} (${counts[w]})',
                            style: GoogleFonts.ibmPlexSans(
                              color: kSecondaryText,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimberPills(List<WeavingShuttleModel> entries) {
    final counts = _countBy(entries, (e) => e.timberHardwood);
    final timbers = TimberHardwood.values
        .where((t) => (counts[t] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final timber in timbers)
          GestureDetector(
            onTap: () {
              final list = entries
                  .where((e) => e.timberHardwood == timber)
                  .toList();
              _showSheet(timber.label.toUpperCase(), [
                _detailRow('Count', list.length.toString()),
                SizedBox(height: 8.h),
                ...list.take(10).map(
                      (e) => _detailRow(
                        e.shuttleRegistryMark,
                        e.tipMetallurgy.label.split(' ').first,
                      ),
                    ),
              ]);
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: kAmberSurface,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(
                      color: kAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timber.label,
                        style: GoogleFonts.ibmPlexSans(
                          color: kPrimaryText,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: kAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          '${(counts[timber]! * _animation.value).round()}',
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTipMetallurgy(List<WeavingShuttleModel> entries) {
    final counts = _countBy(entries, (e) => e.tipMetallurgy);
    final tips = TipMetallurgy.values
        .where((t) => (counts[t] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));
    final maxCount = tips.isEmpty
        ? 1
        : tips.map((t) => counts[t]!).reduce(math.max);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            children: [
              for (final tip in tips)
                GestureDetector(
                  onTap: () {
                    final list = entries
                        .where((e) => e.tipMetallurgy == tip)
                        .toList();
                    _showSheet(tip.label.toUpperCase(), [
                      _detailRow('Count', list.length.toString()),
                      SizedBox(height: 8.h),
                      ...list.take(8).map(
                            (e) => _detailRow(
                              e.shuttleRegistryMark,
                              e.timberHardwood.label,
                            ),
                          ),
                    ]);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36.w,
                          height: 36.w,
                          child: CustomPaint(
                            painter: _TipRingPainter(
                              progress: (counts[tip]! / maxCount) *
                                  _animation.value,
                              color: tip == TipMetallurgy.notTipped
                                  ? kSecondaryText
                                  : kSecondaryAccent,
                            ),
                            child: Center(
                              child: Text(
                                '${counts[tip]}',
                                style: GoogleFonts.ibmPlexMono(
                                  color: kPrimaryText,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            tip.label,
                            style: GoogleFonts.ibmPlexSans(
                              color: kPrimaryText,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: kSecondaryText.withValues(alpha: 0.5),
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroundZeroFooter(List<WeavingShuttleModel> entries) {
    final grounds = entries
        .map((e) => e.weavingGroundZero.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (grounds.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _showSheet('WEAVING GROUND ZERO', [
          _detailRow('Unique sites', grounds.length.toString()),
          SizedBox(height: 8.h),
          ...grounds.map(
            (g) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 14.sp, color: kAccent),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      g,
                      style: GoogleFonts.ibmPlexSans(
                        color: kPrimaryText,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: kTealSurface,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kSecondaryAccent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.map_outlined, color: kSecondaryAccent, size: 18.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '${grounds.length} weaving ground${grounds.length == 1 ? '' : 's'} logged',
                style: GoogleFonts.ibmPlexSans(
                  color: kPrimaryText,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Text(
              'VIEW',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryAccent,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Accent painters ────────────────────────────────────────────────────────

class _TelemetryGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withValues(alpha: 0.45)
      ..strokeWidth = 0.6;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.6),
        radius: 1.1,
        colors: [
          kAccent.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.38;
    final track = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final accent = Paint()
      ..color = kAccent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 0.55,
      false,
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FracBarPainter extends CustomPainter {
  final double fraction;
  final Color color;

  _FracBarPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = kOutline;
    final fg = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), bg..strokeWidth = 2);
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * fraction.clamp(0.0, 1.0), y),
      fg..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FracBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}

class _TipRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TipRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    final track = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _TipRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
