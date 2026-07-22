import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Builds framed barcode template stacks (PDF-Scanner style).
class BarcodeTemplateStackBuilder extends StatelessWidget {
  const BarcodeTemplateStackBuilder({
    super.key,
    required this.templateIndex,
    required this.barcodeData,
    this.foregroundColor,
    this.barcodeHeight,
  });

  final int templateIndex;
  final String barcodeData;
  final Color? foregroundColor;
  final double? barcodeHeight;

  Color get _color => foregroundColor ?? Colors.black;

  double get _height => barcodeHeight ?? 70;

  Widget _barcode({
    required double height,
    required double width,
  }) {
    return BarcodeWidget(
      height: height,
      width: width,
      drawText: false,
      barcode: Barcode.code128(),
      color: _color,
      data: barcodeData.isEmpty ? '1234567890' : barcodeData,
      errorBuilder: (context, error) => Center(
        child: Text(
          error,
          style: TextStyle(fontSize: 10.sp, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frameHeight = (_height + 80).h;

    switch (templateIndex) {
      case 1:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/genertor/general_types_frame_bar_code.svg',
              height: frameHeight,
              width: 300.w,
            ),
            _barcode(height: 60.h, width: 150.w),
          ],
        );
      case 3:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/genertor/barcode_EAN-8.svg',
              height: frameHeight,
              width: 300.w,
            ),
            Transform.translate(
              offset: Offset(0, 18.h),
              child: _barcode(height: _height.h, width: 150.w),
            ),
          ],
        );
      case 5:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/genertor/blue.svg',
              height: frameHeight,
              width: 300.w,
            ),
            Transform.translate(
              offset: Offset(0, 18.h),
              child: _barcode(height: _height.h, width: 150.w),
            ),
          ],
        );
      case 10:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/bag_bar_code.svg',
              height: frameHeight,
              width: 200.w,
            ),
            Transform.translate(
              offset: Offset(1.5.w, 16.h),
              child: _barcode(height: 40.h, width: 80.w),
            ),
          ],
        );
      case 12:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/bar_code_wave_framee.svg',
              height: frameHeight,
              width: 165.w,
            ),
            Transform.translate(
              offset: Offset(-1.w, -1.h),
              child: _barcode(height: 50.h, width: 90.w),
            ),
          ],
        );
      case 21:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/barcode_template_21.svg',
              height: frameHeight,
              width: 165.w,
            ),
            Transform.translate(
              offset: Offset(-2.w, 28.h),
              child: _barcode(height: 50.h, width: 85.w),
            ),
          ],
        );
      default:
        return _barcode(height: _height.h, width: 200.w);
    }
  }
}
