import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';

enum QrBarcodeScanKind { qrCode, barcode }

/// Figma result screen after QR / Barcode camera scan (replaces PDF dialog).
class QrBarcodeScanResultScreen extends StatelessWidget {
  const QrBarcodeScanResultScreen({
    super.key,
    required this.kind,
    required this.content,
  });

  final QrBarcodeScanKind kind;
  final String content;

  String get _title =>
      kind == QrBarcodeScanKind.qrCode ? 'QR Code' : 'Barcode';

  bool get _looksLikeUrl {
    final v = content.trim().toLowerCase();
    return v.startsWith('http://') ||
        v.startsWith('https://') ||
        v.startsWith('www.');
  }

  Future<void> _openLink(BuildContext context) async {
    var value = content.trim();
    if (value.isEmpty) return;

    Uri? uri;
    if (_looksLikeUrl) {
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        value = 'https://$value';
      }
      uri = Uri.tryParse(value);
    } else {
      uri = Uri.parse(
        'https://www.google.com/search?q=${Uri.encodeComponent(value)}',
      );
    }

    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ui.AppToast.show(
        context,
        message: 'Could not open link',
        backgroundColor: const Color(0xFFE53935),
      );
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    ui.AppToast.success(context, 'Copied to Clipboard');
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.zero;
    await Share.share(
      content,
      subject: kind == QrBarcodeScanKind.qrCode
          ? 'Scanned QR Code'
          : 'Scanned Barcode',
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _title,
          style: ui.AppTextStyles.mainText().copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPaint(
                painter: _DashedBorderPainter(
                  color: ui.Colors.parentIconSelectTextColor,
                  radius: 12.r,
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FFF9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        ui.AppAssets.qrBarScannerOutputWebsiteIcon,
                        width: 38.w,
                        height: 40.w,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Link',
                              style: TextStyle(
                                fontFamily: ui.AppFonts.sfPro,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: ui.Colors.parentIconSelectTextColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              content,
                              style: TextStyle(
                                fontFamily: ui.AppFonts.sfPro,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: _Sparkles(color: const Color(0xFFB8E6CF)),
                  ),
                  Positioned(
                    right: 0,
                    child: _Sparkles(color: const Color(0xFFB8E6CF)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: VisitingGradientButton(
                      label: 'Open Link',
                      onTap: () => _openLink(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0E0E0),
                      thickness: 1,
                      endIndent: 8.w,
                    ),
                  ),
                  Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontFamily: ui.AppFonts.sfPro,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0E0E0),
                      thickness: 1,
                      indent: 8.w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      background: const Color(0xFFF6F2FF),
                      icon: ui.AppAssets.qrBarScannerOutputCopyIcon,
                      title: 'Copy Link',
                      subtitle: 'Copy link to clipboard',
                      onTap: () => _copy(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _QuickActionCard(
                      background: const Color(0xFFEBFEF5),
                      icon: ui.AppAssets.qrBarScannerOutputShareIcon,
                      title: 'Share Link',
                      subtitle: 'Share link with others',
                      onTap: () => _share(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkles extends StatelessWidget {
  const _Sparkles({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _line(18),
        SizedBox(height: 3.h),
        _line(12),
        SizedBox(height: 3.h),
        _line(8),
      ],
    );
  }

  Widget _line(double width) {
    return Container(
      width: width.w,
      height: 2.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.background,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color background;
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 40.w, height: 40.w),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ui.AppFonts.sfPro,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: ui.AppFonts.sfPro,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dashWidth = 5.0;
    const dashSpace = 3.5;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
