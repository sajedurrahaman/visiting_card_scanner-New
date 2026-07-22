import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class BarcodeTemplateItem {
  const BarcodeTemplateItem({
    required this.id,
    required this.thumbnailAsset,
    required this.stackTemplateIndex,
  });

  final String id;
  final String thumbnailAsset;
  final int stackTemplateIndex;
}

class BarcodeTemplateViewModel extends ChangeNotifier {
  String? _selectedTemplateId;

  String? get selectedTemplateId => _selectedTemplateId;

  List<BarcodeTemplateItem> get templates => _templates;

  void selectTemplate(String id) {
    if (_selectedTemplateId == id) {
      return;
    }
    _selectedTemplateId = id;
    notifyListeners();
  }

  static const _templates = [
    BarcodeTemplateItem(
      id: 'barcode1',
      thumbnailAsset: ui.AppAssets.barCodeOneThumbnail,
      stackTemplateIndex: 1,
    ),
    BarcodeTemplateItem(
      id: 'barcode2',
      thumbnailAsset: ui.AppAssets.barCodeTwoThumbnail,
      stackTemplateIndex: 3,
    ),
    BarcodeTemplateItem(
      id: 'barcode3',
      thumbnailAsset: ui.AppAssets.barCodeThreeThumbnail,
      stackTemplateIndex: 5,
    ),
    BarcodeTemplateItem(
      id: 'barcode4',
      thumbnailAsset: ui.AppAssets.barCodeFourThumbnail,
      stackTemplateIndex: 21,
    ),
    BarcodeTemplateItem(
      id: 'barcode5',
      thumbnailAsset: ui.AppAssets.barCodeFiveThumbnail,
      stackTemplateIndex: 10,
    ),
    BarcodeTemplateItem(
      id: 'barcode6',
      thumbnailAsset: ui.AppAssets.barCodeSixThumbnail,
      stackTemplateIndex: 12,
    ),
  ];
}
