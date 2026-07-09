class SubFolderItem {
  const SubFolderItem({
    required this.id,
    required this.name,
    required this.dateTime,
  });

  final String id;
  final String name;
  final String dateTime;

  SubFolderItem copyWith({
    String? id,
    String? name,
    String? dateTime,
  }) {
    return SubFolderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
