import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
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

  /// Copy editable contact fields from scanner / another edit VM.
  void applyContactFrom(VisitingCardEditContactViewModel other) {
    _replaceEntries(names, other.names);
    _replaceEntries(designations, other.designations);
    _replaceEntries(companies, other.companies);
    _replaceEntries(taglines, other.taglines);
    _replaceEntries(phones, other.phones, fallbackType: 'Cell');
    _replaceEntries(emails, other.emails, fallbackType: 'Company');
    _replaceEntries(websites, other.websites, fallbackType: 'Company');
    _replaceEntries(addresses, other.addresses);
    qrAssetPath = other.qrAssetPath;
    logoAssetPath = other.logoAssetPath;
    hasChosenQr = other.hasChosenQr;
    hasChosenLogo = other.hasChosenLogo;
    notifyListeners();
  }

  void applyContactLists({
    required List<ContactFieldEntry> names,
    required List<ContactFieldEntry> designations,
    required List<ContactFieldEntry> companies,
    required List<ContactFieldEntry> phones,
    required List<ContactFieldEntry> emails,
    required List<ContactFieldEntry> websites,
    required List<ContactFieldEntry> addresses,
    List<ContactFieldEntry>? taglines,
  }) {
    _replaceEntries(this.names, names);
    _replaceEntries(this.designations, designations);
    _replaceEntries(this.companies, companies);
    _replaceEntries(this.taglines, taglines ?? const []);
    _replaceEntries(this.phones, phones, fallbackType: 'Cell');
    _replaceEntries(this.emails, emails, fallbackType: 'Company');
    _replaceEntries(this.websites, websites, fallbackType: 'Company');
    _replaceEntries(this.addresses, addresses);
    notifyListeners();
  }

  void _replaceEntries(
    List<ContactFieldEntry> target,
    List<ContactFieldEntry> source, {
    String fallbackType = '',
  }) {
    target
      ..clear()
      ..addAll(
        source.map(
          (e) => ContactFieldEntry(value: e.value, type: e.type),
        ),
      );
    if (target.isEmpty) {
      target.add(ContactFieldEntry(type: fallbackType));
    }
  }

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

  /// Same shape as scanner [SavedContactInfo] for share / phone contacts.
  SavedContactInfo buildSavedContact({List<String> imagePaths = const []}) {
    return SavedContactInfo(
      name: names.first.value.trim(),
      designation: designations.first.value.trim(),
      company: companies.first.value.trim(),
      phones: phones
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      emails: emails
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      websites: websites
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      addresses: addresses
          .map((e) => e.value.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      imagePaths: imagePaths,
    );
  }

  /// Scanner visiting-card save: one contact folder + details → Recent + Folder.
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

      final contactName = names.first.value.trim().isNotEmpty
          ? names.first.value.trim()
          : 'Visiting Card';
      final safeFolderName = _safeFolderName('${contactName}_$stamp');

      final docs = await getApplicationDocumentsDirectory();
      final contactFolder = Directory(
        p.join(
          docs.path,
          'Convert Document',
          'Visiting Card',
          safeFolderName,
        ),
      );
      await contactFolder.create(recursive: true);

      final frontPath = p.join(contactFolder.path, 'card_front.jpg');
      final backPath = p.join(contactFolder.path, 'card_back.jpg');
      await File(frontPath).writeAsBytes(_toJpeg(frontBytes), flush: true);
      await File(backPath).writeAsBytes(_toJpeg(backBytes), flush: true);

      final imagePaths = [frontPath, backPath];
      final contact = buildSavedContact(imagePaths: imagePaths);
      await SavedContactInfo.writeToFolder(contactFolder.path, contact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText());

      final displayName =
          contact.name.isNotEmpty ? contact.name : 'Visiting Card';
      final model = SavedFileModel(
        id: '${now.millisecondsSinceEpoch}',
        name: displayName,
        dateTime: dateLabel,
        path: contactFolder.path,
        pathImage: frontPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
      );
      await AppStorageService().storeAllFiles(model);

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

  Uint8List _toJpeg(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
  }

  String _safeFolderName(String raw) {
    return raw
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  String _contactDetailsText() {
    final buffer = StringBuffer();
    void addLine(String label, String value) {
      final v = value.trim();
      if (v.isEmpty) return;
      buffer.writeln('$label: $v');
    }

    addLine('Name', names.first.value);
    addLine('Designation', designations.first.value);
    addLine('Company', companies.first.value);
    for (final phone in phones) {
      if (phone.value.trim().isNotEmpty) {
        buffer.writeln('${phone.type}: ${phone.value.trim()}');
      }
    }
    for (final email in emails) {
      if (email.value.trim().isNotEmpty) {
        buffer.writeln('Email (${email.type}): ${email.value.trim()}');
      }
    }
    for (final web in websites) {
      if (web.value.trim().isNotEmpty) {
        buffer.writeln('Website (${web.type}): ${web.value.trim()}');
      }
    }
    for (final address in addresses) {
      if (address.value.trim().isNotEmpty) {
        buffer.writeln('Address: ${address.value.trim()}');
      }
    }
    return buffer.isEmpty
        ? 'Visiting card contact (exported)'
        : buffer.toString();
  }
}
