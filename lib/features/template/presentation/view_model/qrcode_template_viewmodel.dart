import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

enum QrcodeTemplateCategory { trending, new_, social, wifi, event, love }

class QrcodeTemplateItem {
  const QrcodeTemplateItem({
    required this.id,
    required this.thumbnailAsset,
    required this.category,
    required this.stackTemplateIndex,
  });

  final String id;
  final String thumbnailAsset;
  final QrcodeTemplateCategory category;
  final int stackTemplateIndex;
}

class QrcodeTemplateViewModel extends ChangeNotifier {
  QrcodeTemplateCategory _selectedCategory = QrcodeTemplateCategory.trending;
  String? _selectedTemplateId;

  QrcodeTemplateCategory get selectedCategory => _selectedCategory;
  String? get selectedTemplateId => _selectedTemplateId;

  List<QrcodeTemplateItem> get templates => _allTemplates
      .where((item) => item.category == _selectedCategory)
      .toList();

  void changeCategory(QrcodeTemplateCategory category) {
    if (_selectedCategory == category) {
      return;
    }
    _selectedCategory = category;
    _selectedTemplateId = null;
    notifyListeners();
  }

  void selectTemplate(String id) {
    if (_selectedTemplateId == id) {
      return;
    }
    _selectedTemplateId = id;
    notifyListeners();
  }

