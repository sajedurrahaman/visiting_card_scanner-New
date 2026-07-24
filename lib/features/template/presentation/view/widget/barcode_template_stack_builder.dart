import 'dart:math' as math;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' show AppFonts;
import 'package:visiting_card/features/template/domain/app_barcode_type.dart';
import 'package:visiting_card/features/template/presentation/helper/retail_barcode_guards.dart';

/// Barcode template stacks — PDF Scanner `BarCodeWidgetDatax` parity.
class BarcodeTemplateStackBuilder extends StatelessWidget {
  const BarcodeTemplateStackBuilder({
    super.key,
    required this.templateIndex,
    required this.barcodeData,
    required this.barcodeType,
    this.foregroundColor = Colors.black,
    this.foregroundGradientColors = const [],
    this.backgroundColor = Colors.transparent,
    this.backgroundGradientColors = const [],
    this.hasExplicitBackground = false,
    this.barcodeHeight = 150,
    this.pdf417Height = 8,
    this.headingText = '',
    this.showHeading = true,
    this.headingColor = Colors.black,
    this.headingFontSize = 20,
    this.showDetails = true,
    this.detailsColor = Colors.black,
    this.detailsFontSize = 16,
  });

  final int templateIndex;
  final String barcodeData;
  final AppBarcodeType barcodeType;
  final Color foregroundColor;
  final List<Color> foregroundGradientColors;
  final Color backgroundColor;
  final List<Color> backgroundGradientColors;
  final bool hasExplicitBackground;
  final double barcodeHeight;
  final double pdf417Height;
  final String headingText;
  final bool showHeading;
  final Color headingColor;
  final double headingFontSize;
  final bool showDetails;
  final Color detailsColor;
  final double detailsFontSize;

  bool get _isPdf417 => barcodeType == AppBarcodeType.pdf417;
  bool get _hasForegroundGradient => foregroundGradientColors.length >= 2;
  bool get _hasBackgroundGradient => backgroundGradientColors.length >= 2;

  String get _data => barcodeData.isEmpty ? '1234567890128' : barcodeData;

  Barcode get barcode => barcodeType.toBarcode();

  double get frameHeight =>
      _isPdf417 ? (pdf417Height * 20) + 60 : barcodeHeight + 80;

