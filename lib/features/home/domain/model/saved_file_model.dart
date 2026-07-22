class SavedFileModel {
  const SavedFileModel({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.path,
    required this.pathImage,
    required this.fileType,
    required this.folderId,
    this.isTextFile = false,
  });

  final String id;
  final String name;
  final String dateTime;
  final String path;
  final String pathImage;

  /// One of: `qr`, `barcode`, `visiting_card`.
  final String fileType;
  final String folderId;
  final bool isTextFile;

  SavedFileModel copyWith({
    String? id,
    String? name,
    String? dateTime,
    String? path,
    String? pathImage,
    String? fileType,
    String? folderId,
    bool? isTextFile,
  }) {
    return SavedFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      path: path ?? this.path,
      pathImage: pathImage ?? this.pathImage,
      fileType: fileType ?? this.fileType,
      folderId: folderId ?? this.folderId,
      isTextFile: isTextFile ?? this.isTextFile,
    );
  }

  factory SavedFileModel.fromJson(Map<String, dynamic> json) {
    return SavedFileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateTime: json['dateTime'] as String? ?? '',
      path: json['path'] as String? ?? '',
      pathImage: json['pathImage'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      folderId: json['folderId'] as String? ?? '',
      isTextFile: json['isTextFile'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateTime': dateTime,
        'path': path,
        'pathImage': pathImage,
        'fileType': fileType,
        'folderId': folderId,
        'isTextFile': isTextFile,
      };
}
