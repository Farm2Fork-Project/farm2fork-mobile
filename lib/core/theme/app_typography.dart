import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String primaryFontFamily = 'Open Sans';
  static const String secondaryFontFamily = 'Microsoft Sans Serif';

  static TextStyle get h1 => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle get body => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle get small => TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle get dashboard => TextStyle(
    fontFamily: secondaryFontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );
}
