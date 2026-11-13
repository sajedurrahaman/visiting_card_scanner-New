import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Shared gallery/camera picks that ignore Android `already_active` races
/// (double-tap / overlapping pickers) instead of crashing via Crashlytics.
class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage({
    required ImageSource source,
    int imageQuality = 90,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return null;
      rethrow;
    }
  }

  static Future<List<XFile>> pickMultiImage({
    int imageQuality = 90,
    int? limit,
  }) async {
    try {
      return await _picker.pickMultiImage(
        imageQuality: imageQuality,
        limit: limit,
      );
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return const [];
      rethrow;
    }
  }
}
