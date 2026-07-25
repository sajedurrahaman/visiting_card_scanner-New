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
  late List<ContactFieldEntry> phones = draft.phoneEntries();
  late List<ContactFieldEntry> emails = draft.emailEntries();
  late List<ContactFieldEntry> websites = draft.websiteEntries();
  late List<ContactFieldEntry> addresses = draft.addressEntries();

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

  Future<bool> saveScannedCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
  }) async {
    if (isUpdatingExisting) {
      return updateScannedCard(
        homeViewModel: homeViewModel,
        folderViewModel: folderViewModel,
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

        // Gallery save disabled for scan → add contact → save flow.
        // Keep contact create + recent + folder storage only.
        // try {
        //   final hasAccess = await Gal.hasAccess();
        //   if (!hasAccess) await Gal.requestAccess();
        //   await Gal.putImage(out.path, album: 'Visiting Card');
        // } catch (_) {}
      }

      final contact = _buildSavedContact(savedImagePaths);
      await SavedContactInfo.writeToFolder(contactFolder.path, contact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText());

      final displayName =
          contact.name.isNotEmpty ? contact.name : 'Visiting Card';
      final thumbPath = frontPath ?? p.join(contactFolder.path, 'card_front.jpg');
      final model = SavedFileModel(
        id: '${now.millisecondsSinceEpoch}',
        name: displayName,
        dateTime: dateLabel,
        path: contactFolder.path,
        pathImage: thumbPath,
        fileType: 'visiting_card',
        folderId: FolderViewModel.visitingCardFolderId,
        isTextFile: false,
      );
      await AppStorageService().storeAllFiles(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearImages();
      clearEditingState();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates existing contact folder + storage row (PDF Scanner Update flow).
  Future<bool> updateScannedCard({
    required HomeViewModel homeViewModel,
    required FolderViewModel folderViewModel,
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

      final contact = _buildSavedContact(savedImagePaths);
      await SavedContactInfo.writeToFolder(contactFolder.path, contact);
      await File(p.join(contactFolder.path, 'contact_details.txt'))
          .writeAsString(_contactDetailsText());

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
      );
      await AppStorageService().updateFile(model);

      await homeViewModel.loadRecentFromStorage();
      await folderViewModel.loadFromStorage();
      clearImages();
      clearEditingState();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  SavedContactInfo buildSavedContact({List<String>? imagePaths}) {
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
      imagePaths: imagePaths ??
          images
              .map((e) => e.filePath)
              .whereType<String>()
              .where((e) => e.isNotEmpty)
              .toList(),
    );
  }

  SavedContactInfo _buildSavedContact(List<String> savedImagePaths) {
    return buildSavedContact(imagePaths: savedImagePaths);
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
    return buffer.isEmpty ? 'Visiting card contact (exported)' : buffer.toString();
  }
}
