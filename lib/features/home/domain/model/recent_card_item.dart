class RecentCardItem {
  const RecentCardItem({
    required this.id,
    required this.name,
    required this.dateTime,
    this.thumbnailPath,
    this.path,
    this.fileType,
    this.folderId,
    this.isTextFile = false,
  });

  final String id;
  final String name;
  final String dateTime;
  final String? thumbnailPath;
  final String? path;
  final String? fileType;
  final String? folderId;
  final bool isTextFile;

  bool get hasFilePath => path != null && path!.isNotEmpty;

  RecentCardItem copyWith({
    String? id,
    String? name,
    String? dateTime,
    String? thumbnailPath,
    String? path,
    String? fileType,
    String? folderId,
    bool? isTextFile,
  }) {
    return RecentCardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      path: path ?? this.path,
      fileType: fileType ?? this.fileType,
      folderId: folderId ?? this.folderId,
      isTextFile: isTextFile ?? this.isTextFile,
    );
  }
}
