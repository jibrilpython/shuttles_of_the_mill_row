import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';

const Color kBackground = Color(0xFF100C08);
const Color kPrimaryText = Color(0xFFEDE6D8);
const Color kPanelBg = Color(0xFF181208);
const Color kSecondaryText = Color(0xFF6E6050);
const Color kAccent = Color(0xFFC4873A);
const Color kSecondaryAccent = Color(0xFF4A7A6A);
const Color kOutline = Color(0xFF1E1810);
const Color kError = Color(0xFFC0392B);
const Color kSelectedTint = Color(0xFF1A1008);
const Color kTealSurface = Color(0xFF14201C);
const Color kAmberSurface = Color(0xFF24180E);

const double kRadiusSubtle = 10;
const double kRadiusStandard = 16;
const double kRadiusMedium = 24;
const double kRadiusLarge = 32;
const double kRadiusPill = 999;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -4,
  color: Color(0x66000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 18),
  blurRadius: 34,
  spreadRadius: -16,
  color: Color(0x99000000),
);

const double kBottomNavBarHeight = 68;
const double kBottomNavBarMargin = 16;
const double kAddButtonGapAboveNav = 12;

double bottomNavOverlayHeight(BuildContext context) {
  return MediaQuery.of(context).padding.bottom +
      kBottomNavBarMargin.h +
      kBottomNavBarHeight.h;
}

double homeAddButtonBottom(BuildContext context) {
  return bottomNavOverlayHeight(context) + kAddButtonGapAboveNav.h;
}

Color getFiberColor(FiberType fiber) {
  switch (fiber) {
    case FiberType.cotton:
      return kAccent;
    case FiberType.wool:
      return const Color(0xFFB89A6A);
    case FiberType.silk:
      return const Color(0xFFD4B878);
    case FiberType.linen:
      return const Color(0xFF8A9A6E);
    case FiberType.synthetic:
      return kSecondaryAccent;
    case FiberType.mixed:
      return const Color(0xFF9A7060);
  }
}

Color getConditionColor(TrackFrictionWear state) {
  switch (state) {
    case TrackFrictionWear.polishedWax:
    case TrackFrictionWear.lightTrackPolish:
      return kAccent;
    case TrackFrictionWear.displayCased:
      return kSecondaryAccent;
    case TrackFrictionWear.splitGrainScoring:
      return const Color(0xFFC9A050);
    case TrackFrictionWear.splinteredHeel:
    case TrackFrictionWear.noseCapDisplacement:
      return kError;
  }
}

bool isOperationalWear(TrackFrictionWear state) {
  return state == TrackFrictionWear.polishedWax ||
      state == TrackFrictionWear.lightTrackPolish;
}

double getLoomClassFraction(LoomApplicationClass classification) {
  switch (classification) {
    case LoomApplicationClass.northropAutomatic:
      return 1.0;
    case LoomApplicationClass.draperBoxLoom:
      return 0.86;
    case LoomApplicationClass.powerLoomFly:
      return 0.72;
    case LoomApplicationClass.handLoomFly:
      return 0.58;
    case LoomApplicationClass.skiShuttleFrame:
      return 0.42;
    case LoomApplicationClass.silkRibbonNarrow:
      return 0.28;
  }
}

IconData getLoomClassIcon(LoomApplicationClass classification) {
  switch (classification) {
    case LoomApplicationClass.handLoomFly:
      return Icons.handshake_outlined;
    case LoomApplicationClass.northropAutomatic:
      return Icons.precision_manufacturing_rounded;
    case LoomApplicationClass.draperBoxLoom:
      return Icons.view_week_rounded;
    case LoomApplicationClass.silkRibbonNarrow:
      return Icons.straighten_rounded;
    case LoomApplicationClass.powerLoomFly:
      return Icons.bolt_rounded;
    case LoomApplicationClass.skiShuttleFrame:
      return Icons.snowboarding_rounded;
  }
}

String fiberThreadSpec(FiberType fiber) {
  switch (fiber) {
    case FiberType.cotton:
      return 'Cotton 2/60s';
    case FiberType.wool:
      return 'Wool 2/32Nm';
    case FiberType.silk:
      return 'Silk 20/22 denier';
    case FiberType.linen:
      return 'Linen 40 lea';
    case FiberType.synthetic:
      return 'Synth 150 denier';
    case FiberType.mixed:
      return 'Mixed count';
  }
}
