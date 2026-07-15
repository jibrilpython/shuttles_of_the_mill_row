import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: kAccent,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      secondary: kSecondaryAccent,
      surface: kPanelBg,
      onSurface: kPrimaryText,
      onPrimary: kBackground,
      error: kError,
      outline: kOutline,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.archivo(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
      ),
      iconTheme: const IconThemeData(color: kPrimaryText),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.archivo(
        fontSize: 54.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 0.96,
      ),
      displayMedium: GoogleFonts.archivo(
        fontSize: 42.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        height: 0.98,
      ),
      headlineMedium: GoogleFonts.archivo(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: kPrimaryText,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: kPrimaryText,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
        color: kSecondaryText,
      ),
      labelLarge: GoogleFonts.ibmPlexMono(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: kPrimaryText,
        letterSpacing: 0.4,
      ),
      labelMedium: GoogleFonts.ibmPlexMono(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: kSecondaryText,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.ibmPlexMono(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: kSecondaryText,
        letterSpacing: 0.4,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kPanelBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        borderSide: const BorderSide(color: kAccent, width: 1.5),
      ),
      hintStyle: GoogleFonts.ibmPlexSans(
        color: kSecondaryText.withValues(alpha: 0.5),
        fontSize: 13.sp,
      ),
      labelStyle: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 10.sp,
        letterSpacing: 0.8,
      ),
      floatingLabelStyle: GoogleFonts.ibmPlexMono(
        color: kAccent,
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: kBackground,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 28.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
        ),
        textStyle: GoogleFonts.ibmPlexMono(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ),
    useMaterial3: true,
  );
}
