import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' show AppFonts;

/// QR template stacks — same structure as PDF Scanner `CustomizeCode._applyCustomTemplateStyle`.
class QrTemplateStackBuilder extends StatelessWidget {
  const QrTemplateStackBuilder({
    super.key,
    required this.templateIndex,
    required this.qrData,
    this.eyeShape,
    this.dotShape,
    this.foregroundColor,
    this.foregroundGradientColors,
    this.backgroundColor = Colors.white,
    this.backgroundGradientColors = const [],
    this.backgroundImage,
    this.size,
    this.logoAsset,
    this.logoText = '',
    this.logoSize = 25,
    this.logoTextColor = Colors.black,
    this.logoFontSize = 8,
    this.logoFontWeight = FontWeight.w400,
    this.logoFontStyle = FontStyle.normal,
  });

  final int templateIndex;
  final String qrData;

  /// Null = use template default (PDF: `_selectedEyeShape ?? …`).
  final QrEyeShape? eyeShape;
  final QrDataModuleShape? dotShape;

  /// Null = use template default (PDF: `_foregroundColor ?? …`).
  final Color? foregroundColor;
  final List<Color>? foregroundGradientColors;
  final Color backgroundColor;
  final List<Color> backgroundGradientColors;
  final String? backgroundImage;
  final double? size;
  final String? logoAsset;
  final String logoText;
  final double logoSize;
  final Color logoTextColor;
  final double logoFontSize;
  final FontWeight logoFontWeight;
  final FontStyle logoFontStyle;

  bool get _hasLogoAsset => logoAsset != null && logoAsset!.isNotEmpty;
  bool get _hasLogoText => logoText.isNotEmpty;
  bool get _hasLogo => _hasLogoAsset || _hasLogoText;

  bool get _hasForegroundGradient =>
      foregroundGradientColors != null && foregroundGradientColors!.length >= 2;