  static const categories = [
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.trending,
      icon: ui.AppAssets.qrCodeTrendingIcon,
      label: 'Trending',
    ),
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.new_,
      icon: ui.AppAssets.qrCodeNewIcon,
      label: 'New',
    ),
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.social,
      icon: ui.AppAssets.qrCodeSocialIcon,
      label: 'Social',
    ),
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.wifi,
      icon: ui.AppAssets.qrCodeWifiIcon,
      label: 'WIFI',
    ),
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.event,
      icon: ui.AppAssets.qrCodeEventIcon,
      label: 'Event',
    ),
    QrcodeCategoryData(
      category: QrcodeTemplateCategory.love,
      icon: ui.AppAssets.qrCodeLoveIcon,
      label: 'Love',
    ),
  ];

  static const _allTemplates = [
    // trending: [1,2,3,4,5,6]
    QrcodeTemplateItem(
      id: 'qr1',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingOneThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 1,
    ),
    QrcodeTemplateItem(
      id: 'qr2',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingTwoThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 2,
    ),
    QrcodeTemplateItem(
      id: 'qr3',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingThreeThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 3,
    ),
    QrcodeTemplateItem(
      id: 'qr4',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingFourThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 4,
    ),
    QrcodeTemplateItem(
      id: 'qr5',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingFiveThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 5,
    ),
    QrcodeTemplateItem(
      id: 'qr6',
      thumbnailAsset: ui.AppAssets.qrCodeTrendingSixThumbnail,
      category: QrcodeTemplateCategory.trending,
      stackTemplateIndex: 6,
    ),
    // new: [7,8,9,10,11,12]
    QrcodeTemplateItem(
      id: 'qr7',
      thumbnailAsset: ui.AppAssets.qrCodeNewOneThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 7,
    ),
    QrcodeTemplateItem(
      id: 'qr8',
      thumbnailAsset: ui.AppAssets.qrCodeNewTwoThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 8,
    ),
    QrcodeTemplateItem(
      id: 'qr9',
      thumbnailAsset: ui.AppAssets.qrCodeNewThreeThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 9,
    ),
    QrcodeTemplateItem(
      id: 'qr10',
      thumbnailAsset: ui.AppAssets.qrCodeNewFourThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 10,
    ),
    QrcodeTemplateItem(
      id: 'qr11',
      thumbnailAsset: ui.AppAssets.qrCodeNewFiveThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 11,
    ),
    QrcodeTemplateItem(
      id: 'qr12',
      thumbnailAsset: ui.AppAssets.qrCodeNewSixThumbnail,
      category: QrcodeTemplateCategory.new_,
      stackTemplateIndex: 12,
    ),
    // social: [13,14,15,16,17,18]
    QrcodeTemplateItem(
      id: 'qr13',
      thumbnailAsset: ui.AppAssets.qrCodeSocialOneThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 13,
    ),
    QrcodeTemplateItem(
      id: 'qr14',
      thumbnailAsset: ui.AppAssets.qrCodeSocialTwoThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 14,
    ),
    QrcodeTemplateItem(
      id: 'qr15',
      thumbnailAsset: ui.AppAssets.qrCodeSocialThreeThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 15,
    ),
    QrcodeTemplateItem(
      id: 'qr16',
      thumbnailAsset: ui.AppAssets.qrCodeSocialFourThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 16,
    ),
    QrcodeTemplateItem(
      id: 'qr17',
      thumbnailAsset: ui.AppAssets.qrCodeSocialFiveThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 17,
    ),
    QrcodeTemplateItem(
      id: 'qr18',
      thumbnailAsset: ui.AppAssets.qrCodeSocialSixThumbnail,
      category: QrcodeTemplateCategory.social,
      stackTemplateIndex: 18,
    ),
    // wifi: [19,20,21,22,23,24]
    QrcodeTemplateItem(
      id: 'qr19',
      thumbnailAsset: ui.AppAssets.qrCodeWifiOneThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 19,
    ),
    QrcodeTemplateItem(
      id: 'qr20',
      thumbnailAsset: ui.AppAssets.qrCodeWifiTwoThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 20,
    ),
    QrcodeTemplateItem(
      id: 'qr21',
      thumbnailAsset: ui.AppAssets.qrCodeWifiThreeThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 21,
    ),
    QrcodeTemplateItem(
      id: 'qr22',
      thumbnailAsset: ui.AppAssets.qrCodeWifiFourThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 22,
    ),
    QrcodeTemplateItem(
      id: 'qr23',
      thumbnailAsset: ui.AppAssets.qrCodeWifiFiveThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 23,
    ),
    QrcodeTemplateItem(
      id: 'qr24',
      thumbnailAsset: ui.AppAssets.qrCodeWifiSixThumbnail,
      category: QrcodeTemplateCategory.wifi,
      stackTemplateIndex: 24,
    ),
    // event: [25,26,27,28,29,30]
    QrcodeTemplateItem(
      id: 'qr25',
      thumbnailAsset: ui.AppAssets.qrCodeEventOneThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 25,
    ),
    QrcodeTemplateItem(
      id: 'qr26',
      thumbnailAsset: ui.AppAssets.qrCodeEventTwoThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 26,
    ),
    QrcodeTemplateItem(
      id: 'qr27',
      thumbnailAsset: ui.AppAssets.qrCodeEventThreeThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 27,
    ),
    QrcodeTemplateItem(
      id: 'qr28',
      thumbnailAsset: ui.AppAssets.qrCodeEventFourThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 28,
    ),
    QrcodeTemplateItem(
      id: 'qr29',
      thumbnailAsset: ui.AppAssets.qrCodeEventFiveThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 29,
    ),
    QrcodeTemplateItem(
      id: 'qr30',
      thumbnailAsset: ui.AppAssets.qrCodeEventSixThumbnail,
      category: QrcodeTemplateCategory.event,
      stackTemplateIndex: 30,
    ),
    // love: [31,32,33,34,35,36]
    QrcodeTemplateItem(
      id: 'qr31',
      thumbnailAsset: ui.AppAssets.qrCodeLoveOneThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 31,
    ),
    QrcodeTemplateItem(
      id: 'qr32',
      thumbnailAsset: ui.AppAssets.qrCodeLoveTwoThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 32,
    ),
    QrcodeTemplateItem(
      id: 'qr33',
      thumbnailAsset: ui.AppAssets.qrCodeLoveThreeThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 33,
    ),
    QrcodeTemplateItem(
      id: 'qr34',
      thumbnailAsset: ui.AppAssets.qrCodeLoveFourThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 34,
    ),
    QrcodeTemplateItem(
      id: 'qr35',
      thumbnailAsset: ui.AppAssets.qrCodeLoveFiveThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 35,
    ),
    QrcodeTemplateItem(
      id: 'qr36',
      thumbnailAsset: ui.AppAssets.qrCodeLoveSixThumbnail,
      category: QrcodeTemplateCategory.love,
      stackTemplateIndex: 36,
    ),
  ];
}

class QrcodeCategoryData {
  const QrcodeCategoryData({
    required this.category,
    required this.icon,
    required this.label,
  });

  final QrcodeTemplateCategory category;
  final String icon;
  final String label;
}
