import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class ContactFieldEntry {
  ContactFieldEntry({
    this.value = '',
    this.type = '',
  });

  String value;
  String type;
}

class VisitingCardEditContactViewModel extends ChangeNotifier {
  VisitingCardEditContactViewModel({
    required this.templateId,
    required this.isHorizontal,
    required this.frontAssetWithoutData,
    required this.backAssetWithoutData,
  });

  factory VisitingCardEditContactViewModel.fromTemplate(
    VisitingCardTemplateItem item, {
    required bool isHorizontal,
  }) {
    return VisitingCardEditContactViewModel(
      templateId: item.id,
      isHorizontal: isHorizontal,
      frontAssetWithoutData: item.frontAssetWithoutData,
      backAssetWithoutData: item.backAssetWithoutData,
    );
  }

  final String templateId;
  final bool isHorizontal;
  final String frontAssetWithoutData;
  final String backAssetWithoutData;

  final ScreenshotController screenshotController = ScreenshotController();

  static const telTypes = [
    'Tel',
    'Fax',
    'Cell',
    'Home',
    'Work',
    'Desk',
    'Others',
  ];
  static const emailWebsiteTypes = ['Company', 'Personal'];

  int sideIndex = 0;
  bool isSaving = false;

  String? qrAssetPath = ui.AppAssets.defaultQrcodeIcon;
  String? logoAssetPath;
  bool hasChosenQr = false;
  bool hasChosenLogo = false;

  final List<ContactFieldEntry> names = [ContactFieldEntry()];
  final List<ContactFieldEntry> designations = [ContactFieldEntry()];
  final List<ContactFieldEntry> companies = [ContactFieldEntry()];
  final List<ContactFieldEntry> taglines = [ContactFieldEntry()];
  final List<ContactFieldEntry> phones = [
    ContactFieldEntry(type: 'Cell'),
  ];
  final List<ContactFieldEntry> emails = [
    ContactFieldEntry(type: 'Company'),
  ];
  final List<ContactFieldEntry> websites = [
    ContactFieldEntry(type: 'Company'),
  ];
  final List<ContactFieldEntry> addresses = [ContactFieldEntry()];

  bool get isFront => sideIndex == 0;
  bool get isBack => sideIndex == 1;

  /// Horizontal 2–5 + vertical 1,2,4,5 have logo on the front.
  bool get hasFrontLogo {
    const frontLogoIds = {'h2', 'h3', 'h4', 'h5', 'v1', 'v2', 'v4', 'v5'};
    return frontLogoIds.contains(templateId);
  }

  /// QR is only placed on the back.
  bool get canEditQr => isBack;

  /// Logo: back always; front only for templates that have front logo.
  bool get canEditLogo => isBack || (isFront && hasFrontLogo);

  String get currentBackgroundAsset =>
      isFront ? frontAssetWithoutData : backAssetWithoutData;

  String get displayName =>
      names.isNotEmpty ? names.first.value.trim() : '';
  String get displayDesignation =>
      designations.isNotEmpty ? designations.first.value.trim() : '';
  String get displayCompany =>
      companies.isNotEmpty ? companies.first.value.trim() : '';
  String get displayTagline =>
      taglines.isNotEmpty ? taglines.first.value.trim() : '';
  String get displayAddress =>
      addresses.isNotEmpty ? addresses.first.value.trim() : '';

  void setSide(int index) {
    if (index < 0 || index > 1 || index == sideIndex) return;
    sideIndex = index;
    notifyListeners();
  }

  void showFront() => setSide(0);
  void showBack() => setSide(1);

  void chooseQrCode() {
    if (!canEditQr) return;
    hasChosenQr = true;
    qrAssetPath = ui.AppAssets.defaultQrcodeIcon;
    notifyListeners();
  }

  void applyQrImage(String path) {
    if (!canEditQr) return;
    hasChosenQr = true;
    qrAssetPath = path;
    notifyListeners();
  }

  void chooseLogo() {
    if (!canEditLogo) return;
    hasChosenLogo = true;
    logoAssetPath = ui.AppAssets.visitingTemplateLocalFileUploadIcon;
    notifyListeners();
  }

  void applyLogoImage(String path) {
    if (!canEditLogo) return;
    hasChosenLogo = true;
    logoAssetPath = path;
    notifyListeners();
  }

  Future<String> persistLogoFile(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final logoDir = Directory('${dir.path}/visiting_card/logo_embed');
    if (!await logoDir.exists()) {
      await logoDir.create(recursive: true);
    }
    final ext = source.path.contains('.')
        ? source.path.split('.').last
        : 'jpg';
    final dest = File(
      '${logoDir.path}/logo_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await source.copy(dest.path);
    return dest.path;
  }

  void updateSimpleField(
    List<ContactFieldEntry> list,
    int index,
    String value,
  ) {
    if (index < 0 || index >= list.length) return;
    list[index].value = value;
    notifyListeners();
  }

  void updateTypedField(
    List<ContactFieldEntry> list,
    int index, {
    String? value,
    String? type,
  }) {
    if (index < 0 || index >= list.length) return;
    if (value != null) list[index].value = value;
    if (type != null) list[index].type = type;
    notifyListeners();
  }

  void clearField(List<ContactFieldEntry> list, int index) {
    if (index < 0 || index >= list.length) return;
    list[index].value = '';
    notifyListeners();
  }

  void addField(
    List<ContactFieldEntry> list, {
    required String defaultType,
  }) {
    list.add(ContactFieldEntry(type: defaultType));
    notifyListeners();
  }

  void removeField(List<ContactFieldEntry> list, int index) {
    if (list.length <= 1) {
      clearField(list, index);
      return;
    }
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    notifyListeners();
  }

  Future<bool> saveCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    required Future<Uint8List?> Function(int side) captureSide,
  }) async {
    if (isSaving) return false;
    isSaving = true;
    notifyListeners();

    final previousSide = sideIndex;

    try {
      final frontBytes = await captureSide(0);
      final backBytes = await captureSide(1);

      sideIndex = previousSide;
      notifyListeners();

      if (frontBytes == null || backBytes == null) {
        isSaving = false;
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final dateLabel = DateFormat('dd-MMM-yyyy HH:mm').format(now);

      final frontPath = await _persistBytes(frontBytes, suffix: 'front');
      final backPath = await _persistBytes(backBytes, suffix: 'back');

      final frontModel = SavedFileModel(
        id: '${now.millisecondsSinceEpoch}_front',
        name: 'Front_Card_$stamp',
        dateTime: dateLabel,
        path: frontPath,
        pathImage: frontPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
      );
      final backModel = SavedFileModel(
        id: '${now.millisecondsSinceEpoch}_back',
        name: 'Back_Card_$stamp',
        dateTime: dateLabel,
        path: backPath,
        pathImage: backPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
      );

      await AppStorageService().storeAllFiles(frontModel);
      await AppStorageService().storeAllFiles(backModel);

      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }
        await Gal.putImage(frontPath, album: 'Visiting Card');
        await Gal.putImage(backPath, album: 'Visiting Card');
      } catch (_) {}

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();

      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      sideIndex = previousSide;
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> _persistBytes(
    Uint8List bytes, {
    String suffix = '',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final cardDir = Directory('${dir.path}/visiting_card');
    if (!await cardDir.exists()) {
      await cardDir.create(recursive: true);
    }
    final name = suffix.isEmpty
        ? 'card_${DateTime.now().millisecondsSinceEpoch}.png'
        : 'card_${DateTime.now().millisecondsSinceEpoch}_$suffix.png';
    final file = File('${cardDir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
