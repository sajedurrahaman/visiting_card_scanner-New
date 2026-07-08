class RecentCardItem {
  const RecentCardItem({
    required this.id,
    required this.name,
    required this.dateTime,
    this.thumbnailPath,
    this.isTextFile = false,
  });

  final String id;
  final String name;
  final String dateTime;
  final String? thumbnailPath;
  final bool isTextFile;

  RecentCardItem copyWith({
    String? id,
    String? name,
    String? dateTime,
    String? thumbnailPath,
    bool? isTextFile,
  }) {
    return RecentCardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isTextFile: isTextFile ?? this.isTextFile,
    );
  }
}
