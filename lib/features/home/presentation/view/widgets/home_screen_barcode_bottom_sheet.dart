import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_camera_scan_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_scan_result_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/barcode_template_screen.dart';

enum _BarcodeScanMethod { useTemplate, scanWithCamera }

class HomeScreenBarcodeBottomSheet extends StatefulWidget {
  const HomeScreenBarcodeBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (_) => const HomeScreenBarcodeBottomSheet(),
    );
  }

  @override
  State<HomeScreenBarcodeBottomSheet> createState() =>
      _HomeScreenBarcodeBottomSheetState();
}

class _HomeScreenBarcodeBottomSheetState
    extends State<HomeScreenBarcodeBottomSheet> {
  _BarcodeScanMethod? _selectedMethod;

  void _openTemplates(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const BarcodeTemplateScreen(),
      ),
    );
  }

  void _openCamera(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const QrBarcodeCameraScanScreen(
          kind: QrBarcodeScanKind.barcode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 12.h + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chose scan Method',
            style: ui.AppTextStyles.mainText(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Select Now you want to scan or create your Barcode',
            style: ui.AppTextStyles.helperText(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          _ScanMethodCard(
            icon: ui.AppAssets.useBarCodeTemplate,
            title: 'Use Template',
            description:
                'Choose from Beautiful Templates and Customize your Barcode',
            isSelected: _selectedMethod == _BarcodeScanMethod.useTemplate,
            onTap: () {
              setState(() {
                _selectedMethod = _BarcodeScanMethod.useTemplate;
              });
              _openTemplates(context);
            },
          ),
          SizedBox(height: 10.h),
          _ScanMethodCard(
            icon: ui.AppAssets.scanWithCamera,
            title: 'Scan With Camera',
            description:
                'Scan Physical Barcode Using Camera and extract Details Automatically',
            isSelected: _selectedMethod == _BarcodeScanMethod.scanWithCamera,
            onTap: () {
              setState(() {
                _selectedMethod = _BarcodeScanMethod.scanWithCamera;
              });
              _openCamera(context);
            },
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Cancel',
                  style: ui.AppTextStyles.helperText(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanMethodCard extends StatelessWidget {
  const _ScanMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEBFEF5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4DA3FF)
                : const Color(0x00000000),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 48.w,
              height: 48.w,
            ),
            SizedBox(width: 10.w),
            Container(
              width: 1.w,
              height: 44.h,
              color: const Color(0xFFB8E6CF),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ui.AppTextStyles.helperText(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: ui.AppTextStyles.iconUnderText(
                      color: const Color(0xFF6B6B6B),
                    ).copyWith(fontSize: 10.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Color(0xFFD4F5E4),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: ui.Colors.parentIconSelectTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
