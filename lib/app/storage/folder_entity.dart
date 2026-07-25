import 'package:isar_plus/isar_plus.dart';

part 'folder_entity.g.dart';

/// Isar collection for user-created folders (PDF Scanner folder persistence parity).
@Collection(accessor: 'folders')
class FolderEntity {
  @Id()
  int id = 0;

  /// App-facing folder id (e.g. `sub_17123…`).
  @Index(unique: true)
  late String folderId;

  late String name;
  late String dateTime;

  /// Parent folder id (`visiting_card` / `qr_code` / `barcode` / another `sub_…`).
  @Index()
  late String parentFolderId;
}
