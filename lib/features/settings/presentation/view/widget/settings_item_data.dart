import 'package:flutter/material.dart';

class SettingsItemData {
  const SettingsItemData({
    required this.icon,
    required this.label,
    required this.subTitle,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String subTitle;
  final VoidCallback onTap;
}
