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

  // qrcode
   static const qrCodeTrendingIcon = 'assets/qrcode/trending.svg';
   static const qrCodeNewIcon = 'assets/qrcode/new.svg';
   static const qrCodeWifiIcon = 'assets/qrcode/wifi.svg';
   static const qrCodeEventIcon = 'assets/qrcode/event.svg';
   static const qrCodeSocialIcon = 'assets/qrcode/social.svg';
   static const qrCodeLoveIcon = 'assets/qrcode/love.svg';

   // trending
   static const qrCodeTrendingOneThumbnail = 'assets/qrcode/qr_code_1.png';
   static const qrCodeTrendingTwoThumbnail = 'assets/qrcode/qr_code_2.png';
   static const qrCodeTrendingThreeThumbnail = 'assets/qrcode/qr_code_3.png';
   static const qrCodeTrendingFourThumbnail = 'assets/qrcode/qr_code_4.png';
   static const qrCodeTrendingFiveThumbnail = 'assets/qrcode/qr_code_5.png';
   static const qrCodeTrendingSixThumbnail = 'assets/qrcode/qr_code_6.png';

   // new
   static const qrCodeNewOneThumbnail = 'assets/qrcode/qr_code_7.png';
   static const qrCodeNewTwoThumbnail = 'assets/qrcode/qr_code_8.png';
   static const qrCodeNewThreeThumbnail = 'assets/qrcode/qr_code_9.png';
   static const qrCodeNewFourThumbnail = 'assets/qrcode/qr_code_10.png';
   static const qrCodeNewFiveThumbnail = 'assets/qrcode/qr_code_11.png';
   static const qrCodeNewSixThumbnail = 'assets/qrcode/qr_code_12.png';

   // social
   static const qrCodeSocialOneThumbnail = 'assets/qrcode/qr_code_13.png';
   static const qrCodeSocialTwoThumbnail = 'assets/qrcode/qr_code_14.png';
   static const qrCodeSocialThreeThumbnail = 'assets/qrcode/qr_code_15.png';
   static const qrCodeSocialFourThumbnail = 'assets/qrcode/qr_code_16.png';
   static const qrCodeSocialFiveThumbnail = 'assets/qrcode/qr_code_17.png';
   static const qrCodeSocialSixThumbnail = 'assets/qrcode/qr_code_18.png';

   // wifi
   static const qrCodeWifiOneThumbnail = 'assets/qrcode/qr_code_19.png';
   static const qrCodeWifiTwoThumbnail = 'assets/qrcode/qr_code_20.png';
   static const qrCodeWifiThreeThumbnail = 'assets/qrcode/qr_code_21.png';
   static const qrCodeWifiFourThumbnail = 'assets/qrcode/qr_code_22.png';
   static const qrCodeWifiFiveThumbnail = 'assets/qrcode/qr_code_23.png';
   static const qrCodeWifiSixThumbnail = 'assets/qrcode/qr_code_24.png';

   // event
   static const qrCodeEventOneThumbnail = 'assets/qrcode/qr_code_25.png';
   static const qrCodeEventTwoThumbnail = 'assets/qrcode/qr_code_26.png';
   static const qrCodeEventThreeThumbnail = 'assets/qrcode/qr_code_27.png';
   static const qrCodeEventFourThumbnail = 'assets/qrcode/qr_code_28.png';
   static const qrCodeEventFiveThumbnail = 'assets/qrcode/qr_code_29.png';
   static const qrCodeEventSixThumbnail = 'assets/qrcode/qr_code_30.png';

   // love
   static const qrCodeLoveOneThumbnail = 'assets/qrcode/qr_code_31.png';
   static const qrCodeLoveTwoThumbnail = 'assets/qrcode/qr_code_32.png';
   static const qrCodeLoveThreeThumbnail = 'assets/qrcode/qr_code_33.png';
   static const qrCodeLoveFourThumbnail = 'assets/qrcode/qr_code_34.png';
   static const qrCodeLoveFiveThumbnail = 'assets/qrcode/qr_code_35.png';
   static const qrCodeLoveSixThumbnail = 'assets/qrcode/qr_code_36.png';

   // barcode
   static const barCodeOneThumbnail = 'assets/barcode/barcode_1.png';
   static const barCodeTwoThumbnail = 'assets/barcode/barcode_2.png';
   static const barCodeThreeThumbnail = 'assets/barcode/barcode_3.png';
   static const barCodeFourThumbnail = 'assets/barcode/barcode_4.png';
   static const barCodeFiveThumbnail = 'assets/barcode/barcode_5.png';
   static const barCodeSixThumbnail = 'assets/barcode/barcode_6.png';

   // qr code dialog icon
   static const qrDialogWifi = 'assets/qrcode/wifi 2.svg';
   static const qrDialogX = 'assets/qrcode/x.svg';
   static const qrDialogWhatsapp = 'assets/qrcode/whatsapp.svg';
   static const qrDialogViber = 'assets/qrcode/viber.svg';
   static const qrDialogWebsite = 'assets/qrcode/Website.svg';
   static const qrDialogText = 'assets/qrcode/text.svg';
   static const qrDialogSpotify = 'assets/qrcode/spotify.svg';
   static const qrDialogSms = 'assets/qrcode/sms.svg';
   static const qrDialogContacts = 'assets/qrcode/contacts.svg';
   static const qrDialogEmail = 'assets/qrcode/email.svg';
   static const qrDialogFacebook = 'assets/qrcode/facebook.svg';
   static const qrDialogInstagram = 'assets/qrcode/instagram.svg';
   static const qrDialogLocation = 'assets/qrcode/location.svg';
   static const qrDialogPhone = 'assets/qrcode/phone.svg';
   static const qrDialogProduct = 'assets/qrcode/product.svg';

   static const qrDialogMainLogo = 'assets/qrcode/qrcode_dialog_image.png';


   static const qrTemplateRowIconText = 'assets/qrcode/template_row_text_icon.svg';
   static const qrTemplateRowIconTemplate = 'assets/qrcode/template_row_template_icon.svg';
   static const qrTemplateRowIconColor = 'assets/qrcode/template_row_color_icon.svg';
   static const qrTemplateRowIconLogo = 'assets/qrcode/template_row_logo_icon.svg';
   static const qrTemplateRowIconEye = 'assets/qrcode/template_row_eye_icon.svg';
   static const qrTemplateRowIconDot = 'assets/qrcode/template_row_dot_icon.svg';


  // bar code dialog icon
  static const barGeneralTypes = 'assets/barcode/general_types.svg';
  static const barIsbn = 'assets/barcode/isbn.svg';
  static const barItf = 'assets/barcode/itf.svg';
  static const barItf14 = 'assets/barcode/itf_14.svg';
  static const barMsi = 'assets/barcode/msi.svg';
  static const barPdf417 = 'assets/barcode/pdf_417.svg';
  static const barUpcA = 'assets/barcode/upc_a.svg';
  static const barUpcE = 'assets/barcode/upc_e.svg';
  static const barEan13 = 'assets/barcode/ean_13.svg';
  static const barEan8 = 'assets/barcode/ean_8.svg';
  static const barDataMatrix = 'assets/barcode/data_matrix.svg';
  static const barCode128 = 'assets/barcode/code_128.svg';
  static const barCode93 = 'assets/barcode/code_93.svg';
  static const barCode39 = 'assets/barcode/code_39.svg';
  static const barCodaBar = 'assets/barcode/codabar.svg';



  static const barDialogMainLogo = 'assets/barcode/barcode_dialog_image.png';

  static const barTemplateRowText = 'assets/barcode/template_row_barcode_text_icon.svg';
  static const barTemplateRowTemplate = 'assets/barcode/template_row_barcode_template_icon.svg';
  static const barTemplateRowColor = 'assets/barcode/template_row_barcode_color_icon.svg';
  static const barTemplateRowHeight = 'assets/barcode/template_row_barcode_height_icon.svg';

  // QR stack frames (from PDF-Scanner generator)
  static const qrStackDotEyeDir = 'assets/qr_code_template/dot_and_eye/';
  static const qrStackNewDir = 'assets/qr_code_template/new/';
  static const qrStackSocialDir = 'assets/qr_code_template/social/';
  static const qrStackWifiDir = 'assets/qr_code_template/wifi/';
  static const qrStackEventDir = 'assets/qr_code_template/event/';
  static const qrStackLoveDir = 'assets/qr_code_template/love/';
  static const qrStackHotDir = 'assets/svg/genertor/qrcode/';

  // Barcode stack frames (indices 1,3,5,10,12,21)
  static const barStackGeneralTypes =
      'assets/svg/genertor/general_types_frame_bar_code.svg';
  static const barStackEan8 = 'assets/svg/genertor/barcode_EAN-8.svg';
  static const barStackBlue = 'assets/svg/genertor/blue.svg';
  static const barStackBag = 'assets/svg/bag_bar_code.svg';
  static const barStackWave = 'assets/svg/bar_code_wave_framee.svg';
  static const barStackTemplate21 = 'assets/svg/barcode_template_21.svg';


  static const noneIcon = 'assets/icons/none_icon.svg';
  static const noneIconOne = 'assets/icons/null_icon_one.png';
  static const multipleColorIcon = 'assets/icons/mutiple_color_picker.svg';


  // visiting template card icon
  static const pickerCameraIcon = 'assets/icons/camera_icon.svg';
  static const flashOnIcon = 'assets/icons/flash_on.svg';
  static const flashOffIcon = 'assets/icons/flash_off.svg';
  static const autoCameraIcon = 'assets/icons/Auto.svg';
  static const cropIcon = 'assets/icons/crop.svg';
  static const retakeIcon = 'assets/icons/retake.svg';
  static const galleryImportIcon = 'assets/icons/imagesIcon.svg';
  static const noCropIcon = 'assets/icons/nocrop.svg';
  static const autoCropIcon = 'assets/icons/auto_crop.svg';
  static const rotateLeftIcon = 'assets/icons/rotateleft.svg';
  static const rotateRightIcon = 'assets/icons/roate_right.svg';
  static const defaultQrcodeIcon = 'assets/icons/default_qrcode.png';
  static const visitingTemplateLocalFileUploadIcon = 'assets/icons/local_upload_icon.png';
  static const visitingTemplateEditIcon = 'assets/icons/green_edit.svg';
  static const visitingTemplateLocationIcon = 'assets/icons/green_location.svg';
  static const visitingTemplateMailIcon = 'assets/icons/green_mail.svg';
  static const visitingTemplatePhoneIcon = 'assets/icons/green_phone.svg';
  static const visitingTemplateShareIcon = 'assets/icons/green_share.svg';
  static const visitingTemplateIcon = 'assets/icons/green_template.svg';
  static const visitingTemplateWebsiteIcon = 'assets/icons/green_website.svg';
  static const visitingTemplateQrcodeCustomizeIcon = 'assets/icons/visiting_qr_customize_icon.svg';
  static const visitingTemplateQrcodePlaceIcon = 'assets/icons/visiting_qr_place_icon.svg';
  static const visitingTemplateAddIcon = 'assets/icons/add_icon.svg';
  static const visitingTemplateCrossIcon = 'assets/icons/cross_icon.svg';

  // select visiting template card without data
  static const vTemplateHorizontalOneFrontWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card front_01.png';
  static const vTemplateHorizontalOneBackWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card-Back_01.png';
  static const vTemplateHorizontalTwoFrontWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card front_02.png';
  static const vTemplateHorizontalTwoBackWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card-Back_02.png';
  static const vTemplateHorizontalThreeFrontWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card front_03.png';
  static const vTemplateHorizontalThreeBackWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card-Back_03.png';
  static const vTemplateHorizontalFourFrontWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card front_04.png';
  static const vTemplateHorizontalFourBackWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card-Back_04.png';
  static const vTemplateHorizontalFiveFrontWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card front_05.png';
  static const vTemplateHorizontalFiveBackWithOutData = 'assets/images/visiting_card_template_without_data/horizontal/business_card-Back_05.png';

  static const vTemplateVerticalOneFrontWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Front_01.png';
  static const vTemplateVerticalOneBackWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Back_01.png';
  static const vTemplateVerticalTwoFrontWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Front_02.png';
  static const vTemplateVerticalTwoBackWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Back_02.png';
  static const vTemplateVerticalThreeFrontWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Front_03.png';
  static const vTemplateVerticalThreeBackWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Back_03.png';
  static const vTemplateVerticalFourFrontWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Front_04.png';
  static const vTemplateVerticalFourBackWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Back_04.png';
  static const vTemplateVerticalFiveFrontWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Front_05.png';
  static const vTemplateVerticalFiveBackWithOutData = 'assets/images/visiting_card_template_without_data/vertical/Back_05.png';


  static const visitingCardAddPageIcon = 'assets/icons/Add page.svg';


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
