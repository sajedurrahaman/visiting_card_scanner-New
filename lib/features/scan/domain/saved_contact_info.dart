import 'dart:convert';
import 'dart:io';

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

  bool get isFromTemplate =>
      source == sourceTemplate ||
      (source.isEmpty && templateId.isNotEmpty);

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
      };

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
    );
  }

  static Future<void> writeToFolder(
    String folderPath,
    SavedContactInfo contact,
  ) async {
    final file = File('$folderPath/contact.json');
    await file.writeAsString(jsonEncode(contact.toJson()), flush: true);
  }

  static Future<SavedContactInfo?> readFromFolder(String folderPath) async {
    final file = File('$folderPath/contact.json');
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      return SavedContactInfo.fromJson(Map<String, dynamic>.from(decoded));
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
