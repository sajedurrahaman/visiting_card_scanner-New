import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qr_template_stack_builder.dart';

/// Renders a QR (with optional template style) to a local PNG.
/// Does **not** save to gallery / recent / folder.
class VisitingCardQrImageHelper {
  VisitingCardQrImageHelper._();

  static Future<String?> renderToFile({
    required String qrData,
    required int templateIndex,
    double size = 512,
  }) async {
    final controller = ScreenshotController();
    final bytes = await controller.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: Colors.white,
            child: QrTemplateStackBuilder(
              templateIndex: templateIndex,
              qrData: qrData,
              size: size,
            ),
          ),
        ),
      ),
      pixelRatio: 2,
      delay: const Duration(milliseconds: 300),
    );

    return persistBytes(bytes);
  }

  static Future<String> persistBytes(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final qrDir = Directory('${dir.path}/visiting_card/qr_embed');
    if (!await qrDir.exists()) {
      await qrDir.create(recursive: true);
    }
    final file = File(
      '${qrDir.path}/vc_qr_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
