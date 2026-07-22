import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/qr_color_helper.dart';
import 'package:visiting_card/app/helper/qr_style_helper.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/template/presentation/view_model/qrcode_template_viewmodel.dart';

enum QrCustomizeTab { text, template, color, logo, dots, eyes }

enum QrLogoMode { image, text }

class QrCustomizeTemplateOption {
  const QrCustomizeTemplateOption({
    required this.stackTemplateIndex,
    required this.thumbnailAsset,
    this.isNone = false,
  });

  final int stackTemplateIndex;
  final String thumbnailAsset;
  final bool isNone;
}

class QrcodeCustomizeViewModel extends ChangeNotifier {
  QrcodeCustomizeViewModel({
    required String initialQrData,
    required int initialTemplateIndex,
    this.thumbnailAsset,
  })  : qrData = initialQrData,
        templateIndex = initialTemplateIndex;

  final String? thumbnailAsset;
  final ScreenshotController screenshotController = ScreenshotController();

  String qrData;
  int templateIndex;
  QrCustomizeTab? selectedTab;
  QrcodeTemplateCategory templateCategory = QrcodeTemplateCategory.trending;
  QrLogoMode logoMode = QrLogoMode.image;

  bool showForegroundOptions = true;
  Color? foregroundColor;
  Color backgroundColor = Colors.white;
  List<Color> foregroundGradientColors = [];
  List<Color> backgroundGradientColors = [];
  int selectedForegroundGradientIndex = -1;
  int selectedBackgroundGradientIndex = -1;
  String? selectedBackgroundImage;

  int? foregroundSolidSwatchUi;
  int? foregroundGradientSwatchUi;
  int? backgroundSolidSwatchUi;
  int? backgroundGradientSwatchUi;
  int? backgroundImageSwatchUi;

  /// Null = use each template's own default (PDF Scanner pattern).
  QrEyeShape? eyeShape;
  QrDataModuleShape? dotShape;
  double logoSize = 25;
  double logoFontSize = 8;
  Color logoTextColor = Colors.black;
  int? logoSolidSwatchUi = -1;
  String logoText = '';
  String? selectedLogoAsset;
  int? selectedLogoIndex;
  String overlayText = '';
  double overlayFontSize = 16;
  Color overlayTextColor = Colors.black;
  int? overlaySolidSwatchUi = -1;
  int selectedFontStyleIndex = 0;
  int selectedLogoFontStyleIndex = 0;
  bool isSaving = false;

  bool get showOverlayTextField =>
      !(selectedTab == QrCustomizeTab.logo && logoMode == QrLogoMode.image);

  bool get hasLogoAsset => selectedLogoAsset != null && selectedLogoAsset!.isNotEmpty;

  bool get hasLogoText => logoText.trim().isNotEmpty;

  Color get effectiveForegroundColor {
    final color = foregroundColor;
    if (color == null || color == Colors.transparent) {
      return Colors.black;
    }
    return color;
  }

  bool get hasForegroundGradient => foregroundGradientColors.length >= 2;

  bool get hasActiveForegroundGradient =>
      selectedForegroundGradientIndex != -1 && hasForegroundGradient;

  bool get hasBackgroundGradient => backgroundGradientColors.length >= 2;

  bool get hasActiveBackgroundGradient =>
      selectedBackgroundGradientIndex != -1 && hasBackgroundGradient;

  bool get hasCustomBackground =>
      selectedBackgroundImage != null ||
      hasBackgroundGradient ||
      backgroundColor != Colors.white;

  static final fontStyleLabels = List.filled(12, 'fonts');

