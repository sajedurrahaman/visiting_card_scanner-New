import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';

enum BarcodeCustomizeTab { text, template, color, height }

class BarcodeCustomizeTemplateOption {
  const BarcodeCustomizeTemplateOption({
    required this.stackTemplateIndex,
    required this.thumbnailAsset,
  });

  final int stackTemplateIndex;
  final String thumbnailAsset;
}

class BarcodeCustomizeViewModel extends ChangeNotifier {
  BarcodeCustomizeViewModel({
    required String initialBarcodeData,
    required int initialTemplateIndex,
    this.thumbnailAsset,
  })  : barcodeData = initialBarcodeData,
        templateIndex = initialTemplateIndex;

  final String? thumbnailAsset;
  final ScreenshotController screenshotController = ScreenshotController();

  String barcodeData;
  int templateIndex;
  BarcodeCustomizeTab selectedTab = BarcodeCustomizeTab.text;
  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;
  double barcodeHeight = 70;
  bool isSaving = false;

  static const templateOptions = [
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 1,
      thumbnailAsset: ui.AppAssets.barCodeOneThumbnail,
    ),
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 3,
      thumbnailAsset: ui.AppAssets.barCodeTwoThumbnail,
    ),
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 5,
      thumbnailAsset: ui.AppAssets.barCodeThreeThumbnail,
    ),
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 21,
      thumbnailAsset: ui.AppAssets.barCodeFourThumbnail,
    ),
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 10,
      thumbnailAsset: ui.AppAssets.barCodeFiveThumbnail,
    ),
    BarcodeCustomizeTemplateOption(
      stackTemplateIndex: 12,
      thumbnailAsset: ui.AppAssets.barCodeSixThumbnail,
    ),
  ];

  static const solidColors = [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF2076FD),
    Color(0xFF05B560),
    Color(0xFFF50302),
    Color(0xFFE31AFF),
    Color(0xFFCF6400),
    Color(0xFF6CC400),
  ];

  void setTab(BarcodeCustomizeTab tab) {
    if (selectedTab == tab) return;
    selectedTab = tab;
    notifyListeners();
  }

  void setBarcodeData(String value) {
    barcodeData = value;
    notifyListeners();
  }

  void selectTemplate(int index) {
    templateIndex = index;
    notifyListeners();
  }

  void selectColor(Color color) {
    foregroundColor = color;
    notifyListeners();
  }

  void setBarcodeHeight(double value) {
    barcodeHeight = value;
    notifyListeners();
  }

  Future<bool> saveToGallery({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
  }) async {
    if (isSaving) return false;
    isSaving = true;
    notifyListeners();

    try {
      final bytes = await screenshotController.capture(pixelRatio: 3);
      if (bytes == null) {
        isSaving = false;
        notifyListeners();
        return false;
      }

      final path = await _persistBytes(bytes);
      final now = DateTime.now();
      final model = SavedFileModel(
        id: now.millisecondsSinceEpoch.toString(),
        name: 'Barcode_${DateFormat('yyyyMMdd_HHmmss').format(now)}',
        dateTime: DateFormat('dd-MMM-yyyy HH:mm').format(now),
        path: path,
        pathImage: path,
        fileType: 'barcode',
        folderId: FolderViewModel.barcodeFolderId,
        isTextFile: true,
      );

      await AppStorageService().storeAllFiles(model);
      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();

      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> _persistBytes(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final barcodeDir = Directory('${dir.path}/barcode');
    if (!await barcodeDir.exists()) {
      await barcodeDir.create(recursive: true);
    }
    final file = File(
      '${barcodeDir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
