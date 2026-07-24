import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Photo Collage Maker BG custom color picker parity
/// (`_pickCustomBgColor` in free_style / PhotoEditScreen).
Future<Color?> showMultipleColorPicker(
  BuildContext context, {
  Color? initial,
}) async {
  Color pickerColor = initial ?? Colors.red;
  final picked = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Pick color', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (color) => pickerColor = color,
          enableAlpha: false,
          labelTypes: const [],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  if (picked != true) return null;
  return pickerColor;
}
