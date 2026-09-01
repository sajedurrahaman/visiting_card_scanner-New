import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';

/// Share via QR Code — same flow as PDF Scanner `QrCodePage`.
class VisitingCardShareQrScreen extends StatefulWidget {
  const VisitingCardShareQrScreen({super.key, required this.shareText});

  final String shareText;

  @override
  State<VisitingCardShareQrScreen> createState() =>
      _VisitingCardShareQrScreenState();
}

class _VisitingCardShareQrScreenState extends State<VisitingCardShareQrScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final data =
        widget.shareText.trim().isEmpty ? 'No contact data' : widget.shareText;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Share via QR Code'),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Scan qr code..'),
            const SizedBox(height: 50),
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(
                    errorCorrectLevel: BarcodeQRCorrectionLevel.low,
                  ),
                  data: data,
                  width: 300,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text('Or'),
            const SizedBox(height: 50),
            CupertinoButton(
              color: ui.Colors.parentIconSelectTextColor,
              padding: const EdgeInsets.all(8),
              onPressed: () async {
                try {
                  final directory = await getTemporaryDirectory();
                  final imagePath = await _screenshotController.captureAndSave(
                    directory.path,
                  );
                  if (imagePath != null) {
                    await VisitingCardShareHelper.shareXFiles(
                      context,
                      [XFile(imagePath)],
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share failed: $e')),
                    );
                  }
                }
              },
              child: const SizedBox(
                width: 100,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Share'),
                      Icon(Icons.share),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
