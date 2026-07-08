import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppAssets {
  static const splashLogo = 'assets/icons/splash_logo.svg';
  static const parentNavLogoOne = 'assets/icons/home.svg';
  static const parentNavLogoTwo = 'assets/icons/my_card.svg';
  static const parentNavLogoThree = 'assets/icons/folder.svg';
  static const parentNavLogoFour = 'assets/icons/setting.svg';
  static const parentNavLogoOneSelect = 'assets/icons/select_home.svg';
  static const parentNavLogoTwoSelect = 'assets/icons/select_my_card.svg';
  static const parentNavLogoThreeSelect = 'assets/icons/select_folder.svg';
  static const parentNavLogoFourSelect = 'assets/icons/select_setting.svg';
  static const parentNavLogoCenter = 'assets/icons/nav_center.svg';

  // home
  static const homeVisitingCard = 'assets/icons/visiting_card.svg';
  static const homeQrCode = 'assets/icons/qr_code.svg';
  static const homeBarCode = 'assets/icons/bar_code.svg';
  static const homeScreenRecentEmpty = 'assets/images/no_card_found.png';
}

class AppFonts {
  static const sfPro = 'SF Pro';
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle mainText({
    Color? color,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: AppFonts.sfPro,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: color ?? const Color(0xFF1A1A1A),
        letterSpacing: 1.0.sp,
      );

  static TextStyle helperText({Color? color}) => TextStyle(
        fontFamily: AppFonts.sfPro,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: color ?? const Color(0xFF6B6B6B),
    letterSpacing: 1.0.sp,
      );

  static TextStyle iconUnderText({Color? color}) => TextStyle(
    fontFamily: AppFonts.sfPro,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF6B6B6B),
    letterSpacing: 1.0.sp,
  );

  static TextStyle sellAllText({Color? color}) => TextStyle(
    fontFamily: AppFonts.sfPro,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF074D2B),
    letterSpacing: 1.0.sp,
  );


}

class Colors{
  static const parentNavColor = Color(0xFF123E38);
  static const parentIconSelectTextColor = Color(0xFF05B560);
  static const parentIconTextColor = Color(0xFFFFFFFF);
}
