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

  /// When editing an existing saved template card (details → Edit).
  String? editingSavedFileId;
  String? editingContactFolderPath;
  String? editingFolderId;
  String? editingDateTime;

  bool get isUpdatingExisting =>
      editingSavedFileId != null &&
      editingContactFolderPath != null &&
      editingContactFolderPath!.isNotEmpty;

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
    String? qrAssetPath,
    String? logoAssetPath,
    bool? hasChosenQr,
    bool? hasChosenLogo,
  }) {
    _replaceEntries(this.names, names);
    _replaceEntries(this.designations, designations);
    _replaceEntries(this.companies, companies);
    _replaceEntries(this.taglines, taglines ?? const []);
    _replaceEntries(this.phones, phones, fallbackType: 'Cell');
    _replaceEntries(this.emails, emails, fallbackType: 'Company');
    _replaceEntries(this.websites, websites, fallbackType: 'Company');
    _replaceEntries(this.addresses, addresses);
    if (qrAssetPath != null) {
      this.qrAssetPath = qrAssetPath.isEmpty ? null : qrAssetPath;
      this.hasChosenQr = hasChosenQr ?? qrAssetPath.isNotEmpty;
    } else if (hasChosenQr != null) {
      this.hasChosenQr = hasChosenQr;
    }
    if (logoAssetPath != null) {
      this.logoAssetPath = logoAssetPath.isEmpty ? null : logoAssetPath;
      this.hasChosenLogo = hasChosenLogo ?? logoAssetPath.isNotEmpty;
    } else if (hasChosenLogo != null) {
      this.hasChosenLogo = hasChosenLogo;
    }
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

  void applyContactFromSaved(
    SavedContactInfo contact, {
    String? savedFileId,
    String? contactFolderPath,
    String? folderId,
    String? dateTime,
  }) {
    editingSavedFileId = savedFileId;
    editingContactFolderPath = contactFolderPath;
    editingFolderId = folderId;
    editingDateTime = dateTime;

    _replaceEntries(names, [ContactFieldEntry(value: contact.name)]);
    _replaceEntries(
      designations,
      [ContactFieldEntry(value: contact.designation)],
    );
    _replaceEntries(companies, [ContactFieldEntry(value: contact.company)]);
    _replaceEntries(taglines, [ContactFieldEntry(value: contact.tagline)]);
    _replaceEntries(
      phones,
      contact.phones.isEmpty
          ? [ContactFieldEntry(type: 'Cell')]
          : contact.phones
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Cell',
    );
    _replaceEntries(
      emails,
      contact.emails.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.emails
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Company',
    );
    _replaceEntries(
      websites,
      contact.websites.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.websites
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      fallbackType: 'Company',
    );
    _replaceEntries(
      addresses,
      contact.addresses.isEmpty
          ? [ContactFieldEntry()]
          : contact.addresses.map((e) => ContactFieldEntry(value: e)).toList(),
    );

    hasChosenQr = contact.hasChosenQr;
    hasChosenLogo = contact.hasChosenLogo;
    qrAssetPath = contact.qrImagePath.isNotEmpty
        ? contact.qrImagePath
        : (hasChosenQr ? ui.AppAssets.defaultQrcodeIcon : qrAssetPath);
    logoAssetPath =
        contact.logoImagePath.isNotEmpty ? contact.logoImagePath : null;
    notifyListeners();
  }

  void clearEditingState() {
    editingSavedFileId = null;
    editingContactFolderPath = null;
    editingFolderId = null;
    editingDateTime = null;
  }

  /// Same shape as scanner [SavedContactInfo] for share / phone contacts.
  SavedContactInfo buildSavedContact({List<String> imagePaths = const []}) {
    return SavedContactInfo(
      name: names.first.value.trim(),
      designation: designations.first.value.trim(),
      company: companies.first.value.trim(),
      tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
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
      source: SavedContactInfo.sourceTemplate,
      templateId: templateId,
      qrImagePath: qrAssetPath ?? '',
      logoImagePath: logoAssetPath ?? '',
      hasChosenQr: hasChosenQr,
      hasChosenLogo: hasChosenLogo,
    );
  }

  /// Scanner visiting-card save: one contact folder + details → Recent + Folder.
  Future<bool> saveCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    required Future<Uint8List?> Function(int side) captureSide,
  }) async {
    if (isUpdatingExisting) {
      return updateCard(
        homeViewModel: homeViewModel,
        folderViewModel: folderViewModel,
        captureSide: captureSide,
      );
    }

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

      final embedded = await _persistEmbeddedAssets(contactFolder);
      final frontPath = p.join(contactFolder.path, 'card_front.jpg');
      final backPath = p.join(contactFolder.path, 'card_back.jpg');
      await File(frontPath).writeAsBytes(_toJpeg(frontBytes), flush: true);
      await File(backPath).writeAsBytes(_toJpeg(backBytes), flush: true);

      final imagePaths = [frontPath, backPath];
      final savedContact = SavedContactInfo(
        name: names.first.value.trim(),
        designation: designations.first.value.trim(),
        company: companies.first.value.trim(),
        tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
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
        source: SavedContactInfo.sourceTemplate,
        templateId: templateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        hasChosenQr: hasChosenQr,
        hasChosenLogo: hasChosenLogo,
      );
      await SavedContactInfo.writeToFolder(contactFolder.path, savedContact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText());

      final displayName =
          savedContact.name.isNotEmpty ? savedContact.name : 'Visiting Card';
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

  Future<bool> updateCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    required Future<Uint8List?> Function(int side) captureSide,
  }) async {
    if (isSaving) return false;
    final folderPath = editingContactFolderPath;
    final fileId = editingSavedFileId;
    if (folderPath == null || fileId == null) return false;

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

      final contactFolder = Directory(folderPath);
      await contactFolder.create(recursive: true);

      final embedded = await _persistEmbeddedAssets(contactFolder);
      final frontPath = p.join(contactFolder.path, 'card_front.jpg');
      final backPath = p.join(contactFolder.path, 'card_back.jpg');
      await File(frontPath).writeAsBytes(_toJpeg(frontBytes), flush: true);
      await File(backPath).writeAsBytes(_toJpeg(backBytes), flush: true);

      final savedContact = SavedContactInfo(
        name: names.first.value.trim(),
        designation: designations.first.value.trim(),
        company: companies.first.value.trim(),
        tagline: taglines.isNotEmpty ? taglines.first.value.trim() : '',
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
        imagePaths: [frontPath, backPath],
        source: SavedContactInfo.sourceTemplate,
        templateId: templateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        hasChosenQr: hasChosenQr,
        hasChosenLogo: hasChosenLogo,
      );
      await SavedContactInfo.writeToFolder(contactFolder.path, savedContact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText());

      final displayName =
          savedContact.name.isNotEmpty ? savedContact.name : 'Visiting Card';
      final model = SavedFileModel(
        id: fileId,
        name: displayName,
        dateTime: editingDateTime ??
            DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now()),
        path: contactFolder.path,
        pathImage: frontPath,
        fileType: 'visiting_card',
        folderId: editingFolderId ?? FolderViewModel.visitingCardFolderId,
        isTextFile: false,
      );
      await AppStorageService().updateFile(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearEditingState();

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

  Future<({String qrPath, String logoPath})> _persistEmbeddedAssets(
    Directory contactFolder,
  ) async {
    final embeddedDir = Directory(p.join(contactFolder.path, 'embedded'));
    if (!await embeddedDir.exists()) {
      await embeddedDir.create(recursive: true);
    }

    var qrPath = '';
    if (hasChosenQr && qrAssetPath != null && qrAssetPath!.isNotEmpty) {
      qrPath = await _persistEmbeddedFile(qrAssetPath!, embeddedDir, 'qr') ??
          qrAssetPath!;
      qrAssetPath = qrPath;
    }

    var logoPath = '';
    if (hasChosenLogo && logoAssetPath != null && logoAssetPath!.isNotEmpty) {
      logoPath =
          await _persistEmbeddedFile(logoAssetPath!, embeddedDir, 'logo') ??
              logoAssetPath!;
      logoAssetPath = logoPath;
    }

    return (qrPath: qrPath, logoPath: logoPath);
  }

  Future<String?> _persistEmbeddedFile(
    String sourcePath,
    Directory destDir,
    String baseName,
  ) async {
    if (sourcePath.startsWith('assets/')) return sourcePath;
    final src = File(sourcePath);
    if (!await src.exists()) return null;

    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.png';

    // Read FIRST — source may already live in [destDir] (previous update).
    final bytes = await src.readAsBytes();

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File(p.join(destDir.path, '${baseName}_$stamp$ext'));
    await dest.writeAsBytes(bytes, flush: true);

    await for (final entity in destDir.list()) {
      if (entity is! File) continue;
      if (p.equals(entity.path, dest.path)) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('$baseName.') || name.startsWith('${baseName}_')) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }

    return dest.path;
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