  Widget _logoOverlay() {
    if (_hasLogoAsset) {
      return SvgPicture.asset(
        logoAsset!,
        width: logoSize,
        height: logoSize,
      );
    }
    if (_hasLogoText) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          logoText,
          style: TextStyle(
            fontFamily: AppFonts.sfPro,
            color: logoTextColor,
            fontSize: logoFontSize.sp,
            fontWeight: logoFontWeight,
            fontStyle: logoFontStyle,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// PDF Scanner `_buildGradientQr`.
  Widget _buildGradientQr({
    required String qrData,
    required double size,
    bool gapless = true,
  }) {
    if (_hasForegroundGradient) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: foregroundGradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: QrImageView(
          data: qrData,
          size: size,
          gapless: gapless,
          backgroundColor: Colors.transparent,
          eyeStyle: QrEyeStyle(
            eyeShape: eyeShape ?? QrEyeShape.square,
            color: Colors.white,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: dotShape ?? QrDataModuleShape.square,
            color: Colors.white,
          ),
        ),
      );
    }

    return QrImageView(
      data: qrData,
      size: size,
      gapless: gapless,
      backgroundColor: Colors.transparent,
      eyeStyle: QrEyeStyle(
        eyeShape: eyeShape ?? QrEyeShape.square,
        color: foregroundColor ?? Colors.black,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: dotShape ?? QrDataModuleShape.square,
        color: foregroundColor ?? Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTemplate();
  }

  Widget _buildTemplate() {
    switch (templateIndex) {
      case 0:
        return Container(
          width: 170.w,
          height: 170.h,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: backgroundImage != null ? 150.w : 150.w,
                height: backgroundImage != null ? 150.h : 130.h,
                decoration: backgroundImage != null
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImage!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : backgroundGradientColors.length >= 2
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: backgroundGradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          )
                        : BoxDecoration(color: backgroundColor),
              ),
              _buildGradientQr(qrData: qrData, size: 160.sp),
              _logoOverlay(),
            ],
          ),
        );
      case 1:
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background
            if (backgroundImage != null)
              Container(
                height: 149.h,
                width: 149.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (backgroundGradientColors.length >= 2)
              Container(
                width: 142.sp,
                height: 142.sp,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: backgroundGradientColors),
                ),
              )
            else
              Container(
                width: 142.sp,
                height: 142.sp,
                color: backgroundColor,
              ),

            // QR
            _hasForegroundGradient
                ? ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: foregroundGradientColors!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: QrImageView(
                      data: qrData,
                      size: 160.sp,
                      gapless: false,
                      backgroundColor: Colors.transparent,
                      eyeStyle: QrEyeStyle(
                        eyeShape: eyeShape ?? QrEyeShape.leaf,
                        color: Colors.white,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape:
                            dotShape ?? QrDataModuleShape.roundedSquare,
                        color: Colors.white,
                      ),
                    ),
                  )
                : QrImageView(
                    data: qrData,
                    size: 160.sp,
                    gapless: false,
                    backgroundColor: Colors.transparent,
                    eyeStyle: QrEyeStyle(
                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                      color: foregroundColor ?? Colors.black,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape:
                          dotShape ?? QrDataModuleShape.roundedSquare,
                      color: foregroundColor ?? Colors.black,
                    ),
                  ),
            _logoOverlay(),
          ],
        );
      case 2:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_27_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 116.h,
                                width: 118.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 118.sp,
                                width: 118.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 118.sp,
                                width: 118.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 130.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.roundedOuter,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 130.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          _logoOverlay(),
                        ],
                      );
      case 3:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_24_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 14),
                              child: Container(
                                height: 108.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 14),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 14),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 14),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 120.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.roundedOuter,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.roundedSquare,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 14),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 120.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.roundedSquare,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, 14),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 4:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background
                          if (backgroundImage != null)
                            Container(
                              width: 210.sp,
                              height: 210.sp,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(backgroundImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Container(
                              width: 183.sp,
                              height: 183.sp,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: backgroundGradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 183.sp,
                              height: 183.sp,
                              color: backgroundColor,
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: foregroundGradientColors!,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                      blendMode: BlendMode.srcIn,
                                      child: QrImageView(
                                        data: qrData,
                                        size: 180.sp,
                                        gapless: false,
                                        padding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        eyeStyle: QrEyeStyle(
                                          eyeShape:
                                              eyeShape ?? QrEyeShape.square,
                                          color: Colors.white,
                                        ),
                                        dataModuleStyle: QrDataModuleStyle(
                                          dataModuleShape: dotShape ??
                                              QrDataModuleShape.square,
                                          color: Colors.white,
                                        ),
                                        embeddedImage: null,
                                      ),
                                    ),
                                    if (!_hasLogo)
                                      Image.asset(
                                        "assets/svg/genertor/qrcode/facebook.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                  ],
                                )
                              : QrImageView(
                                  data: qrData,
                                  size: 180.sp,
                                  gapless: false,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: eyeShape ?? QrEyeShape.square,
                                    color: foregroundColor ?? Color(0xff2076FD),
                                  ),
                                  embeddedImage: _hasLogo
                                      ? null
                                      : const AssetImage(
                                          "assets/svg/genertor/qrcode/facebook.png",
                                        ),
                                  embeddedImageStyle: const QrEmbeddedImageStyle(
                                    size: Size(30, 30),
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape:
                                        dotShape ?? QrDataModuleShape.square,
                                    color: foregroundColor ?? Color(0xff2076FD),
                                  ),
                                ),

                          _logoOverlay(),
                        ],
                      );
      case 5:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(0, -14),
                            child: SvgPicture.asset(
                              "assets/qr_code_template/wifi/wifi_tem_1.svg",
                              height: 152.h,
                              width: 152.w,
                            ),
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 8),
                              child: Container(
                                height: 113.h,
                                width: 116.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 8),
                              child: Container(
                                height: 116.sp,
                                width: 116.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 8),
                              child: Container(
                                height: 116.sp,
                                width: 116.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 8),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 130.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 8),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 130.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, 8),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 6:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/wifi/wifi_temp_18.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-2, -24),
                              child: Container(
                                height: 114.h,
                                width: 116.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-2, -24),
                              child: Container(
                                height: 117.sp,
                                width: 116.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-2, -24),
                              child: Container(
                                height: 117.sp,
                                width: 116.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-2, -24),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 130.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.horizontal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-2, -24),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 130.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.horizontal,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(-2, -24),
                            child: _logoOverlay(),
                          ),
                        ],
                      );


        // New template
      case 7:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_34_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-4, -18),
                              child: Container(
                                height: 88.h,
                                width: 88.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-4, -18),
                              child: Container(
                                height: 90.sp,
                                width: 90.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-4, -18),
                              child: Container(
                                height: 90.sp,
                                width: 90.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-4, -18),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 105.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.leaf,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-4, -18),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 105.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(-4, -18),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 8:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_21_tem.svg",
                            height: 196.h,
                            width: 196.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -14),
                              child: Container(
                                height: 122.h,
                                width: 126.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, -14),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, -14),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, -14),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 140.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.square,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.diamond,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/svg/genertor/qrcode/youtube.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, -14),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 140.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.red,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/svg/genertor/qrcode/youtube.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(30, 30),
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Color(0xffCF6400),
                                    ),
                                  ),
                                ),

                          Transform.translate(
                            offset: const Offset(0, -14),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 9:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_35_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -12),
                              child: Container(
                                height: 62.h,
                                width: 63.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, -12),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, -12),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, -12),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 80.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, -12),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 80.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, -12),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 10:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_tem_1.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 24),
                              child: Container(
                                height: 125.h,
                                width: 126.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 24),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 24),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 24),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 146.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.leaf,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 24),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 146.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                              offset: Offset(0, 24), child: _logoOverlay()),
                        ],
                      );
      case 11:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_30_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -16),
                              child: Container(
                                height: 98.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: Container(
                                height: 100.sp,
                                width: 100.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: Container(
                                height: 100.sp,
                                width: 100.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, -16),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 118.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.leaf,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, -16),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 118.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, -16),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 12:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/new/new_32_tem.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -10.h),
                              child: Container(
                                height: 108.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: Offset(0, -10.h),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: Offset(0, -10.h),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: Offset(0, -10.h),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 120.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: Offset(0, -10.h),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 120.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape:
                                          eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: Offset(0, -10.h),
                            child: _logoOverlay(),
                          ),
                        ],
                      );

      // Social template
      case 13:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_17.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 152.h,
                                width: 154.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 156.sp,
                                width: 156.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 156.sp,
                                width: 156.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 170.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape: eyeShape ??
                                                QrEyeShape.leaf,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.square,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/social/twiter.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 170.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape:
                                          eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/social/twiter.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(20, 20),
                                    ),
                                  ),
                                ),

                          // Logo
                          _logoOverlay(),
                        ],
                      );
      case 14:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_11.svg",
                            height: 166.h,
                            width: 166.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 200.h,
                                width: 200.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 186.sp,
                                width: 186.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 186.sp,
                                width: 186.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 170.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.star,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 170.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.star,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          _logoOverlay(),
                        ],
                      );
      case 15:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_20.svg",
                            height: 166.h,
                            width: 166.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 160.h,
                                width: 164.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 164.sp,
                                width: 164.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 164.sp,
                                width: 164.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 180.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.circle,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 180.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.circle,
                                      color: foregroundColor ?? Colors.white,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.white,
                                    ),
                                  ),
                                ),
                          _logoOverlay(),
                        ],
                      );
      case 16:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_19.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-1, 2),
                              child: Container(
                                height: 124.h,
                                width: 128.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-1, 2),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-1, 2),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-1, 2),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 140.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.star,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.diamond,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/social/facebook_small.png",
                                          width: 20,
                                          height: 20,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-1, 2),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 140.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.star,
                                      color: foregroundColor ?? Color(0xFF2076FD)
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Color(0xFF2076FD),
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/social/facebook_small.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(20, 20),
                                    ),
                                  ),
                                ),

                          // Logo
                          Transform.translate(
                            offset: const Offset(-1, 2),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 17:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_18.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0.w, -16.h),
                              child: Container(
                                height: 114.h,
                                width: 118.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: Offset(0.w, -16.h),
                              child: Container(
                                height: 118.sp,
                                width: 118.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: Offset(0.w, -16.h),
                              child: Container(
                                height: 118.sp,
                                width: 118.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: Offset(0.w, -16.h),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 130.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.roundedOuter,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.square,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/social/insta_small.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: Offset(0.w, -16.h),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 130.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/social/insta_small.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(30, 30),
                                    ),
                                  ),
                                ),

                          // Logo
                          Transform.translate(
                            offset: Offset(0.w, -16.h),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 18:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/social/Social_temp_13.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 122.h,
                                width: 124.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 124.sp,
                                width: 124.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 124.sp,
                                width: 124.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 140.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.square,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.square,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/social/telegram_small.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 140.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/social/telegram_small.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(30, 30),
                                    ),
                                  ),
                                ),

                          // Logo
                          _logoOverlay(),
                        ],
                      );

      // Wifi template
      case 19:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/wifi/wifi_temp_8.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 20),
                              child: Container(
                                height: 82.h,
                                width: 84.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 20),
                              child: Container(
                                height: 84.sp,
                                width: 84.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 20),
                              child: Container(
                                height: 84.sp,
                                width: 84.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 20),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 100.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 20),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 100.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, 20),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 20:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/wifi/wifi_tem_3.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-2, -22),
                              child: Container(
                                height: 112.h,
                                width: 116.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-2, -22),
                              child: Container(
                                height: 116.sp,
                                width: 116.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-2, -22),
                              child: Container(
                                height: 116.sp,
                                width: 116.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-2, -22),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 135.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.square,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.square,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/wifi/wifi_image.png",
                                          height: 25,
                                          width: 25,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-2, -22),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 135.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/wifi/wifi_image.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(25, 25),
                                    ),
                                  ),
                                ),

                          // Logo
                          Transform.translate(
                            offset: const Offset(-2, -22),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 21:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/wifi/wifi_temp_7.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 24),
                              child: Container(
                                height: 123.h,
                                width: 126.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 24),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 24),
                              child: Container(
                                height: 126.sp,
                                width: 126.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 24),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 140.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.leaf,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.square,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/wifi/wifi_image.png",
                                          height: 25,
                                          width: 25,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 24),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 140.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/wifi/wifi_image.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(25, 25),
                                    ),
                                  ),
                                ),

                          // Logo
                          Transform.translate(
                            offset: const Offset(0, 24),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 22:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              "assets/qr_code_template/wifi/wifi_temp_18.svg",
              height: 200.h,
              width: 200.w,
            ),
            if (backgroundImage != null)
              Transform.translate(
                offset: Offset(-2, -24),
                child: Container(
                  height: 114.h,
                  width: 116.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else if (backgroundGradientColors.length >= 2)
              Transform.translate(
                offset: const Offset(-2, -24),
                child: Container(
                  height: 117.sp,
                  width: 116.sp,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: backgroundGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            else if (backgroundColor != Colors.white)
                Transform.translate(
                  offset: const Offset(-2, -24),
                  child: Container(
                    height: 117.sp,
                    width: 116.sp,
                    color: backgroundColor,
                  ),
                ),
            _hasForegroundGradient
                ? Transform.translate(
              offset: const Offset(-2, -24),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: foregroundGradientColors!,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: QrImageView(
                  data: qrData,
                  size: 130.sp,
                  gapless: true,
                  backgroundColor: Colors.transparent,
                  eyeStyle: QrEyeStyle(
                    eyeShape:
                    eyeShape ?? QrEyeShape.square,
                    color: Colors.white,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: dotShape ??
                        QrDataModuleShape.horizontal,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : Transform.translate(
              offset: const Offset(-2, -24),
              child: QrImageView(
                data: qrData,
                size: 130.sp,
                gapless: true,
                eyeStyle: QrEyeStyle(
                    eyeShape: eyeShape ?? QrEyeShape.square,
                    color: foregroundColor ?? Colors.black
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape:
                  dotShape ?? QrDataModuleShape.horizontal,
                  color: foregroundColor ?? Colors.black,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(-2, -24),
              child: _logoOverlay(),
            ),
          ],
        );
      case 23:
        return Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              "assets/qr_code_template/wifi/wifi_temp_5.svg",
              height: 200.h,
              width: 200.w,
            ),
            if (backgroundImage != null)
              Transform.translate(
                offset: Offset(0, 20),
                child: Container(
                  height: 78.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else if (backgroundGradientColors.length >= 2)
              Transform.translate(
                offset: const Offset(0, 20),
                child: Container(
                  height: 80.sp,
                  width: 80.sp,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: backgroundGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            else if (backgroundColor != Colors.white)
                Transform.translate(
                  offset: const Offset(0, 20),
                  child: Container(
                    height: 80.sp,
                    width: 80.sp,
                    color: backgroundColor,
                  ),
                ),
            _hasForegroundGradient
                ? Transform.translate(
              offset: const Offset(0, 20),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: foregroundGradientColors!,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: QrImageView(
                  data: qrData,
                  size: 100.sp,
                  gapless: true,
                  backgroundColor: Colors.transparent,
                  eyeStyle: QrEyeStyle(
                    eyeShape: eyeShape ?? QrEyeShape.shield,
                    color: Colors.white,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: dotShape ??
                        QrDataModuleShape.square,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : Transform.translate(
              offset: const Offset(0, 20),
              child: QrImageView(
                data: qrData,
                size: 100.sp,
                gapless: true,
                eyeStyle: QrEyeStyle(
                  eyeShape: eyeShape ?? QrEyeShape.shield,
                  color: foregroundColor ?? Colors.black,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape:
                  dotShape ?? QrDataModuleShape.square,
                  color: foregroundColor ?? Colors.black,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 20),
              child: _logoOverlay(),
            ),
          ],
        );

      // Event template
      case 24:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/wifi/wifi_temp_14.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-1.w, -13.h),
                              child: Container(
                                height: 96.h,
                                width: 99.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: Offset(-1.w, -13.h),
                              child: Container(
                                height: 99.sp,
                                width: 99.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: Offset(-1.w, -13.h),
                              child: Container(
                                height: 99.sp,
                                width: 99.sp,
                                color: backgroundColor,
                              ),
                            ),

                          // QR
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: Offset(-1.w, -13.h),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: foregroundGradientColors!,
                                        ).createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: QrImageView(
                                          data: qrData,
                                          size: 110.sp,
                                          gapless: true,
                                          backgroundColor: Colors.transparent,
                                          eyeStyle: QrEyeStyle(
                                            eyeShape:
                                                eyeShape ?? QrEyeShape.circle,
                                            color: Colors.white,
                                          ),
                                          dataModuleStyle: QrDataModuleStyle(
                                            dataModuleShape: dotShape ??
                                                QrDataModuleShape.diamond,
                                            color: Colors.white,
                                          ),
                                          embeddedImage: null,
                                        ),
                                      ),
                                      if (!_hasLogo)
                                        Image.asset(
                                          "assets/qr_code_template/wifi/wifi_image.png",
                                          height: 25,
                                          width: 25,
                                        ),
                                    ],
                                  ),
                                )
                              : Transform.translate(
                                  offset: Offset(-1.w, -13.h),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 110.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.circle,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    embeddedImage: _hasLogo
                                        ? null
                                        : const AssetImage(
                                            "assets/qr_code_template/wifi/wifi_image.png",
                                          ),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(25, 25),
                                    ),
                                  ),
                                ),

                          Transform.translate(
                            offset: Offset(-1.w, -13.h),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 25:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_8.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(2, 3),
                              child: Container(
                                height: 108.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(2, 3),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(2, 3),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(2, 3),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 120.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(2, 3),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 120.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.roundedOuter,
                                      color: foregroundColor ?? Color(0xffF50302),
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(2, 3),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 26:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_4.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(3, 3),
                              child: Container(
                                height: 68.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(3, 3),
                              child: Container(
                                height: 70.sp,
                                width: 70.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(3, 3),
                              child: Container(
                                height: 70.sp,
                                width: 70.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(3, 3),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 90.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(3, 3),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 90.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(3, 3),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 27:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_13.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -5.h),
                              child: Container(
                                height: 78.h,
                                width: 80.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: Offset(0, -5.h),
                              child: Container(
                                height: 80.sp,
                                width: 80.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: Offset(0, -5.h),
                              child: Container(
                                height: 80.sp,
                                width: 80.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: Offset(0, -5.h),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 100.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.leaf,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: Offset(0, -5.h),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 100.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.leaf,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: Offset(0, -5.h),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 28:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_15.svg",
                            height: 210.h,
                            width: 210.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(2, 18),
                              child: Container(
                                height: 61.h,
                                width: 63.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(2, 18),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(2, 18),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(2, 18),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 80.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ??
                                            QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(2, 18),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 80.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape:
                                          eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape: dotShape ??
                                          QrDataModuleShape.square,
                                      color: foregroundColor ?? Color(0xff000000),
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(2, 18),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 29:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_1.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(2, 0),
                              child: Container(
                                height: 108.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(2, 0),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(2, 0),
                              child: Container(
                                height: 110.sp,
                                width: 110.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(2, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 135.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.circle,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(2, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 125.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.circle,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(2, 0),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 30:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/event/event_temp_9.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-2, -20),
                              child: Container(
                                height: 110.h,
                                width: 112.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-2, -20),
                              child: Container(
                                height: 112.sp,
                                width: 112.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-2, -20),
                              child: Container(
                                height: 112.sp,
                                width: 112.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-2, -20),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 120.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.star,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-2, -20),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 120.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.star,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(-2, -20),
                            child: _logoOverlay(),
                          ),
                        ],
                      );

      // Love template
      case 31:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/qr_code_template/love/love_temp_7.png",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 68.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 70.sp,
                                width: 70.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 70.sp,
                                width: 70.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 90.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.shield,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 90.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.shield,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          _logoOverlay(),
                        ],
                      );
      case 32:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/love/love_temp_6.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(-2, 22),
                              child: Container(
                                height: 81.h,
                                width: 83.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(-2, 22),
                              child: Container(
                                height: 83.sp,
                                width: 83.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(-2, 22),
                              child: Container(
                                height: 83.sp,
                                width: 83.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(-2, 22),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 100.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(-2, 22),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 100.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.red,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(-2, 22),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 33:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/love/love_temp_9.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, -1.h),
                              child: Container(
                                height: 111.h,
                                width: 115.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: Offset(0, -1.h),
                              child: Container(
                                height: 114.sp,
                                width: 114.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: Offset(0, -1.h),
                              child: Container(
                                height: 114.sp,
                                width: 114.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: Offset(0, -1.h),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 120.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.horizontal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: Offset(0, -1.h),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 120.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.horizontal,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: Offset(0, -1.h),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 34:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/qr_code_template/love/love -20.svg",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 12),
                              child: Container(
                                height: 61.h,
                                width: 63.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 12),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 12),
                              child: Container(
                                height: 63.sp,
                                width: 63.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 12),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 80.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.sharpCorner,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.square,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 12),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 80.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.sharpCorner,
                                      color: foregroundColor ?? Color(0xFF8E227B)
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.square,
                                      color: foregroundColor ?? Color(0xFFEF1586),
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, 12),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 35:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/qr_code_template/love/love_temp_4.png",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 8),
                              child: Container(
                                height: 58.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 8),
                              child: Container(
                                height: 60.sp,
                                width: 60.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 8),
                              child: Container(
                                height: 60.sp,
                                width: 60.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 8),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 80.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape:
                                            eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.roundedSquare,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 8),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 80.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.roundedSquare,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          Transform.translate(
                            offset: const Offset(0, 6),
                            child: _logoOverlay(),
                          ),
                        ],
                      );
      case 36:
        return Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/qr_code_template/love/love_temp_13.png",
                            height: 200.h,
                            width: 200.w,
                          ),
                          if (backgroundImage != null)
                            Transform.translate(
                              offset: Offset(0, 0),
                              child: Container(
                                height: 86.h,
                                width: 88.w,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(backgroundImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundGradientColors.length >= 2)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 88.sp,
                                width: 88.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: backgroundGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            )
                          else if (backgroundColor != Colors.white)
                            Transform.translate(
                              offset: const Offset(0, 0),
                              child: Container(
                                height: 88.sp,
                                width: 88.sp,
                                color: backgroundColor,
                              ),
                            ),
                          _hasForegroundGradient
                              ? Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: foregroundGradientColors!,
                                    ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: QrImageView(
                                      data: qrData,
                                      size: 105.sp,
                                      gapless: true,
                                      backgroundColor: Colors.transparent,
                                      eyeStyle: QrEyeStyle(
                                        eyeShape: eyeShape ?? QrEyeShape.square,
                                        color: Colors.white,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape: dotShape ??
                                            QrDataModuleShape.diamond,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: QrImageView(
                                    data: qrData,
                                    size: 105.sp,
                                    gapless: true,
                                    eyeStyle: QrEyeStyle(
                                      eyeShape: eyeShape ?? QrEyeShape.square,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                    dataModuleStyle: QrDataModuleStyle(
                                      dataModuleShape:
                                          dotShape ?? QrDataModuleShape.diamond,
                                      color: foregroundColor ?? Colors.black,
                                    ),
                                  ),
                                ),
                          _logoOverlay(),
                        ],
                      );
      default:
        return _buildGradientQr(qrData: qrData, size: 160.sp);
    }
  }
}