  Widget _withForegroundGradient(Widget child) {
    if (!_hasForegroundGradient) return child;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: foregroundGradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: child,
    );
  }

  Widget _barcodeContainer({
    required Widget child,
    bool showBackground = true,
    bool showText = true,
    bool showPadding = true,
    bool showHeadingInCard = false,
  }) {
    final graphic = _withForegroundGradient(child);

    return Container(
      padding: showPadding
          ? EdgeInsets.only(
              top: (showHeadingInCard && showHeading) ? 2 : 10,
              right: 10,
              bottom: 0,
              left: 10,
            )
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: _hasBackgroundGradient
            ? null
            : (showBackground
                ? (hasExplicitBackground ? backgroundColor : Colors.white)
                : (hasExplicitBackground
                    ? backgroundColor
                    : Colors.transparent)),
        gradient: _hasBackgroundGradient
            ? LinearGradient(
                colors: backgroundGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeadingInCard && showHeading)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                headingText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.sfPro,
                  color: headingColor,
                  fontSize: headingFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
          graphic,
          if (showDetails && showText)
            Text(
              _data,
              style: TextStyle(
                fontFamily: AppFonts.sfPro,
                fontSize: detailsFontSize,
                fontWeight: FontWeight.bold,
                color: detailsColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlainBarcode() {
    final useRetailGuards =
        RetailBarcodeGuards.useDrawTextForBarHeights(barcodeType);

    if (_isPdf417) {
      return _barcodeContainer(
        showBackground: false,
        showText: false,
        child: BarcodeWidget(
          barcode: barcode,
          drawText: false,
          height: pdf417Height * 20,
          width: 250,
          color: foregroundColor,
          data: _data,
          errorBuilder: (context, error) => Center(child: Text(error)),
        ),
      );
    }

    return _barcodeContainer(
      showHeadingInCard: true,
      child: BarcodeWidget(
        height: barcodeHeight,
        width: 200,
        barcode: barcode,
        drawText: useRetailGuards,
        style: useRetailGuards
            ? RetailBarcodeGuards.invisibleEmbeddedDigitsStyle(barcodeHeight)
            : null,
        textPadding: useRetailGuards ? 3 : 5,
        color: foregroundColor,
        data: _data,
        errorBuilder: (context, error) => Center(child: Text(error)),
      ),
    );
  }

  Widget _buildTemplateCase(int index) {
    switch (index) {

        case 28:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_28.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(0.w, 12.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 50.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 27:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_27.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(1.w, 22.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 50.h,
                    width: 90.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 26:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_26.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-2.w, 16.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 60.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 25:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_25.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, -6.h),
                child: _barcodeContainer(
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 100.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 24:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_24.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, 4.h),
                child: _barcodeContainer(
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 90.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 23:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_23.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-29.w, -10.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 50.h,
                    width: 70.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 22:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_22.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, 30.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 90.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
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
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 50.h,
                    width: 85.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 20:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_20.svg',
                height: frameHeight,
                width: 220.w,
              ),
              Transform.translate(
                offset: Offset(5.w, 3.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 70.w,
                    drawText: false,
                    barcode: Barcode.code128(),
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 19:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_19.svg',
                height: frameHeight,
                width: 200.w,
              ),
              Transform.translate(
                offset: Offset(-3.w, 24.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 70.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 18:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_18.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, 35.h),
                child: _barcodeContainer(
                  showBackground: false,
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 35.h,
                    width: 48.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 17:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_17.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, -40.h),
                child: _barcodeContainer(
                  showBackground: false,
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 50.h,
                    width: 100.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 16:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_16.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(12.w, -18.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 85.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 15:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_15.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(34.w, -1.h),
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: _barcodeContainer(
                    showText: false,
                    showPadding: false,
                    child: BarcodeWidget(
                      height: 54.h,
                      width: 110.w,
                      drawText: false,
                      style: TextStyle(
                        fontSize: detailsFontSize.sp,
                        fontWeight: FontWeight.bold,
                        color: detailsColor,
                      ),
                      barcode: Barcode.code128(),
                      color: foregroundColor,
                      data: _data,
                      errorBuilder: (context, error) =>
                          Center(child: Text('$error')),
                    ),
                  ),
                ),
              ),
            ],
          );
        case 14:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_14.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(3.w, 20.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 40.h,
                    width: 88.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );
        case 13:
          return Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/barcode_template_13.svg',
                height: frameHeight,
                width: 165.w,
              ),
              Transform.translate(
                offset: Offset(-1.w, 20.h),
                child: _barcodeContainer(
                  showText: false,
                  showPadding: false,
                  child: BarcodeWidget(
                    height: 50.h,
                    width: 90.w,
                    drawText: false,
                    style: TextStyle(
                      fontSize: detailsFontSize.sp,
                      fontWeight: FontWeight.bold,
                      color: detailsColor,
                    ),
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text('$error')),
                  ),
                ),
              ),
            ],
          );

        case 12:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/bar_code_wave_framee.svg",
                height: frameHeight, width: 165.w),
            Transform.translate(
                offset: Offset(-1.w, 0.h),
                child: _barcodeContainer(
                    showText: false,
                    showPadding: false,
                    child: BarcodeWidget(
                        height: 60.h,
                        width: 100.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 11:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/3_corner_frame.svg",
                height: frameHeight, width: 220.w),
            Transform.translate(
                offset: Offset(-9.w, 3.h),
                child: _barcodeContainer(
                    showText: false,
                    showPadding: false,
                    child: BarcodeWidget(
                        height: 40.h,
                        width: 70.w,
                        drawText: false,
                        barcode: Barcode.code128(),
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 10:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/bag_bar_code.svg",
                height: frameHeight, width: 200.w),
            Transform.translate(
                offset: Offset(1.5.w, 16.h),
                child: _barcodeContainer(
                    showText: false,
                    showPadding: false,
                    child: BarcodeWidget(
                        height: 40.h,
                        width: 80.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 9:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/cart_bar_code_frame.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(10.w, -2.h),
                child: _barcodeContainer(
                    showText: false,
                    showPadding: false,
                    child: BarcodeWidget(
                        height: 30.h,
                        width: 60.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 8:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/four_corner.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 0.h),
                child: _barcodeContainer(
                    child: BarcodeWidget(
                        height: 60.h,
                        width: 140.w,
                        drawText: false,
                        barcode: Barcode.code128(),
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 7:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/fourvug.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 0.h),
                child: _barcodeContainer(
                    child: BarcodeWidget(
                        height: 50.h,
                        width: 140.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 6:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/yellow.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 18.h),
                child: _barcodeContainer(
                    showBackground: true,
                    child: BarcodeWidget(
                        height: 65.h,
                        width: 150.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 5:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/blue.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 18.h),
                child: _barcodeContainer(
                    showBackground: true,
                    child: BarcodeWidget(
                        height: 70.h,
                        width: 150.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 4:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/red_color_frame_bar_code.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 18.h),
                child: _barcodeContainer(
                    showBackground: true,
                    child: BarcodeWidget(
                        height: 70.h,
                        width: 150.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 3:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/barcode_EAN-8.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 18.h),
                child: _barcodeContainer(
                    showBackground: true,
                    child: BarcodeWidget(
                        height: 70.h,
                        width: 150.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 2:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset("assets/svg/genertor/barcode_EAN-13.svg",
                height: frameHeight, width: 300.w),
            Transform.translate(
                offset: Offset(0.w, 18.h),
                child: _barcodeContainer(
                    showBackground: true,
                    child: BarcodeWidget(
                        height: 70.h,
                        width: 150.w,
                        drawText: false,
                        style: TextStyle(
                            fontSize: detailsFontSize.sp,
                            fontWeight: FontWeight.bold,
                            color: detailsColor),
                        barcode: Barcode.code128(),
                        color: foregroundColor,
                        data: _data,
                        errorBuilder: (context, error) =>
                            Center(child: Text(error))))),
          ]);
        case 1:
          return Stack(alignment: Alignment.center, children: [
            SvgPicture.asset(
                "assets/svg/genertor/general_types_frame_bar_code.svg",
                height: frameHeight,
                width: 300.w),
            _barcodeContainer(
                child: BarcodeWidget(
                    height: 60.h,
                    width: 150.w,
                    drawText: false,
                    barcode: Barcode.code128(),
                    color: foregroundColor,
                    data: _data,
                    errorBuilder: (context, error) =>
                        Center(child: Text(error)))),
          ]);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (templateIndex <= 0) {
      return _buildPlainBarcode();
    }
    return _buildTemplateCase(templateIndex);
  }
}
