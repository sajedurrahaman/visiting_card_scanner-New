import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

enum VisitingCardOrientation { horizontal, vertical }

class VisitingCardTemplateItem {
  const VisitingCardTemplateItem({
    required this.id,
    required this.frontAsset,
    required this.backAsset,
  });

  final String id;
  final String frontAsset;
  final String backAsset;
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
      isHorizontal ? _horizontalTemplates : _verticalTemplates;

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

  static const _horizontalTemplates = [
    VisitingCardTemplateItem(
      id: 'h1',
      frontAsset: ui.AppAssets.vTemplateHorizontalOneFront,
      backAsset: ui.AppAssets.vTemplateHorizontalOneBack,
    ),
    VisitingCardTemplateItem(
      id: 'h2',
      frontAsset: ui.AppAssets.vTemplateHorizontalTwoFront,
      backAsset: ui.AppAssets.vTemplateHorizontalTwoBack,
    ),
    VisitingCardTemplateItem(
      id: 'h3',
      frontAsset: ui.AppAssets.vTemplateHorizontalThreeFront,
      backAsset: ui.AppAssets.vTemplateHorizontalThreeBack,
    ),
    VisitingCardTemplateItem(
      id: 'h4',
      frontAsset: ui.AppAssets.vTemplateHorizontalFourFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFourBack,
    ),
    VisitingCardTemplateItem(
      id: 'h5',
      frontAsset: ui.AppAssets.vTemplateHorizontalFiveFront,
      backAsset: ui.AppAssets.vTemplateHorizontalFiveBack,
    ),
  ];

  static const _verticalTemplates = [
    VisitingCardTemplateItem(
      id: 'v1',
      frontAsset: ui.AppAssets.vTemplateVerticalOneFront,
      backAsset: ui.AppAssets.vTemplateVerticalOneBack,
    ),
    VisitingCardTemplateItem(
      id: 'v2',
      frontAsset: ui.AppAssets.vTemplateVerticalTwoFront,
      backAsset: ui.AppAssets.vTemplateVerticalTwoBack,
    ),
    VisitingCardTemplateItem(
      id: 'v3',
      frontAsset: ui.AppAssets.vTemplateVerticalThreeFront,
      backAsset: ui.AppAssets.vTemplateVerticalThreeBack,
    ),
    VisitingCardTemplateItem(
      id: 'v4',
      frontAsset: ui.AppAssets.vTemplateVerticalFourFront,
      backAsset: ui.AppAssets.vTemplateVerticalFourBack,
    ),
    VisitingCardTemplateItem(
      id: 'v5',
      frontAsset: ui.AppAssets.vTemplateVerticalFiveFront,
      backAsset: ui.AppAssets.vTemplateVerticalFiveBack,
    ),
  ];
}
