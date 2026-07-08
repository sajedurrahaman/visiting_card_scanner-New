import 'dart:async';

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
  static const useTemplate = 'assets/icons/use_template.svg';
  static const scanWithCamera = 'assets/icons/scan_with_camera.svg';
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
  static const toastSuccessColor = Color(0xFF05B560);
}

class AppToast {
  AppToast._();

  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.toastSuccessColor,
  }) {
    hide();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Material(
              color: Color(0x00000000),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 32.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.sfPro,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _timer = Timer(duration, hide);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
