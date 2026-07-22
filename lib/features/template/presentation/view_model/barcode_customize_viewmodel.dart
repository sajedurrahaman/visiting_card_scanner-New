import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/qr_color_helper.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/template/domain/app_barcode_type.dart';

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
    required String typeLabel,
    this.thumbnailAsset,
  })  : barcodeData = initialBarcodeData,
        templateIndex = initialTemplateIndex,
        typeLabel = typeLabel,
        barcodeType = AppBarcodeTypeX.fromLabel(typeLabel),
        headingText = typeLabel;

  final String typeLabel;
  final String? thumbnailAsset;
  final ScreenshotController screenshotController = ScreenshotController();

  final AppBarcodeType barcodeType;
  String barcodeData;
  int templateIndex;
  BarcodeCustomizeTab? selectedTab;

  bool isBarCodeDetails = true;
  bool showHeading = true;
  bool showDetails = true;

  String headingText;
  double headingFontSize = 20;
  double detailsFontSize = 16;
  Color headingColor = Colors.black;
  Color detailsColor = Colors.black;

  bool showForegroundOptions = true;
  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.transparent;
  bool hasExplicitBackground = false;
  List<Color> foregroundGradientColors = [];
  List<Color> backgroundGradientColors = [];
  int selectedForegroundGradientIndex = -1;
  int selectedBackgroundGradientIndex = -1;
  int? foregroundSolidSwatchUi = -1;
  int? foregroundGradientSwatchUi;
  int? backgroundSolidSwatchUi = -1;
  int? backgroundGradientSwatchUi;

  double barcodeHeight = 150;
  double pdf417Height = 7;
  bool isSaving = false;

  bool get isPdf417 => barcodeType == AppBarcodeType.pdf417;
  bool get isTemplateUsed => templateIndex > 0;
  bool get hasForegroundGradient => foregroundGradientColors.length >= 2;
  bool get hasActiveForegroundGradient =>
      selectedForegroundGradientIndex != -1 && hasForegroundGradient;
  bool get hasBackgroundGradient => backgroundGradientColors.length >= 2;
  bool get hasActiveBackgroundGradient =>
      selectedBackgroundGradientIndex != -1 && hasBackgroundGradient;
  String get displayHeading =>
      headingText.trim().isNotEmpty ? headingText.trim() : typeLabel;

  static const textColors = [
    Color(0xFF000000),
    Color(0xFF4A4A4A),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFFFB8C00),
    Color(0xFF00ACC1),
    Color(0xFFD81B60),
  ];

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

  void setTab(BarcodeCustomizeTab tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void selectDefaultSolid() {
    if (showForegroundOptions) {
      selectDefaultForeground();
    } else {
      selectDefaultBackground();
    }
  }

  void selectSolidColor(int colorIndex) {
    if (showForegroundOptions) {
      selectForegroundSolid(colorIndex);
    } else {
      selectBackgroundSolid(colorIndex);
    }
  }

  void selectCustomSolidColor(Color color) {
    if (showForegroundOptions) {
      foregroundSolidSwatchUi = -2;
      foregroundGradientSwatchUi = null;
      foregroundColor = color;
      foregroundGradientColors = [];
      selectedForegroundGradientIndex = -1;
    } else {
      backgroundSolidSwatchUi = -2;
      backgroundGradientSwatchUi = null;
      backgroundColor = color;
      hasExplicitBackground = true;
      backgroundGradientColors = [];
      selectedBackgroundGradientIndex = -1;
    }
    notifyListeners();
  }

  void selectDefaultGradient() {
    if (showForegroundOptions) {
      clearForegroundGradient();
      foregroundSolidSwatchUi = null;
      foregroundColor = Colors.black;
    } else {
      clearBackgroundGradient();
      backgroundSolidSwatchUi = null;
      backgroundColor = Colors.transparent;
      hasExplicitBackground = false;
    }
    notifyListeners();
  }

  void selectGradient(int gradientIndex) {
    if (showForegroundOptions) {
      selectForegroundGradient(gradientIndex);
    } else {
      selectBackgroundGradient(gradientIndex);
    }
  }

  void setIsBarCodeDetails(bool value) {
    if (isBarCodeDetails == value) return;
    isBarCodeDetails = value;
    notifyListeners();
  }

  void setBarcodeData(String value) {
    barcodeData = value;
    notifyListeners();
  }

  void setHeadingText(String value) {
    headingText = value;
    notifyListeners();
  }

  void setShowHeading(bool value) {
    showHeading = value;
    notifyListeners();
  }

  void setShowDetails(bool value) {
    showDetails = value;
    notifyListeners();
  }

  void setHeadingFontSize(double value) {
    headingFontSize = value;
    notifyListeners();
  }

  void setDetailsFontSize(double value) {
    detailsFontSize = value;
    notifyListeners();
  }

  void setHeadingColor(Color color) {
    headingColor = color;
    notifyListeners();
  }

  void setDetailsColor(Color color) {
    detailsColor = color;
    notifyListeners();
  }

  void selectTemplate(int index) {
    templateIndex = index;
    if (index == 0) {
      resetColors();
    }
    notifyListeners();
  }

  void resetColors() {
    foregroundColor = Colors.black;
    backgroundColor = Colors.transparent;
    hasExplicitBackground = false;
    foregroundGradientColors = [];
    backgroundGradientColors = [];
    selectedForegroundGradientIndex = -1;
    selectedBackgroundGradientIndex = -1;
    foregroundSolidSwatchUi = -1;
    foregroundGradientSwatchUi = null;
    backgroundSolidSwatchUi = -1;
    backgroundGradientSwatchUi = null;
  }

  void setShowForegroundOptions(bool value) {
    if (showForegroundOptions == value) return;
    showForegroundOptions = value;
    notifyListeners();
  }

  void selectDefaultForeground() {
    foregroundSolidSwatchUi = -1;
    foregroundGradientSwatchUi = null;
    foregroundColor = Colors.black;
    foregroundGradientColors = [];
    selectedForegroundGradientIndex = -1;
    notifyListeners();
  }

  void selectDefaultBackground() {
    backgroundSolidSwatchUi = -1;
    backgroundGradientSwatchUi = null;
    backgroundColor = Colors.transparent;
    hasExplicitBackground = false;
    backgroundGradientColors = [];
    selectedBackgroundGradientIndex = -1;
    notifyListeners();
  }

  void selectForegroundSolid(int index) {
    foregroundSolidSwatchUi = index;
    foregroundGradientSwatchUi = null;
    foregroundColor = QrColorHelper.colorOptions[index];
    foregroundGradientColors = [];
    selectedForegroundGradientIndex = -1;
    notifyListeners();
  }

  void selectBackgroundSolid(int index) {
    backgroundSolidSwatchUi = index;
    backgroundGradientSwatchUi = null;
    backgroundColor = QrColorHelper.colorOptions[index];
    hasExplicitBackground = true;
    backgroundGradientColors = [];
    selectedBackgroundGradientIndex = -1;
    notifyListeners();
  }

  void selectForegroundGradient(int index) {
    foregroundGradientSwatchUi = index;
    foregroundSolidSwatchUi = null;
    foregroundGradientColors = List<Color>.from(QrColorHelper.gradientColors[index]);
    selectedForegroundGradientIndex = index;
    foregroundColor = Colors.black;
    notifyListeners();
  }

  void selectBackgroundGradient(int index) {
    backgroundGradientSwatchUi = index;
    backgroundSolidSwatchUi = null;
    backgroundGradientColors = List<Color>.from(QrColorHelper.gradientColors[index]);
    hasExplicitBackground = true;
    backgroundColor = Colors.transparent;
    selectedBackgroundGradientIndex = index;
    notifyListeners();
  }

  void clearForegroundGradient() {
    foregroundGradientSwatchUi = -1;
    foregroundGradientColors = [];
    selectedForegroundGradientIndex = -1;
    notifyListeners();
  }

  void clearBackgroundGradient() {
    backgroundGradientSwatchUi = -1;
    backgroundGradientColors = [];
    selectedBackgroundGradientIndex = -1;
    notifyListeners();
  }

  void setBarcodeHeight(double value) {
    barcodeHeight = value;
    notifyListeners();
  }

  void setPdf417Height(double value) {
    pdf417Height = value;
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
        isTextFile: false,
      );

      await AppStorageService().storeAllFiles(model);

      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }
        await Gal.putImage(path, album: 'Visiting Card');
      } catch (_) {}

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
