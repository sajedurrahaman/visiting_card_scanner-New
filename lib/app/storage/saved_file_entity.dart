import 'package:isar_plus/isar_plus.dart';

part 'saved_file_entity.g.dart';

/// Isar collection for saved QR / Barcode / Visiting Card metadata.
/// Domain DTO remains [SavedFileModel]; this is the persistence layer.
@Collection(accessor: 'savedFiles')
class SavedFileEntity {
  @Id()
  int id = 0;

  /// App-facing string id (UUID / timestamp key used across UI).
  @Index(unique: true)
  late String fileId;

  late String name;
  late String dateTime;
  late String path;
  late String pathImage;

  /// One of: `qr`, `barcode`, `visiting_card`.
  late String fileType;

  @Index()
  late String folderId;

  late bool isTextFile;

  /// Serialized [SavedContactInfo] JSON for visiting cards.
  /// Empty for QR / Barcode. Survives iOS Documents path churn.
  String contactJson = '';
}
