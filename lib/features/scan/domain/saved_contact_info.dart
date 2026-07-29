import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';

class SavedContactInfo {
  const SavedContactInfo({
    this.name = '',
    this.designation = '',
    this.company = '',
    this.tagline = '',
    this.phones = const [],
    this.emails = const [],
    this.websites = const [],
    this.addresses = const [],
    this.imagePaths = const [],
    this.source = '',
    this.templateId = '',
    this.qrImagePath = '',
    this.logoImagePath = '',
    this.hasChosenQr = false,
    this.hasChosenLogo = false,
    this.templateImagePaths = const [],
    this.fieldTransforms = const VisitingCardFieldTransforms(),
  });

  static const sourceScan = 'scan';
  static const sourceTemplate = 'template';

  final String name;
  final String designation;
  final String company;
  final String tagline;
  final List<SavedTypedValue> phones;
  final List<SavedTypedValue> emails;
  final List<SavedTypedValue> websites;
  final List<String> addresses;
  final List<String> imagePaths;

  /// [sourceScan] or [sourceTemplate]. Empty on older saved cards.
  final String source;
  final String templateId;
  final String qrImagePath;
  final String logoImagePath;
  final bool hasChosenQr;
  final bool hasChosenLogo;
  final List<String> templateImagePaths;
  final VisitingCardFieldTransforms fieldTransforms;

  /// True when at least one contact field has a non-empty value.
  bool get hasAnyFieldData =>
      name.trim().isNotEmpty ||
      designation.trim().isNotEmpty ||
      company.trim().isNotEmpty ||
      tagline.trim().isNotEmpty ||
      phones.any((e) => e.value.trim().isNotEmpty) ||
      emails.any((e) => e.value.trim().isNotEmpty) ||
      websites.any((e) => e.value.trim().isNotEmpty) ||
      addresses.any((e) => e.trim().isNotEmpty);

  /// True only for cards created from the template designer (not scan + template).
  bool get isFromTemplate => source == sourceTemplate;

  Map<String, dynamic> toJson() => {
        'name': name,
        'designation': designation,
        'company': company,
        'tagline': tagline,
        'phones': phones.map((e) => e.toJson()).toList(),
        'emails': emails.map((e) => e.toJson()).toList(),
        'websites': websites.map((e) => e.toJson()).toList(),
        'addresses': addresses,
        'imagePaths': imagePaths,
        'source': source,
        'templateId': templateId,
        'qrImagePath': qrImagePath,
        'logoImagePath': logoImagePath,
        'hasChosenQr': hasChosenQr,
        'hasChosenLogo': hasChosenLogo,
        'templateImagePaths': templateImagePaths,
        if (!fieldTransforms.isEmpty)
          'fieldTransforms': fieldTransforms.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory SavedContactInfo.fromJson(Map<String, dynamic> json) {
    List<SavedTypedValue> typed(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => SavedTypedValue.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<String> strings(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }

    return SavedContactInfo(
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      company: json['company'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      phones: typed('phones'),
      emails: typed('emails'),
      websites: typed('websites'),
      addresses: strings('addresses'),
      imagePaths: strings('imagePaths'),
      source: json['source'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      qrImagePath: json['qrImagePath'] as String? ?? '',
      logoImagePath: json['logoImagePath'] as String? ?? '',
      hasChosenQr: json['hasChosenQr'] as bool? ?? false,
      hasChosenLogo: json['hasChosenLogo'] as bool? ?? false,
      templateImagePaths: strings('templateImagePaths'),
      fieldTransforms: VisitingCardFieldTransforms.fromJson(
        json['fieldTransforms'] is Map
            ? Map<String, dynamic>.from(json['fieldTransforms'] as Map)
            : null,
      ),
    );
  }

  static Future<void> writeToFolder(
    String folderPath,
    SavedContactInfo contact,
  ) async {
    final file = File(p.join(folderPath, 'contact.json'));
    await file.writeAsString(jsonEncode(contact.toJson()), flush: true);
  }

  static Future<SavedContactInfo?> readFromFolder(String folderPath) async {
    final file = File(p.join(folderPath, 'contact.json'));
    if (await file.exists()) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) {
          final contact =
              SavedContactInfo.fromJson(Map<String, dynamic>.from(decoded));
          if (contact.hasAnyFieldData) return contact;
        }
      } catch (e, st) {
        assert(() {
          // ignore: avoid_print
          print('SavedContactInfo.readFromFolder failed: $e\n$st');
          return true;
        }());
      }
    }

    // Older saves / corrupt json — fall back to contact_details.txt.
    return readFromDetailsTxt(folderPath);
  }

  /// Best-effort parse of `contact_details.txt` written beside contact.json.
  static Future<SavedContactInfo?> readFromDetailsTxt(String folderPath) async {
    final file = File(p.join(folderPath, 'contact_details.txt'));
    if (!await file.exists()) return null;
    try {
      final lines = (await file.readAsString())
          .split(RegExp(r'\r?\n'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (lines.isEmpty) return null;

      var name = '';
      var designation = '';
      var company = '';
      var tagline = '';
      final phones = <SavedTypedValue>[];
      final emails = <SavedTypedValue>[];
      final websites = <SavedTypedValue>[];
      final addresses = <String>[];

      for (final line in lines) {
        final sep = line.indexOf(':');
        if (sep <= 0) continue;
        final label = line.substring(0, sep).trim();
        final value = line.substring(sep + 1).trim();
        if (value.isEmpty) continue;
        final lower = label.toLowerCase();
        if (lower == 'name') {
          name = value;
        } else if (lower == 'designation') {
          designation = value;
        } else if (lower == 'company') {
          company = value;
        } else if (lower == 'tagline') {
          tagline = value;
        } else if (lower.startsWith('email')) {
          final typeMatch = RegExp(r'\(([^)]+)\)').firstMatch(label);
          emails.add(
            SavedTypedValue(
              value: value,
              type: typeMatch?.group(1)?.trim() ?? 'Company',
            ),
          );
        } else if (lower.startsWith('website')) {
          final typeMatch = RegExp(r'\(([^)]+)\)').firstMatch(label);
          websites.add(
            SavedTypedValue(
              value: value,
              type: typeMatch?.group(1)?.trim() ?? 'Company',
            ),
          );
        } else if (lower == 'address') {
          addresses.add(value);
        } else {
          // Phone rows are written as "<type>: <number>" (Cell/Work/…).
          phones.add(SavedTypedValue(value: value, type: label));
        }
      }

      final contact = SavedContactInfo(
        name: name,
        designation: designation,
        company: company,
        tagline: tagline,
        phones: phones,
        emails: emails,
        websites: websites,
        addresses: addresses,
      );
      return contact.hasAnyFieldData ? contact : null;
    } catch (_) {
      return null;
    }
  }
}

class SavedTypedValue {
  const SavedTypedValue({
    required this.value,
    this.type = '',
  });

  final String value;
  final String type;

  Map<String, dynamic> toJson() => {
        'value': value,
        'type': type,
      };

  factory SavedTypedValue.fromJson(Map<String, dynamic> json) {
    return SavedTypedValue(
      value: json['value'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
