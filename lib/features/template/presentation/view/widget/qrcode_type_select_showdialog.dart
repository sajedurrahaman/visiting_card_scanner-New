import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class _QrTypeOption {
  const _QrTypeOption({required this.icon, required this.label});
  final String icon;
  final String label;
}

const _qrTypeOptions = [
  _QrTypeOption(icon: ui.AppAssets.qrDialogWebsite, label: 'Website'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogWifi, label: 'Wi-Fi'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogText, label: 'Text'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogContacts, label: 'Contacts'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogSms, label: 'SMS'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogPhone, label: 'Phone'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogLocation, label: 'Location'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogWhatsapp, label: 'WhatsApp'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogFacebook, label: 'Facebook'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogInstagram, label: 'Instagram'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogEmail, label: 'Email'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogViber, label: 'Viber'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogX, label: 'X'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogSpotify, label: 'Spotify'),
  _QrTypeOption(icon: ui.AppAssets.qrDialogProduct, label: 'Product'),
];

class QrcodeTypeSelectDialog extends StatelessWidget {
  const QrcodeTypeSelectDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const QrcodeTypeSelectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = 360.w;
    final dialogHeight = 278.h;

    return Dialog(
      backgroundColor: const Color(0x00000000),
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: dialogWidth * 0.42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF5F4FD),
                      Color(0xFFDDCDF8),
                      Color(0xFFEEE7FB),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(14.w, 18.h, 10.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose QR Type',
                      style: ui.AppTextStyles.mainText().copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Select The content you want to Create QR for',
                      style: ui.AppTextStyles.helperText().copyWith(
                        fontSize: 11.sp,
                        letterSpacing: 0,
                        height: 1.3,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Image.asset(
                      ui.AppAssets.qrDialogMainLogo,
                      width: 128.w,
                      height: 132.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 10.h),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _qrTypeOptions.length,
                    itemBuilder: (context, index) {
                      final option = _qrTypeOptions[index];
                      return _QrTypeOptionTile(
                        option: option,
                        onTap: () => Navigator.pop(context, option.label),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrTypeOptionTile extends StatelessWidget {
  const _QrTypeOptionTile({
    required this.option,
    required this.onTap,
  });

  final _QrTypeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              option.icon,
              width: 24.w,
              height: 24.w,
            ),
            SizedBox(height: 5.h),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ui.AppTextStyles.iconUnderText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(
                fontSize: 9.sp,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