  static const textColors = [
    Color(0xFF000000),
    Color(0xFF4A4A4A),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF1A237E),
    Color(0xFF6A1B9A),
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFFC62828),
  ];

  List<QrCustomizeTemplateOption> templatesForCategory(
    QrcodeTemplateCategory category,
  ) {
    final indices = switch (category) {
      QrcodeTemplateCategory.trending => const [1, 2, 3, 4, 5, 6],
      QrcodeTemplateCategory.new_ => const [7, 8, 9, 10, 11, 12],
      QrcodeTemplateCategory.social => const [13, 14, 15, 16, 17, 18],
      QrcodeTemplateCategory.wifi => const [19, 20, 21, 22, 23, 24],
      QrcodeTemplateCategory.event => const [25, 26, 27, 28, 29, 30],
      QrcodeTemplateCategory.love => const [31, 32, 33, 34, 35, 36],
    };
    final thumbs = switch (category) {
      QrcodeTemplateCategory.trending => const [
          ui.AppAssets.qrCodeTrendingOneThumbnail,
          ui.AppAssets.qrCodeTrendingTwoThumbnail,
          ui.AppAssets.qrCodeTrendingThreeThumbnail,
          ui.AppAssets.qrCodeTrendingFourThumbnail,
          ui.AppAssets.qrCodeTrendingFiveThumbnail,
          ui.AppAssets.qrCodeTrendingSixThumbnail,
        ],
      QrcodeTemplateCategory.new_ => const [
          ui.AppAssets.qrCodeNewOneThumbnail,
          ui.AppAssets.qrCodeNewTwoThumbnail,
          ui.AppAssets.qrCodeNewThreeThumbnail,
          ui.AppAssets.qrCodeNewFourThumbnail,
          ui.AppAssets.qrCodeNewFiveThumbnail,
          ui.AppAssets.qrCodeNewSixThumbnail,
        ],
      QrcodeTemplateCategory.social => const [
          ui.AppAssets.qrCodeSocialOneThumbnail,
          ui.AppAssets.qrCodeSocialTwoThumbnail,
          ui.AppAssets.qrCodeSocialThreeThumbnail,
          ui.AppAssets.qrCodeSocialFourThumbnail,
          ui.AppAssets.qrCodeSocialFiveThumbnail,
          ui.AppAssets.qrCodeSocialSixThumbnail,
        ],
      QrcodeTemplateCategory.wifi => const [
          ui.AppAssets.qrCodeWifiOneThumbnail,
          ui.AppAssets.qrCodeWifiTwoThumbnail,
          ui.AppAssets.qrCodeWifiThreeThumbnail,
          ui.AppAssets.qrCodeWifiFourThumbnail,
          ui.AppAssets.qrCodeWifiFiveThumbnail,
          ui.AppAssets.qrCodeWifiSixThumbnail,
        ],
      QrcodeTemplateCategory.event => const [
          ui.AppAssets.qrCodeEventOneThumbnail,
          ui.AppAssets.qrCodeEventTwoThumbnail,
          ui.AppAssets.qrCodeEventThreeThumbnail,
          ui.AppAssets.qrCodeEventFourThumbnail,
          ui.AppAssets.qrCodeEventFiveThumbnail,
          ui.AppAssets.qrCodeEventSixThumbnail,
        ],
      QrcodeTemplateCategory.love => const [
          ui.AppAssets.qrCodeLoveOneThumbnail,
          ui.AppAssets.qrCodeLoveTwoThumbnail,
          ui.AppAssets.qrCodeLoveThreeThumbnail,
          ui.AppAssets.qrCodeLoveFourThumbnail,
          ui.AppAssets.qrCodeLoveFiveThumbnail,
          ui.AppAssets.qrCodeLoveSixThumbnail,
        ],
    };

    return [
      const QrCustomizeTemplateOption(
        stackTemplateIndex: 0,
        thumbnailAsset: '',
        isNone: true,
      ),
      for (var i = 0; i < indices.length; i++)
        QrCustomizeTemplateOption(
          stackTemplateIndex: indices[i],
          thumbnailAsset: thumbs[i],
        ),
    ];
  }

  void setTab(QrCustomizeTab tab) {
    selectedTab = tab;
    notifyListeners();
  }

  void setQrData(String value) {
    qrData = value;
    notifyListeners();
  }

  void setOverlayText(String value) {
    overlayText = value;
    notifyListeners();
  }

  void clearOverlayText() {
    overlayText = '';
    notifyListeners();
  }

  void setOverlayFontSize(double value) {
    overlayFontSize = value;
    notifyListeners();
  }

  void setOverlayTextColor(Color color) {
    overlayTextColor = color;
    notifyListeners();
  }

  void selectDefaultOverlayColor() {
    overlaySolidSwatchUi = -1;
    overlayTextColor = Colors.black;
    notifyListeners();
  }

  void selectOverlaySolidColor(int colorIndex) {
    overlaySolidSwatchUi = colorIndex;
    overlayTextColor = textColors[colorIndex];
    notifyListeners();
  }

  void selectCustomOverlayColor(Color color) {
    overlaySolidSwatchUi = -2;
    overlayTextColor = color;
    notifyListeners();
  }

  void setFontStyleIndex(int index) {
    selectedFontStyleIndex = index;
    notifyListeners();
  }

  void setLogoFontStyleIndex(int index) {
    selectedLogoFontStyleIndex = index;
    notifyListeners();
  }

  void setTemplateCategory(QrcodeTemplateCategory category) {
    if (templateCategory == category) return;
    templateCategory = category;
    notifyListeners();
  }

  void selectTemplate(int index) {
    templateIndex = index;
    if (index == 0) {
      resetColorSelections();
    }
    notifyListeners();
  }

  void setLogoMode(QrLogoMode mode) {
    if (logoMode == mode) return;
    logoMode = mode;
    if (mode == QrLogoMode.image) {
      logoText = '';
    } else {
      selectedLogoAsset = null;
      selectedLogoIndex = null;
    }
    notifyListeners();
  }

  void setShowForegroundOptions(bool value) {
    if (showForegroundOptions == value) return;
    showForegroundOptions = value;
    notifyListeners();
  }

  void resetColorSelections() {
    foregroundColor = null;
    backgroundColor = Colors.white;
    foregroundGradientColors = [];
    backgroundGradientColors = [];
    selectedForegroundGradientIndex = -1;
    selectedBackgroundGradientIndex = -1;
    selectedBackgroundImage = null;
    foregroundSolidSwatchUi = null;
    foregroundGradientSwatchUi = null;
    backgroundSolidSwatchUi = null;
    backgroundGradientSwatchUi = null;
    backgroundImageSwatchUi = null;
  }

  void selectDefaultSolid() {
    if (showForegroundOptions) {
      foregroundSolidSwatchUi = -1;
      foregroundGradientSwatchUi = null;
      foregroundColor = null;
      foregroundGradientColors = [];
      selectedForegroundGradientIndex = -1;
    } else {
      backgroundSolidSwatchUi = -1;
      backgroundGradientSwatchUi = null;
      backgroundImageSwatchUi = null;
      backgroundColor = Colors.white;
      selectedBackgroundImage = null;
      backgroundGradientColors = [];
      selectedBackgroundGradientIndex = -1;
    }
    notifyListeners();
  }

  void selectSolidColor(int colorIndex) {
    final color = QrColorHelper.colorOptions[colorIndex];
    if (showForegroundOptions) {
      foregroundSolidSwatchUi = colorIndex;
      foregroundGradientSwatchUi = null;
      foregroundColor = color;
      foregroundGradientColors = [];
      selectedForegroundGradientIndex = -1;
    } else {
      backgroundSolidSwatchUi = colorIndex;
      backgroundGradientSwatchUi = null;
      backgroundImageSwatchUi = null;
      backgroundColor = color;
      selectedBackgroundImage = null;
      backgroundGradientColors = [];
      selectedBackgroundGradientIndex = -1;
    }
    notifyListeners();
  }

  void selectDefaultGradient() {
    if (showForegroundOptions) {
      foregroundSolidSwatchUi = null;
      foregroundGradientSwatchUi = -1;
      foregroundGradientColors = [];
      selectedForegroundGradientIndex = -1;
      foregroundColor = null;
    } else {
      backgroundSolidSwatchUi = null;
      backgroundGradientSwatchUi = -1;
      backgroundImageSwatchUi = null;
      backgroundGradientColors = [];
      selectedBackgroundGradientIndex = -1;
      selectedBackgroundImage = null;
      backgroundColor = Colors.white;
    }
    notifyListeners();
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
      backgroundImageSwatchUi = null;
      backgroundColor = color;
      selectedBackgroundImage = null;
      backgroundGradientColors = [];
      selectedBackgroundGradientIndex = -1;
    }
    notifyListeners();
  }

  void selectGradient(int gradientIndex) {
    final gradient = QrColorHelper.gradientColors[gradientIndex];
    if (showForegroundOptions) {
      foregroundGradientSwatchUi = gradientIndex;
      foregroundSolidSwatchUi = null;
      foregroundGradientColors = List<Color>.from(gradient);
      foregroundColor = Colors.transparent;
      selectedForegroundGradientIndex = gradientIndex;
    } else {
      backgroundGradientSwatchUi = gradientIndex;
      backgroundSolidSwatchUi = null;
      backgroundImageSwatchUi = null;
      backgroundGradientColors = List<Color>.from(gradient);
      backgroundColor = Colors.transparent;
      selectedBackgroundImage = null;
      selectedBackgroundGradientIndex = gradientIndex;
    }
    notifyListeners();
  }

  void selectBackgroundImage(int imageIndex) {
    backgroundImageSwatchUi = imageIndex;
    backgroundSolidSwatchUi = null;
    backgroundGradientSwatchUi = null;
    selectedBackgroundImage = QrColorHelper.backgroundImages[imageIndex];
    backgroundColor = Colors.transparent;
    backgroundGradientColors = [];
    selectedBackgroundGradientIndex = -1;
    notifyListeners();
  }

  void resetBackgroundImage() {
    backgroundImageSwatchUi = -1;
    backgroundSolidSwatchUi = null;
    backgroundGradientSwatchUi = null;
    selectedBackgroundImage = null;
    backgroundColor = Colors.white;
    backgroundGradientColors = [];
    selectedBackgroundGradientIndex = -1;
    notifyListeners();
  }

  void selectDotShape(QrDataModuleShape shape) {
    dotShape = shape;
    notifyListeners();
  }

  void selectEyeShape(QrEyeShape shape) {
    eyeShape = shape;
    notifyListeners();
  }

  void setLogoFontSize(double value) {
    logoFontSize = value.clamp(8, 10).toDouble();
    notifyListeners();
  }

  void setLogoSize(double value) {
    logoSize = value;
    notifyListeners();
  }

  void setLogoTextColor(Color color) {
    logoTextColor = color;
    notifyListeners();
  }

  void selectDefaultLogoColor() {
    logoSolidSwatchUi = -1;
    logoTextColor = Colors.black;
    notifyListeners();
  }

  void selectLogoSolidColor(int colorIndex) {
    logoSolidSwatchUi = colorIndex;
    logoTextColor = QrColorHelper.colorOptions[colorIndex];
    notifyListeners();
  }

  void selectCustomLogoColor(Color color) {
    logoSolidSwatchUi = -2;
    logoTextColor = color;
    notifyListeners();
  }

  void setLogoText(String value) {
    logoText = value;
    if (value.isNotEmpty) {
      selectedLogoAsset = null;
      selectedLogoIndex = null;
    }
    notifyListeners();
  }

  void clearLogoText() {
    logoText = '';
    notifyListeners();
  }

  void clearSelectedLogo() {
    selectedLogoAsset = null;
    selectedLogoIndex = null;
    notifyListeners();
  }

  void selectLogoAsset(int index) {
    selectedLogoIndex = index;
    selectedLogoAsset = QrColorHelper.logoOptions[index];
    logoText = '';
    notifyListeners();
  }

  List<Map<String, dynamic>> get dotOptions => QrStyleHelper.dotStyleOptions;
  List<Map<String, dynamic>> get eyeOptions => QrStyleHelper.eyeShapeOptions;

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
        name: 'QR_${DateFormat('yyyyMMdd_HHmmss').format(now)}',
        dateTime: DateFormat('dd-MMM-yyyy HH:mm').format(now),
        path: path,
        pathImage: path,
        fileType: 'qr',
        folderId: FolderViewModel.qrCodeFolderId,
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
    final qrDir = Directory('${dir.path}/qr_code');
    if (!await qrDir.exists()) {
      await qrDir.create(recursive: true);
    }
    final file = File(
      '${qrDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
