import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/providers/user_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  Future<void> _enterArchive(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref.read(userProvider).setFirstTimeUser(false);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ShedGridPainter())),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: kPanelBg,
                                borderRadius: BorderRadius.circular(kRadiusPill),
                                border: Border.all(color: kOutline),
                              ),
                              child: Text(
                                'MILL ROW ARCHIVE',
                                style: GoogleFonts.ibmPlexMono(
                                  color: kAccent,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'SHUTTLES OF\nTHE MILL ROW.',
                              style: GoogleFonts.archivo(
                                color: kPrimaryText,
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w700,
                                height: 0.94,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Container(width: 54.w, height: 2, color: kAccent),
                            SizedBox(height: 18.h),
                            Text(
                              'A industrial archive for heavy wooden fly-shuttles, internal pirns, and mechanical bobbins that once carried thread across massive looms.',
                              style: GoogleFonts.ibmPlexSans(
                                color: kSecondaryText,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w300,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 160.h),
                            Center(
                              child: SizedBox(
                                width: 120.w,
                                height: 48.w,
                                child: CustomPaint(
                                  painter: _ShuttleSilhouettePainter(
                                    color: kAccent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 28.h),
                            SizedBox(
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(kRadiusPill),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _enterArchive(context, ref),
                                    child: Ink(
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        color: kAccent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: kAccent.withValues(
                                              alpha: 0.28,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: kBackground,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            'ENTER THE SHED',
                                            style: GoogleFonts.ibmPlexMono(
                                              color: kBackground,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Center(
                              child: Text(
                                'Tap to begin cataloging your collection.',
                                style: GoogleFonts.ibmPlexSans(
                                  color: kSecondaryText,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Text(
                                'A misfit shuttle was a catastrophic failure event.',
                                style: GoogleFonts.ibmPlexSans(
                                  color: kSecondaryText.withValues(alpha: 0.72),
                                  fontSize: 11.sp,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withValues(alpha: 0.9)
      ..strokeWidth = 0.6;
    for (double y = 88; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 28; x < size.width; x += 72) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = kOutline.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShedGridPainter oldDelegate) => false;
}

class _ShuttleSilhouettePainter extends CustomPainter {
  final Color color;
  _ShuttleSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final midY = size.height / 2;
    path.moveTo(size.width * 0.06, midY);
    path.quadraticBezierTo(
      size.width * 0.18,
      midY - size.height * 0.42,
      size.width * 0.5,
      midY - size.height * 0.38,
    );
    path.quadraticBezierTo(
      size.width * 0.82,
      midY - size.height * 0.42,
      size.width * 0.94,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.82,
      midY + size.height * 0.42,
      size.width * 0.5,
      midY + size.height * 0.38,
    );
    path.quadraticBezierTo(
      size.width * 0.18,
      midY + size.height * 0.42,
      size.width * 0.06,
      midY,
    );
    path.close();
    canvas.drawPath(path, Paint()..color = color);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, midY),
        width: size.width * 0.22,
        height: size.height * 0.34,
      ),
      Paint()..color = kBackground.withValues(alpha: 0.55),
    );

    final tipPaint = Paint()..color = kSecondaryAccent;
    canvas.drawCircle(Offset(size.width * 0.05, midY), 3.2, tipPaint);
    canvas.drawCircle(Offset(size.width * 0.95, midY), 3.2, tipPaint);
  }

  @override
  bool shouldRepaint(covariant _ShuttleSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
