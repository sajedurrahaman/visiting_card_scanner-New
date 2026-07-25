class FolderRecord {
  const FolderRecord({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.parentFolderId,
  });

  final String id;
  final String name;
  final String dateTime;
  final String parentFolderId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateTime': dateTime,
        'parentFolderId': parentFolderId,
      };

  factory FolderRecord.fromJson(Map<String, dynamic> json) {
    return FolderRecord(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateTime: json['dateTime'] as String? ?? '',
      parentFolderId: json['parentFolderId'] as String? ?? '',
    );
  }
}
