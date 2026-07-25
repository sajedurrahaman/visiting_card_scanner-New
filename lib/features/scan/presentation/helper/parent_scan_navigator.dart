import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_camera_scan_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_scan_result_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_camera_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/widget/parent_scan_mode_strip.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';

/// Opens / switches parent center-button camera modes (PDF Scanner parity).
class ParentScanNavigator {
  ParentScanNavigator._();

  static Future<void> open(
    BuildContext context, {
    ParentScanMode mode = ParentScanMode.visitingCard,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _pageFor(mode)),
    );
  }

  static void switchMode(BuildContext context, ParentScanMode mode) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _pageFor(mode),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static Widget _pageFor(ParentScanMode mode) {
    switch (mode) {
      case ParentScanMode.visitingCard:
        return ChangeNotifierProvider(
          create: (_) => VisitingCardScanViewModel(),
          child: VisitingCardCameraScreen(
            showScanModeStrip: true,
            scanMode: mode,
          ),
        );
      case ParentScanMode.qrCode:
        return QrBarcodeCameraScanScreen(
          kind: QrBarcodeScanKind.qrCode,
          showScanModeStrip: true,
          scanMode: mode,
        );
      case ParentScanMode.barcode:
        return QrBarcodeCameraScanScreen(
          kind: QrBarcodeScanKind.barcode,
          showScanModeStrip: true,
          scanMode: mode,
        );
    }
  }
}
