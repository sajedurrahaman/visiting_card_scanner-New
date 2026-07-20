import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class BarcodeTemplateItem {
  const BarcodeTemplateItem({
    required this.id,
    required this.thumbnailAsset,
  });

  final String id;
  final String thumbnailAsset;
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
    ),
    BarcodeTemplateItem(
      id: 'barcode2',
      thumbnailAsset: ui.AppAssets.barCodeTwoThumbnail,
    ),
    BarcodeTemplateItem(
      id: 'barcode3',
      thumbnailAsset: ui.AppAssets.barCodeThreeThumbnail,
    ),
    BarcodeTemplateItem(
      id: 'barcode4',
      thumbnailAsset: ui.AppAssets.barCodeFourThumbnail,
    ),
    BarcodeTemplateItem(
      id: 'barcode5',
      thumbnailAsset: ui.AppAssets.barCodeFiveThumbnail,
    ),
    BarcodeTemplateItem(
      id: 'barcode6',
      thumbnailAsset: ui.AppAssets.barCodeSixThumbnail,
    ),
  ];
}
