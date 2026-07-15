import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/providers/image_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = args['index'] as int;
    final project = ref.watch(projectProvider);

    if (index < 0 || index >= project.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'SHUTTLE NOT FOUND.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    final entry = project.entries[index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final fiberColor = getFiberColor(entry.fiberType);
    final wearColor = getConditionColor(entry.trackFrictionWear);
    final loomFraction = getLoomClassFraction(entry.loomApplicationClass);
    final hasPhoto =
        imagePath != null && File(imagePath).existsSync();

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.40,
            stretch: true,
            pinned: false,
            backgroundColor: kBackground,
            leadingWidth: 68.w,
            leading: _roundAction(
              Icons.arrow_back_rounded,
              () => Navigator.pop(context),
            ),
            actions: [
              _roundAction(
                Icons.delete_outline_rounded,
                () => _confirmDelete(context, ref, index),
              ),
              SizedBox(width: 8.w),
              _roundAction(Icons.edit_rounded, () {
                ref.read(projectProvider).fillInput(ref, index);
                Navigator.pushNamed(
                  context,
                  '/add_screen',
                  arguments: {'index': index, 'isEdit': true},
                );
              }),
              SizedBox(width: 16.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: hasPhoto
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Container(
                      color: kBackground,
                      child: Center(
                        child: CustomPaint(
                          size: Size(200.w, 72.w),
                          painter: _ShuttleSilhouettePainter(
                            color: isOperationalWear(entry.trackFrictionWear)
                                ? kAccent
                                : kSecondaryAccent,
                            fraction: loomFraction,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kRadiusLarge),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                28.h,
                20.w,
                MediaQuery.of(context).padding.bottom + 32.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _fiberBadge(entry.fiberType.label, fiberColor),
                      SizedBox(width: 8.w),
                      _threadSpecBadge(fiberThreadSpec(entry.fiberType)),
                      const Spacer(),
                      SizedBox(
                        width: 52.w,
                        height: 52.w,
                        child: CustomPaint(
                          painter: _LoomRingPainter(
                            fraction: loomFraction,
                            color: wearColor,
                          ),
                          child: Center(
                            child: Icon(
                              getLoomClassIcon(entry.loomApplicationClass),
                              color: wearColor,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    entry.artisanHallmark.toUpperCase(),
                    style: GoogleFonts.archivo(
                      color: kPrimaryText,
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.02,
                      letterSpacing: 0.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.shuttleRegistryMark,
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (entry.calibratedSite.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _millProvenancePill(entry.calibratedSite),
                  ],
                  SizedBox(height: 28.h),
                  _sectionHeader('LOOM APPLICATION'),
                  SizedBox(height: 12.h),
                  _floatingSpecCard(
                    icon: getLoomClassIcon(entry.loomApplicationClass),
                    eyebrow: 'LOOM APPLICATION CLASS',
                    value: entry.loomApplicationClass.label,
                    accent: kAccent,
                  ),
                  SizedBox(height: 12.h),
                  _floatingSpecCard(
                    icon: Icons.grain_rounded,
                    eyebrow: 'FIBER + THREAD SPEC',
                    value:
                        '${entry.fiberType.label}  ·  ${fiberThreadSpec(entry.fiberType)}',
                    accent: fiberColor,
                  ),
                  SizedBox(height: 28.h),
                  _sectionHeader('TIMBER & HARDWARE'),
                  _specRow('Timber & Hardwood', entry.timberHardwood.label),
                  _specRow(
                    'Thread Delivery Eyelet',
                    entry.threadDeliveryEyelet.label,
                  ),
                  _specRow('Tip Metallurgy', entry.tipMetallurgy.label),
                  _specRow(
                    'Internal Bobbin Capacity',
                    entry.internalBobbinCapacity,
                  ),
                  _specRow('Physical Proportions', entry.physicalProportions),
                  SizedBox(height: 24.h),
                  _sectionHeader('TRACK CONDITION'),
                  _wearRow(
                    'Track Friction Wear',
                    entry.trackFrictionWear.label,
                    wearColor,
                  ),
                  SizedBox(height: 24.h),
                  _sectionHeader('MILL RECORD'),
                  if (entry.weavingGroundZero.isNotEmpty)
                    _specRow('Weaving Ground Zero', entry.weavingGroundZero),
                  if (entry.temperatureRange.isNotEmpty)
                    _specRow('Temperature', entry.temperatureRange),
                  if (entry.era.isNotEmpty) _specRow('Era', entry.era),
                  if (entry.calibratedSite.isNotEmpty)
                    _specRow('Calibrated Site', entry.calibratedSite),
                  if (entry.notes.isNotEmpty) ...[
                    SizedBox(height: 28.h),
                    _sectionHeader('NOTES'),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: kPanelBg,
                        borderRadius: BorderRadius.circular(kRadiusSubtle),
                        border: Border.all(color: kOutline),
                        boxShadow: const [kShadowSubtle],
                      ),
                      child: Text(
                        entry.notes,
                        style: GoogleFonts.ibmPlexSans(
                          color: kPrimaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                  if (entry.tags.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: entry.tags
                          .map((tag) => _tagChip(tag))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPanelBg.withValues(alpha: 0.82),
                border: Border.all(color: kOutline),
              ),
              child: Icon(icon, color: kPrimaryText, size: 20.sp),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fiberBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _threadSpecBadge(String spec) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: kAmberSurface,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kAccent.withValues(alpha: 0.22)),
      ),
      child: Text(
        spec,
        style: GoogleFonts.ibmPlexMono(
          color: kAccent,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _millProvenancePill(String site) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kAccent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, color: kAccent, size: 14.sp),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              site,
              style: GoogleFonts.ibmPlexSans(
                color: kAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3.w, height: 14.h, color: kAccent),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.archivo(
            color: kPrimaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _floatingSpecCard({
    required IconData icon,
    required String eyebrow,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: accent, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: GoogleFonts.ibmPlexMono(
                    color: accent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132.w,
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wearRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132.w,
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 12.5.sp,
              ),
            ),
          ),
          Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 5.h, right: 8.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: kSelectedTint,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        tag.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kPanelBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          side: const BorderSide(color: kOutline),
        ),
        title: Text(
          'REMOVE FROM SHED?',
          style: GoogleFonts.archivo(
            color: kPrimaryText,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            letterSpacing: 0.4,
          ),
        ),
        content: Text(
          'This shuttle record will be permanently deleted from the local mill archive.',
          style: GoogleFonts.ibmPlexSans(
            color: kSecondaryText,
            fontSize: 13.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectProvider).deleteEntry(index);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'REMOVE',
              style: GoogleFonts.ibmPlexMono(
                color: kError,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuttleSilhouettePainter extends CustomPainter {
  final Color color;
  final double fraction;

  _ShuttleSilhouettePainter({required this.color, required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = color.withValues(alpha: 0.88);
    final tip = Paint()..color = kPrimaryText.withValues(alpha: 0.55);
    final pirn = Paint()..color = kBackground.withValues(alpha: 0.55);
    final guide = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cy = size.height / 2;
    final tipW = size.width * 0.08;
    final bodyH = size.height * 0.42;

    final path = Path()
      ..moveTo(tipW, cy)
      ..quadraticBezierTo(
        size.width * 0.18,
        cy - bodyH,
        size.width * 0.5,
        cy - bodyH,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        cy - bodyH,
        size.width - tipW,
        cy,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        cy + bodyH,
        size.width * 0.5,
        cy + bodyH,
      )
      ..quadraticBezierTo(size.width * 0.18, cy + bodyH, tipW, cy)
      ..close();

    canvas.drawPath(path, body);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(tipW * 0.55, cy),
          width: tipW * 1.1,
          height: bodyH * 0.55,
        ),
        const Radius.circular(2),
      ),
      tip,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width - tipW * 0.55, cy),
          width: tipW * 1.1,
          height: bodyH * 0.55,
        ),
        const Radius.circular(2),
      ),
      tip,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, cy),
        width: size.width * 0.22 * fraction.clamp(0.35, 1.0),
        height: bodyH * 0.55,
      ),
      pirn,
    );

    canvas.drawLine(
      Offset(size.width * 0.12, cy + bodyH + 10),
      Offset(size.width * 0.88, cy + bodyH + 10),
      guide,
    );
  }

  @override
  bool shouldRepaint(covariant _ShuttleSilhouettePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.fraction != fraction;
}

class _LoomRingPainter extends CustomPainter {
  final double fraction;
  final Color color;

  _LoomRingPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 3;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LoomRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
