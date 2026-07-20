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
  static const useQrCodeTemplate = 'assets/icons/qrcode_template.svg';
  static const useBarCodeTemplate = 'assets/icons/barcode_template.svg';
  static const scanWithCamera = 'assets/icons/scan_with_camera.svg';

  // settings
  static const shareIcon = 'assets/icons/share_icon.svg';
  static const ratingIcon = 'assets/icons/rate_us_icon.svg';
  static const contactIcon = 'assets/icons/contacts_us.svg';
  static const privacyIcon = 'assets/icons/privacy_policy.svg';
  static const termsIcon = 'assets/icons/terms_icon.svg';

  // folder
  static const folderIcon = 'assets/icons/folder_icon.svg';
  static const createFolderIcon = 'assets/icons/create_folder.svg';
  static const folderSelectIcon = 'assets/icons/file_select.svg';
  static const moveIcon = 'assets/icons/move.svg';
  static const selectShareIcon = 'assets/icons/select_share.svg';
  static const delectIcon = 'assets/icons/delete.svg';
  static const moveSelectIcon = 'assets/icons/select_move.svg';
  static const deleteSelectIcon = 'assets/icons/select_delete.svg';

  // visiting_card_template
  static const vTemplateHorizontalOneFront = 'assets/images/visiting_card_template/horizontal/business_card front_01.png';
  static const vTemplateHorizontalOneBack = 'assets/images/visiting_card_template/horizontal/business_card-Back_01.png';
  static const vTemplateHorizontalTwoFront = 'assets/images/visiting_card_template/horizontal/business_card front_02.png';
  static const vTemplateHorizontalTwoBack = 'assets/images/visiting_card_template/horizontal/business_card-Back_02.png';
  static const vTemplateHorizontalThreeFront = 'assets/images/visiting_card_template/horizontal/business_card front_03.png';
  static const vTemplateHorizontalThreeBack = 'assets/images/visiting_card_template/horizontal/business_card-Back_03.png';
  static const vTemplateHorizontalFourFront = 'assets/images/visiting_card_template/horizontal/business_card front_04.png';
  static const vTemplateHorizontalFourBack = 'assets/images/visiting_card_template/horizontal/business_card-Back_04.png';
  static const vTemplateHorizontalFiveFront = 'assets/images/visiting_card_template/horizontal/business_card front_05.png';
  static const vTemplateHorizontalFiveBack = 'assets/images/visiting_card_template/horizontal/business_card-Back_05.png';

  static const vTemplateVerticalOneFront = 'assets/images/visiting_card_template/vertical/Front_01.png';
  static const vTemplateVerticalOneBack = 'assets/images/visiting_card_template/vertical/Back_01.png';
  static const vTemplateVerticalTwoFront = 'assets/images/visiting_card_template/vertical/Front_02.png';
  static const vTemplateVerticalTwoBack = 'assets/images/visiting_card_template/vertical/Back_02.png';
  static const vTemplateVerticalThreeFront = 'assets/images/visiting_card_template/vertical/Front_03.png';
  static const vTemplateVerticalThreeBack = 'assets/images/visiting_card_template/vertical/Back_03.png';
  static const vTemplateVerticalFourFront = 'assets/images/visiting_card_template/vertical/Front_04.png';
  static const vTemplateVerticalFourBack = 'assets/images/visiting_card_template/vertical/Back_04.png';
  static const vTemplateVerticalFiveFront = 'assets/images/visiting_card_template/vertical/Front_05.png';
  static const vTemplateVerticalFiveBack = 'assets/images/visiting_card_template/vertical/Back_05.png';

  static const inactiveLeftSideArrow = 'assets/icons/inactive_left_side_arrow.svg';
  static const activeLeftSideArrow = 'assets/icons/active_left_side_arrow.svg';
  static const inactiveRightSideArrow = 'assets/icons/inactive_right_side_arrow.svg';
  static const activeRightSideArrow = 'assets/icons/active_right_side_arrow.svg';


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
  static const cardBgColor = Color(0xFFF3FFF9);
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

class AppDialogs {
  AppDialogs._();

  static Future<bool> showDeleteDialog(
    BuildContext context, {
    String title = 'Delete Item',
    String message = 'Are you sure you want to delete the selected items?',
    String cancelText = 'Cancel',
    String confirmText = 'Ok',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF123E38).withValues(alpha: 0.28),
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: const Color(0xFFD8E6FF),
            width: 2.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.mainText(
                  color: const Color(0xFF1A1A1A),
                ).copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 26.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.helperText(
                  color: const Color(0xFF575757),
                ).copyWith(
                  fontSize: 17.sp,
                  height: 1.55,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A1A),
                        side: const BorderSide(color: Color(0xFF1A1A1A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        cancelText,
                        style: AppTextStyles.helperText(
                          color: const Color(0xFF1A1A1A),
                        ).copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF3DCB6A),
                            Color(0xFF0B5D2A),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x00000000),
                          foregroundColor: const Color(0xFFFFFFFF),
                          shadowColor: const Color(0x00000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          confirmText,
                          style: AppTextStyles.helperText(
                            color: const Color(0xFFFFFFFF),
                          ).copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
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

    return result ?? false;
  }

  static Future<String?> showRenameDialog(
    BuildContext context, {
    String title = 'Rename File',
    String? initialValue,
    String hintText = 'Office Document',
    String cancelText = 'Cancel',
    String confirmText = 'Save',
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: const Color(0xFF123E38).withValues(alpha: 0.28),
      builder: (_) => _RenameDialog(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );
  }

  static Widget _dialogActionButtons({
    required BuildContext dialogContext,
    required String cancelText,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Color(0xFF1A1A1A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              cancelText,
              style: AppTextStyles.helperText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF3DCB6A),
                  Color(0xFF0B5D2A),
                ],
              ),
            ),
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0x00000000),
                foregroundColor: const Color(0xFFFFFFFF),
                shadowColor: const Color(0x00000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                confirmText,
                style: AppTextStyles.helperText(
                  color: const Color(0xFFFFFFFF),
                ).copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({
    required this.title,
    this.initialValue,
    required this.hintText,
    required this.cancelText,
    required this.confirmText,
  });

  final String title;
  final String? initialValue;
  final String hintText;
  final String cancelText;
  final String confirmText;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: const Color(0xFFD8E6FF),
          width: 2.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.mainText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.helperText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 16.sp,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.helperText(
                  color: const Color(0xFFB0B0B0),
                ).copyWith(
                  fontSize: 16.sp,
                  letterSpacing: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF05B560),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF05B560),
                    width: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            AppDialogs._dialogActionButtons(
              dialogContext: context,
              cancelText: widget.cancelText,
              confirmText: widget.confirmText,
              onConfirm: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
