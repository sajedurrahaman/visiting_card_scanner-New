import 'dart:typed_data';

class ScannedImageModel {
  ScannedImageModel({
    required this.bytes,
    required this.name,
    this.filePath,
  });

  Uint8List bytes;
  String name;
  String? filePath;
}
