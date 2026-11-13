import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_scan_result_screen.dart';

/// Persists QR / Barcode camera scans like PDF Scanner (.txt under Convert Document).
class QrBarcodeScanStorage {
  QrBarcodeScanStorage._();

  static Future<SavedFileModel?> saveScan({
    required BuildContext context,
    required QrBarcodeScanKind kind,
    required String text,
  }) async {
    final value = text.trim();
    if (value.isEmpty) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final stamp = now.millisecondsSinceEpoch.toString();
    final isQr = kind == QrBarcodeScanKind.qrCode;

    final folderName = isQr ? 'QR Code' : 'Barcode';
    final filePrefix = isQr ? 'QrCode' : 'BarCode';
    final dir = Directory('${appDir.path}/Convert Document/$folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = '${dir.path}/${filePrefix}_$stamp.txt';
    await File(filePath).writeAsString(value);

    final model = SavedFileModel(
      id: stamp,
      name: '${filePrefix}_$stamp',
      dateTime: DateFormat('dd-MMM-yyyy HH:mm').format(now),
      path: filePath,
      pathImage: '',
      fileType: isQr ? 'qr' : 'barcode',
      folderId: isQr
          ? FolderViewModel.qrCodeFolderId
          : FolderViewModel.barcodeFolderId,
      isTextFile: true,
    );

    await AppStorageService().storeAllFiles(model);

    if (!context.mounted) return model;
    final homeViewModel = context.read<HomeViewModel>();
    final folderViewModel = context.read<FolderViewModel>();
    await homeViewModel.loadRecentFromStorage();
    await folderViewModel.loadFromStorage();

    return model;
  }

  static bool isScanTextItem(RecentCardItem item) {
    return item.isTextFile &&
        (item.fileType == 'qr' || item.fileType == 'barcode') &&
        item.hasFilePath;
  }

  static Future<void> openSavedScan(
    BuildContext context,
    RecentCardItem item,
  ) async {
    final path = item.path;
    if (path == null || path.isEmpty) return;

    final file = File(path);
    if (!await file.exists()) {
      if (context.mounted) {
        ui.AppToast.show(
          context,
          message: 'File not found',
          backgroundColor: const Color(0xFFE53935),
        );
      }
      return;
    }

    final content = await file.readAsString();
    if (!context.mounted) return;

    final kind = item.fileType == 'barcode'
        ? QrBarcodeScanKind.barcode
        : QrBarcodeScanKind.qrCode;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrBarcodeScanResultScreen(
          kind: kind,
          content: content,
        ),
      ),
    );
  }
}
