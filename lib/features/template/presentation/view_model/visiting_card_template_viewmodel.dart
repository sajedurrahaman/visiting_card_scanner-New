import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

enum VisitingCardOrientation { horizontal, vertical }

class VisitingCardTemplateItem {
  const VisitingCardTemplateItem({
    required this.id,
    required this.frontAsset,
    required this.backAsset,
    required this.frontAssetWithoutData,
    required this.backAssetWithoutData,
  });

  final String id;
  final String frontAsset;
  final String backAsset;
  final String frontAssetWithoutData;
  final String backAssetWithoutData;
}

class VisitingCardTemplateViewModel extends ChangeNotifier {
  VisitingCardOrientation _orientation = VisitingCardOrientation.horizontal;
  String? _selectedTemplateId;
  final Map<String, int> _sideByTemplateId = {};

  VisitingCardOrientation get orientation => _orientation;
  String? get selectedTemplateId => _selectedTemplateId;

  bool get isHorizontal =>
      _orientation == VisitingCardOrientation.horizontal;

  List<VisitingCardTemplateItem> get templates =>
      isHorizontal ? horizontalTemplates : verticalTemplates;

  int sideFor(String templateId) => _sideByTemplateId[templateId] ?? 0;

  void changeOrientation(VisitingCardOrientation orientation) {
    if (_orientation == orientation) {
      return;
    }
    _orientation = orientation;
    _selectedTemplateId = null;
    _sideByTemplateId.clear();
    notifyListeners();
  }

  void selectTemplate(String id) {
    if (_selectedTemplateId == id) {
      return;
    }
    _selectedTemplateId = id;
    notifyListeners();
  }

  void showFront(String templateId) {
    if (sideFor(templateId) == 0) {
      return;
    }
    _sideByTemplateId[templateId] = 0;
    notifyListeners();
  }

  void showBack(String templateId) {
    if (sideFor(templateId) == 1) {
      return;
    }
    _sideByTemplateId[templateId] = 1;
    notifyListeners();
  }

  static const horizontalTemplates = [
    VisitingCardTemplateItem(
      id: 'h1',
      frontAsset: ui.AppAssets.vTemplateHorizontalOneFront,
      backAsset: ui.AppAssets.vTemplateHorizontalOneBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalOneFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalOneBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h2',
      frontAsset: ui.AppAssets.vTemplateHorizontalTwoFront,
      backAsset: ui.AppAssets.vTemplateHorizontalTwoBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwoFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwoBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h3',
      frontAsset: ui.AppAssets.vTemplateHorizontalThreeFront,
      backAsset: ui.AppAssets.vTemplateHorizontalThreeBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalThreeFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalThreeBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h4',
      frontAsset: ui.AppAssets.vTemplateHorizontalFourFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFourBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalFourFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalFourBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h5',
      frontAsset: ui.AppAssets.vTemplateHorizontalFiveFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFiveBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalFiveFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalFiveBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h6',
      frontAsset: ui.AppAssets.vTemplateHorizontalSixFront,
      backAsset: ui.AppAssets.vTemplateHorizontalSixBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalSixFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalSixBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h7',
      frontAsset: ui.AppAssets.vTemplateHorizontalSevenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalSevenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalSevenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalSevenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h8',
      frontAsset: ui.AppAssets.vTemplateHorizontalEightFront,
      backAsset: ui.AppAssets.vTemplateHorizontalEightBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalEightFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalEightBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h9',
      frontAsset: ui.AppAssets.vTemplateHorizontalNineFront,
      backAsset: ui.AppAssets.vTemplateHorizontalNineBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalNineFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalNineBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h10',
      frontAsset: ui.AppAssets.vTemplateHorizontalTenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalTenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalTenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalTenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h11',
      frontAsset: ui.AppAssets.vTemplateHorizontalElevenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalElevenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalElevenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalElevenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h12',
      frontAsset: ui.AppAssets.vTemplateHorizontalTwelveFront,
      backAsset: ui.AppAssets.vTemplateHorizontalTwelveBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwelveFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwelveBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h13',
      frontAsset: ui.AppAssets.vTemplateHorizontalThirteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalThirteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalThirteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalThirteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h14',
      frontAsset: ui.AppAssets.vTemplateHorizontalFourteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFourteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalFourteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalFourteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h15',
      frontAsset: ui.AppAssets.vTemplateHorizontalFifteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFifteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalFifteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalFifteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h16',
      frontAsset: ui.AppAssets.vTemplateHorizontalSixteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalSixteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalSixteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalSixteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h17',
      frontAsset: ui.AppAssets.vTemplateHorizontalSeventeenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalSeventeenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalSeventeenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalSeventeenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h18',
      frontAsset: ui.AppAssets.vTemplateHorizontalEighteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalEighteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalEighteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalEighteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h19',
      frontAsset: ui.AppAssets.vTemplateHorizontalNineteenFront,
      backAsset: ui.AppAssets.vTemplateHorizontalNineteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalNineteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalNineteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'h20',
      frontAsset: ui.AppAssets.vTemplateHorizontalTwentyFront,
      backAsset: ui.AppAssets.vTemplateHorizontalTwentyBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwentyFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateHorizontalTwentyBackWithOutData,
    ),
  ];

