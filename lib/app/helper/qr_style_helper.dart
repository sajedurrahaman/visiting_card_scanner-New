import 'package:qr_flutter/qr_flutter.dart';

/// QR eye/dot style option lists (from PDF-Scanner app_helper).
class QrStyleHelper {
  const QrStyleHelper._();

  static List<Map<String, dynamic>> get dotStyleOptions => [
    {
      'name': 'Square',
      'shape': QrDataModuleShape.square,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_1.svg',
    },
    {
      'name': 'Circle',
      'shape': QrDataModuleShape.circle,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_2.svg',
    },
    {
      'name': 'Rounded',
      'shape': QrDataModuleShape.roundedSquare,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_3.svg',
    },
    {
      'name': 'Diamond',
      'shape': QrDataModuleShape.diamond,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_4.svg',
    },
    {
      'name': 'Star',
      'shape': QrDataModuleShape.star,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_5.svg',
    },
    {
      'name': 'Cross',
      'shape': QrDataModuleShape.cross,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_6.svg',
    },
    {
      'name': 'Horizontal',
      'shape': QrDataModuleShape.horizontal,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_7.svg',
    },
    {
      'name': 'Vertical',
      'shape': QrDataModuleShape.vertical,
      'image': 'assets/qr_code_template/dot_and_eye/dot_shape_temp_8.svg',
    },
  ];

  static List<Map<String, dynamic>> get eyeShapeOptions => [
    {
      'name': 'Eye 1',
      'shape': QrEyeShape.square,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_1.svg',
    },
    {
      'name': 'Eye 2',
      'shape': QrEyeShape.circle,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_2.svg',
    },
    {
      'name': 'Eye 3',
      'shape': QrEyeShape.dots,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_3.svg',
    },
    {
      'name': 'Eye 4',
      'shape': QrEyeShape.roundedOuter,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_4.svg',
    },
    {
      'name': 'Eye 5',
      'shape': QrEyeShape.squircle,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_5.svg',
    },
    {
      'name': 'Eye 6',
      'shape': QrEyeShape.sharpCorner,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_6.svg',
    },
    {
      'name': 'Eye 7',
      'shape': QrEyeShape.asymmetric,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_7.svg',
    },
    {
      'name': 'Eye 8',
      'shape': QrEyeShape.leaf,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_8.svg',
    },
    {
      'name': 'Eye 9',
      'shape': QrEyeShape.pinched,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_9.svg',
    },
    {
      'name': 'Eye 10',
      'shape': QrEyeShape.extraRounded,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_10.svg',
    },
    {
      'name': 'Eye 11',
      'shape': QrEyeShape.shield,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_11.svg',
    },
    {
      'name': 'Eye 12',
      'shape': QrEyeShape.star,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_12.svg',
    },
    {
      'name': 'Eye 13',
      'shape': QrEyeShape.diamond,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_13.svg',
    },
    {
      'name': 'Eye 14',
      'shape': QrEyeShape.circleOuter,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_14.svg',
    },
    {
      'name': 'Eye 15',
      'shape': QrEyeShape.roundedInner,
      'image': 'assets/qr_code_template/dot_and_eye/eye_shape_temp_15.svg',
    },
  ];
}
