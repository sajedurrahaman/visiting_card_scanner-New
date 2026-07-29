import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:gal/gal.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/scan/domain/ocr_contact_parser.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/scan/domain/scanned_image_model.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardScanViewModel extends ChangeNotifier {
  final List<ScannedImageModel> images = [];
  bool isBothSides = true;
  bool isOcrLoading = false;
  bool isSaving = false;
  String ocrText = '';
  ScannedContactDraft draft = ScannedContactDraft();

  /// When editing an existing saved card (details → Edit).
  String? editingSavedFileId;
  String? editingContactFolderPath;
  String? editingFolderId;
  String? editingDateTime;

  bool get isUpdatingExisting =>
      editingSavedFileId != null &&
      editingContactFolderPath != null &&
      editingContactFolderPath!.isNotEmpty;

  late List<ContactFieldEntry> names = draft.nameEntries();
  late List<ContactFieldEntry> designations = draft.designationEntries();
  late List<ContactFieldEntry> companies = draft.companyEntries();
  List<ContactFieldEntry> taglines = [ContactFieldEntry()];
  late List<ContactFieldEntry> phones = draft.phoneEntries();
  late List<ContactFieldEntry> emails = draft.emailEntries();
  late List<ContactFieldEntry> websites = draft.websiteEntries();
  late List<ContactFieldEntry> addresses = draft.addressEntries();

  String? qrAssetPath;
  String? logoAssetPath;
  bool hasChosenQr = false;
  bool hasChosenLogo = false;
  String? selectedTemplateId;
  VisitingCardFieldTransforms fieldTransforms =
      const VisitingCardFieldTransforms();

  int get maxShots => isBothSides ? 2 : 1;
  bool get canCaptureMore => images.length < maxShots;

  void setBothSides(bool value) {
    if (isBothSides == value) return;
    isBothSides = value;
    if (!isBothSides && images.length > 1) {
      images.removeRange(1, images.length);
    }
    notifyListeners();
  }

  void clearImages() {
    images.clear();
    notifyListeners();
  }

  Future<void> loadFromSavedContact({
    required SavedContactInfo contact,
    required List<Uint8List> imageBytesList,
    String? savedFileId,
    String? contactFolderPath,
    String? folderId,
    String? dateTime,
  }) async {
    editingSavedFileId = savedFileId;
    editingContactFolderPath = contactFolderPath;
    editingFolderId = folderId;
    editingDateTime = dateTime;

    images
      ..clear()
      ..addAll(
        List.generate(imageBytesList.length, (i) {
          return ScannedImageModel(
            bytes: imageBytesList[i],
            name: 'visitingcard_edit_$i.jpg',
            filePath: i < contact.imagePaths.length
                ? contact.imagePaths[i]
                : null,
          );
        }),
      );

    names = [ContactFieldEntry(value: contact.name)];
    designations = [ContactFieldEntry(value: contact.designation)];
    companies = [ContactFieldEntry(value: contact.company)];
    taglines = [ContactFieldEntry(value: contact.tagline)];
    phones = contact.phones.isEmpty
        ? [ContactFieldEntry(type: 'Cell')]
        : contact.phones
            .map((e) => ContactFieldEntry(value: e.value, type: e.type))
            .toList();
    emails = contact.emails.isEmpty
        ? [ContactFieldEntry(type: 'Company')]
        : contact.emails
            .map((e) => ContactFieldEntry(value: e.value, type: e.type))
            .toList();
    websites = contact.websites.isEmpty
        ? [ContactFieldEntry(type: 'Company')]
        : contact.websites
            .map((e) => ContactFieldEntry(value: e.value, type: e.type))
            .toList();
    addresses = contact.addresses.isEmpty
        ? [ContactFieldEntry()]
        : contact.addresses
            .map((e) => ContactFieldEntry(value: e))
            .toList();
    selectedTemplateId =
        contact.templateId.isNotEmpty ? contact.templateId : null;
    hasChosenQr = contact.hasChosenQr;
    hasChosenLogo = contact.hasChosenLogo;
    qrAssetPath = contact.qrImagePath.isNotEmpty ? contact.qrImagePath : null;
    logoAssetPath =
        contact.logoImagePath.isNotEmpty ? contact.logoImagePath : null;
    fieldTransforms = contact.fieldTransforms;
    notifyListeners();
  }

  void clearEditingState() {
    editingSavedFileId = null;
    editingContactFolderPath = null;
    editingFolderId = null;
    editingDateTime = null;
  }

  void addImage(ScannedImageModel model) {
    if (images.length >= maxShots) return;
    images.add(model);
    notifyListeners();
  }

  void replaceImage(int index, ScannedImageModel model) {
    if (index < 0 || index >= images.length) return;
    images[index] = model;
    notifyListeners();
  }

  void updateImageBytes(int index, Uint8List bytes) {
    if (index < 0 || index >= images.length) return;
    images[index].bytes = bytes;
    images[index].name =
        'visitingcard_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
    images[index].filePath = null;
    notifyListeners();
  }

  Future<List<String>> persistPreviewFiles() async {
    final appDir = await getApplicationDocumentsDirectory();
    final picturesDir = Directory(p.join(appDir.path, 'Pictures'))
      ..createSync(recursive: true);

    final paths = <String>[];
    for (var i = 0; i < images.length; i++) {
      var fileName = images[i].name.trim();
      if (fileName.isEmpty) {
        fileName =
            'visitingcard_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      }
      if (p.extension(fileName).isEmpty) {
        fileName = '$fileName.jpg';
      }
      images[i].name = fileName;
      final fullPath = p.join(picturesDir.path, fileName);
      final file = File(fullPath);
      await file.writeAsBytes(images[i].bytes, flush: true);
      images[i].filePath = fullPath;
      paths.add(fullPath);
    }
    notifyListeners();
    return paths;
  }

  Future<bool> runOcr() async {
    if (images.isEmpty) return false;
    isOcrLoading = true;
    ocrText = '';
    notifyListeners();

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final paths = await persistPreviewFiles();
      for (final path in paths) {
        final recognized =
            await recognizer.processImage(InputImage.fromFilePath(path));
        ocrText += '${recognized.text}\n';
      }

      if (ocrText.trim().isEmpty) {
        return false;
      }

      draft = OcrContactParser.parse(ocrText);
      names = draft.nameEntries();
      designations = draft.designationEntries();
      companies = draft.companyEntries();
      taglines = [ContactFieldEntry()];
      phones = draft.phoneEntries();
      emails = draft.emailEntries();
      websites = draft.websiteEntries();
      addresses = draft.addressEntries();
      return true;
    } finally {
      await recognizer.close();
      isOcrLoading = false;
      notifyListeners();
    }
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

  void addField(List<ContactFieldEntry> list, {required String defaultType}) {
    list.add(ContactFieldEntry(type: defaultType));
    notifyListeners();
  }

  void removeField(List<ContactFieldEntry> list, int index) {
    if (list.length <= 1) {
      list[index].value = '';
      notifyListeners();
      return;
    }
    list.removeAt(index);
    notifyListeners();
  }

  void applyQrImage(String path) {
    if (path.trim().isEmpty) return;
    hasChosenQr = true;
    qrAssetPath = path;
    notifyListeners();
  }

  void applyLogoImage(String path) {
    if (path.trim().isEmpty) return;
    hasChosenLogo = true;
    logoAssetPath = path;
    notifyListeners();
  }

  /// Notify listeners after bulk field / transform sync from template edit.
  void notifyContactChanged() => notifyListeners();

  Future<String> persistLogoFile(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final logoDir = Directory(p.join(dir.path, 'visiting_card', 'logo_embed'));
    if (!await logoDir.exists()) {
      await logoDir.create(recursive: true);
    }
    final ext = source.path.contains('.')
        ? source.path.split('.').last
        : 'jpg';
    final dest = File(
      p.join(
        logoDir.path,
        'logo_${DateTime.now().millisecondsSinceEpoch}.$ext',
      ),
    );
    await source.copy(dest.path);
    return dest.path;
  }

  Future<bool> saveScannedCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    String? templateId,
    Future<Uint8List?> Function(int side)? captureTemplateSide,
  }) async {
    if (isUpdatingExisting) {
      return updateScannedCard(
        homeViewModel: homeViewModel,
        folderViewModel: folderViewModel,
        templateId: templateId,
        captureTemplateSide: captureTemplateSide,
      );
    }

    if (isSaving || images.isEmpty) return false;
    isSaving = true;
    notifyListeners();

    try {
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
      // Ensure template capture uses the freshly persisted QR/logo paths.
      final templatePaths = await _persistTemplateImages(
        contactFolder,
        captureTemplateSide,
      );

      String? frontPath;
      final savedImagePaths = <String>[];
      for (var i = 0; i < images.length; i++) {
        final fileName = i == 0
            ? 'card_front.jpg'
            : (i == 1 ? 'card_back.jpg' : 'card_$i.jpg');
        final out = File(p.join(contactFolder.path, fileName));
        await out.writeAsBytes(images[i].bytes, flush: true);
        savedImagePaths.add(out.path);
        if (i == 0) frontPath = out.path;
      }

      final contact = _buildSavedContact(
        savedImagePaths,
        templateId: templateId ?? selectedTemplateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        templateImagePaths: templatePaths,
      );
      final modelId = '${now.millisecondsSinceEpoch}';
      await SavedContactInfo.writeToFolder(contactFolder.path, contact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText(), flush: true);

      final displayName =
          contact.name.isNotEmpty ? contact.name : 'Visiting Card';
      final thumbPath = frontPath ?? p.join(contactFolder.path, 'card_front.jpg');
      final model = SavedFileModel(
        id: modelId,
        name: displayName,
        dateTime: dateLabel,
        path: contactFolder.path,
        pathImage: thumbPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
        contactJson: contact.toJsonString(),
      );
      await AppStorageService().storeAllFiles(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearImages();
      clearEditingState();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('saveScannedCard failed: $e\n$st');
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates existing contact folder + storage row (PDF Scanner Update flow).
  Future<bool> updateScannedCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
    String? templateId,
    Future<Uint8List?> Function(int side)? captureTemplateSide,
  }) async {
    if (isSaving || images.isEmpty) return false;
    final folderPath = editingContactFolderPath;
    final fileId = editingSavedFileId;
    if (folderPath == null || fileId == null) return false;

    isSaving = true;
    notifyListeners();

    try {
      final contactFolder = Directory(folderPath);
      await contactFolder.create(recursive: true);

      final embedded = await _persistEmbeddedAssets(contactFolder);
      // Ensure template capture uses the freshly persisted QR/logo paths.
      final templatePaths = await _persistTemplateImages(
        contactFolder,
        captureTemplateSide,
      );

      String? frontPath;
      final savedImagePaths = <String>[];
      for (var i = 0; i < images.length; i++) {
        final fileName = i == 0
            ? 'card_front.jpg'
            : (i == 1 ? 'card_back.jpg' : 'card_$i.jpg');
        final out = File(p.join(contactFolder.path, fileName));
        await out.writeAsBytes(images[i].bytes, flush: true);
        savedImagePaths.add(out.path);
        if (i == 0) frontPath = out.path;
      }

      final contact = _buildSavedContact(
        savedImagePaths,
        templateId: templateId ?? selectedTemplateId,
        qrImagePath: embedded.qrPath,
        logoImagePath: embedded.logoPath,
        templateImagePaths: templatePaths,
      );
      await SavedContactInfo.writeToFolder(contactFolder.path, contact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText(), flush: true);

      final displayName =
          contact.name.isNotEmpty ? contact.name : 'Visiting Card';
      final thumbPath = frontPath ?? p.join(contactFolder.path, 'card_front.jpg');
      final model = SavedFileModel(
        id: fileId,
        name: displayName,
        dateTime: editingDateTime ??
            DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now()),
        path: contactFolder.path,
        pathImage: thumbPath,
        fileType: 'visiting_card',
        folderId: editingFolderId ?? FolderViewModel.visitingCardFolderId,
        isTextFile: false,
        contactJson: contact.toJsonString(),
      );
      await AppStorageService().updateFile(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearImages();
      clearEditingState();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('updateScannedCard failed: $e\n$st');
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  SavedContactInfo buildSavedContact({
    List<String>? imagePaths,
    String? templateId,
    String? qrImagePath,
    String? logoImagePath,
    List<String>? templateImagePaths,
  }) {
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
      imagePaths: imagePaths ??
          images
              .map((e) => e.filePath)
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .toList(),
      source: SavedContactInfo.sourceScan,
      templateId: templateId ?? selectedTemplateId ?? '',
      qrImagePath: qrImagePath ?? qrAssetPath ?? '',
      logoImagePath: logoImagePath ?? logoAssetPath ?? '',
      hasChosenQr: hasChosenQr,
      hasChosenLogo: hasChosenLogo,
      templateImagePaths: templateImagePaths ?? const [],
      fieldTransforms: fieldTransforms,
    );
  }

  SavedContactInfo _buildSavedContact(
    List<String> savedImagePaths, {
    String? templateId,
    String? qrImagePath,
    String? logoImagePath,
    List<String> templateImagePaths = const [],
  }) {
    return buildSavedContact(
      imagePaths: savedImagePaths,
      templateId: templateId,
      qrImagePath: qrImagePath,
      logoImagePath: logoImagePath,
      templateImagePaths: templateImagePaths,
    );
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
      qrPath = await _persistEmbeddedFile(
            qrAssetPath!,
            embeddedDir,
            'qr',
          ) ??
          qrAssetPath!;
      qrAssetPath = qrPath;
    }

    var logoPath = '';
    if (hasChosenLogo && logoAssetPath != null && logoAssetPath!.isNotEmpty) {
      logoPath = await _persistEmbeddedFile(
            logoAssetPath!,
            embeddedDir,
            'logo',
          ) ??
          logoAssetPath!;
      logoAssetPath = logoPath;
    }

    return (qrPath: qrPath, logoPath: logoPath);
  }

  /// Writes a fresh copy under [destDir] with a unique name so updates
  /// overwrite safely and Flutter image cache does not keep the old file.
  Future<String?> _persistEmbeddedFile(
    String sourcePath,
    Directory destDir,
    String baseName,
  ) async {
    if (sourcePath.startsWith('assets/')) {
      return sourcePath;
    }
    final src = File(sourcePath);
    if (!await src.exists()) return null;

    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.png';

    // Read FIRST — source may already live in [destDir] (e.g. previous
    // embedded/qr_*.png). Deleting before read caused PathNotFoundException.
    final bytes = await src.readAsBytes();

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File(p.join(destDir.path, '${baseName}_$stamp$ext'));
    await dest.writeAsBytes(bytes, flush: true);

    // Remove older embedded copies (keep the new [dest]).
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

  Future<List<String>> _persistTemplateImages(
    Directory contactFolder,
    Future<Uint8List?> Function(int side)? captureTemplateSide,
  ) async {
    if (captureTemplateSide == null) return const [];

    final frontBytes = await captureTemplateSide(0);
    final backBytes = await captureTemplateSide(1);
    if (frontBytes == null || backBytes == null) return const [];

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final frontPath =
        p.join(contactFolder.path, 'template_front_$stamp.png');
    final backPath = p.join(contactFolder.path, 'template_back_$stamp.png');

    // Clean older template captures so folder stays tidy.
    for (final name in [
      'template_front.png',
      'template_back.png',
    ]) {
      final old = File(p.join(contactFolder.path, name));
      if (await old.exists()) {
        try {
          await old.delete();
        } catch (_) {}
      }
    }
    await for (final entity in contactFolder.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('template_front_') ||
          name.startsWith('template_back_')) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }

    await File(frontPath).writeAsBytes(frontBytes, flush: true);
    await File(backPath).writeAsBytes(backBytes, flush: true);
    return [frontPath, backPath];
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
    if (taglines.isNotEmpty) {
      addLine('Tagline', taglines.first.value);
    }
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
    return buffer.isEmpty ? 'Visiting card contact (exported)' : buffer.toString();
  }
}