  static const verticalTemplates = [
    VisitingCardTemplateItem(
      id: 'v1',
      frontAsset: ui.AppAssets.vTemplateVerticalOneFront,
      backAsset: ui.AppAssets.vTemplateVerticalOneBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalOneFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalOneBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v2',
      frontAsset: ui.AppAssets.vTemplateVerticalTwoFront,
      backAsset: ui.AppAssets.vTemplateVerticalTwoBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalTwoFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalTwoBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v3',
      frontAsset: ui.AppAssets.vTemplateVerticalThreeFront,
      backAsset: ui.AppAssets.vTemplateVerticalThreeBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalThreeFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalThreeBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v4',
      frontAsset: ui.AppAssets.vTemplateVerticalFourFront,
      backAsset: ui.AppAssets.vTemplateVerticalFourBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalFourFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalFourBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v5',
      frontAsset: ui.AppAssets.vTemplateVerticalFiveFront,
      backAsset: ui.AppAssets.vTemplateVerticalFiveBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalFiveFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalFiveBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v6',
      frontAsset: ui.AppAssets.vTemplateVerticalSixFront,
      backAsset: ui.AppAssets.vTemplateVerticalSixBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalSixFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalSixBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v7',
      frontAsset: ui.AppAssets.vTemplateVerticalSevenFront,
      backAsset: ui.AppAssets.vTemplateVerticalSevenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalSevenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalSevenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v8',
      frontAsset: ui.AppAssets.vTemplateVerticalEightFront,
      backAsset: ui.AppAssets.vTemplateVerticalEightBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalEightFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalEightBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v9',
      frontAsset: ui.AppAssets.vTemplateVerticalNineFront,
      backAsset: ui.AppAssets.vTemplateVerticalNineBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalNineFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalNineBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v10',
      frontAsset: ui.AppAssets.vTemplateVerticalTenFront,
      backAsset: ui.AppAssets.vTemplateVerticalTenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalTenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalTenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v11',
      frontAsset: ui.AppAssets.vTemplateVerticalElevenFront,
      backAsset: ui.AppAssets.vTemplateVerticalElevenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalElevenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalElevenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v12',
      frontAsset: ui.AppAssets.vTemplateVerticalTwelveFront,
      backAsset: ui.AppAssets.vTemplateVerticalTwelveBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalTwelveFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalTwelveBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v13',
      frontAsset: ui.AppAssets.vTemplateVerticalThirteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalThirteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalThirteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalThirteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v14',
      frontAsset: ui.AppAssets.vTemplateVerticalFourteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalFourteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalFourteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalFourteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v15',
      frontAsset: ui.AppAssets.vTemplateVerticalFifteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalFifteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalFifteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalFifteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v16',
      frontAsset: ui.AppAssets.vTemplateVerticalSixteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalSixteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalSixteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalSixteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v17',
      frontAsset: ui.AppAssets.vTemplateVerticalSeventeenFront,
      backAsset: ui.AppAssets.vTemplateVerticalSeventeenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalSeventeenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalSeventeenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v18',
      frontAsset: ui.AppAssets.vTemplateVerticalEighteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalEighteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalEighteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalEighteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v19',
      frontAsset: ui.AppAssets.vTemplateVerticalNineteenFront,
      backAsset: ui.AppAssets.vTemplateVerticalNineteenBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalNineteenFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalNineteenBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v20',
      frontAsset: ui.AppAssets.vTemplateVerticalTwentyFront,
      backAsset: ui.AppAssets.vTemplateVerticalTwentyBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalTwentyFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalTwentyBackWithOutData,
    ),
    VisitingCardTemplateItem(
      id: 'v21',
      frontAsset: ui.AppAssets.vTemplateVerticalTwentyOneFront,
      backAsset: ui.AppAssets.vTemplateVerticalTwentyOneBack,
      frontAssetWithoutData: ui.AppAssets.vTemplateVerticalTwentyOneFrontWithOutData,
      backAssetWithoutData: ui.AppAssets.vTemplateVerticalTwentyOneBackWithOutData,
    ),
  ];
}
