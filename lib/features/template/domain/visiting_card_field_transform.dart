/// Interactive overlay fields that users can drag / resize / rotate.
library;

import 'dart:ui' show Color;

enum VisitingCardOverlayField {
  name,
  designation,
  company,
  tagline,
  phone,
  email,
  website,
  address,
  logo,
  qr,
}

extension VisitingCardOverlayFieldX on VisitingCardOverlayField {
  bool get isImageOverlay =>
      this == VisitingCardOverlayField.logo ||
      this == VisitingCardOverlayField.qr;
}

/// Runtime placement override for one overlay field.
///
/// [left] / [top] are fractions of card size (0–1).
/// [size] for logo/qr = square box as fraction of card **width**;
/// for company/tagline = font size (design units, same as position config).
/// [rotation] is radians.
/// [width] is optional text width as fraction of card width.
class VisitingCardFieldTransform {
  const VisitingCardFieldTransform({
    required this.left,
    required this.top,
    required this.size,
    this.rotation = 0,
    this.width,
    this.shapeScaleX = 1,
    this.shapeScaleY = 1,
    this.flipX = false,
    this.flipY = false,
    this.textColorValue,
    this.opacity = 1,
    this.letterSpacing = 0,
    this.strokeWidth = 0,
    this.strokeColorValue,
    this.shadowBlur = 0,
    this.shadowColorValue,
    this.duplicateOf,
    this.duplicateText,
    this.duplicateImagePath,
    this.locked = false,
    this.fontPreset,
    this.fontBoldMode = 0,
    this.fontItalicMode = 0,
    this.fontUnderline = false,
    this.fontStrike = false,
    this.zIndex,
  });

  final double left;
  final double top;
  final double size;
  final double rotation;
  final double? width;

  /// Independent shape stretching, applied after the original image aspect ratio.
  final double shapeScaleX;
  final double shapeScaleY;
  final bool flipX;
  final bool flipY;

  /// Override text color as ARGB. Null keeps the template color.
  final int? textColorValue;
  final double opacity;
  final double letterSpacing;
  final double strokeWidth;
  final int? strokeColorValue;
  final double shadowBlur;
  final int? shadowColorValue;

  /// Set on copies created by Duplicate. Value is the source field name.
  final String? duplicateOf;
  final String? duplicateText;
  final String? duplicateImagePath;

  /// When true, the landscape selection border has no resize handles.
  final bool locked;

  /// Index into [VisitingCardFontPreset.presets]. Null keeps the template font.
  final int? fontPreset;

  /// 0 = follow template/preset, 1 = force bold, 2 = force regular.
  final int fontBoldMode;

  /// 0 = follow template, 1 = italic, 2 = upright.
  final int fontItalicMode;
  final bool fontUnderline;
  final bool fontStrike;

  /// Paint order on the card. Null keeps the template's default stack.
  /// Higher values are in front.
  final int? zIndex;

  static int naturalZ(VisitingCardOverlayField field) => switch (field) {
        VisitingCardOverlayField.name => 0,
        VisitingCardOverlayField.designation => 10,
        VisitingCardOverlayField.company => 20,
        VisitingCardOverlayField.tagline => 30,
        VisitingCardOverlayField.phone => 40,
        VisitingCardOverlayField.email => 50,
        VisitingCardOverlayField.website => 60,
        VisitingCardOverlayField.address => 70,
        VisitingCardOverlayField.logo => 80,
        VisitingCardOverlayField.qr => 90,
      };

  /// Stack position for a stored overlay. Duplicates sit above template fields
  /// until Send Back / Send Front assigns [zIndex].
  static int stackZ(String key, VisitingCardFieldTransform? transform) {
    final stored = transform?.zIndex;
    if (stored != null) return stored;
    if (key.startsWith('dup:')) return 100;
    final field = fieldFromKey(key);
    if (field == null) return 0;
    return naturalZ(field);
  }

  bool get hasFontOverride =>
      fontPreset != null ||
      fontBoldMode != 0 ||
      fontItalicMode != 0 ||
      fontUnderline ||
      fontStrike;

  Color? get textColor =>
      textColorValue == null ? null : Color(textColorValue!);

  Color? get strokeColor =>
      strokeColorValue == null ? null : Color(strokeColorValue!);

  Color? get shadowColor =>
      shadowColorValue == null ? null : Color(shadowColorValue!);

  VisitingCardFieldTransform copyWith({
    double? left,
    double? top,
    double? size,
    double? rotation,
    double? width,
    double? shapeScaleX,
    double? shapeScaleY,
    bool? flipX,
    bool? flipY,
    int? textColorValue,
    double? opacity,
    double? letterSpacing,
    double? strokeWidth,
    int? strokeColorValue,
    double? shadowBlur,
    int? shadowColorValue,
    String? duplicateOf,
    String? duplicateText,
    String? duplicateImagePath,
    bool? locked,
    int? fontPreset,
    int? fontBoldMode,
    int? fontItalicMode,
    bool? fontUnderline,
    bool? fontStrike,
    int? zIndex,
  }) {
    return VisitingCardFieldTransform(
      left: left ?? this.left,
      top: top ?? this.top,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
      shapeScaleX: shapeScaleX ?? this.shapeScaleX,
      shapeScaleY: shapeScaleY ?? this.shapeScaleY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      textColorValue: textColorValue ?? this.textColorValue,
      opacity: opacity ?? this.opacity,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColorValue: strokeColorValue ?? this.strokeColorValue,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColorValue: shadowColorValue ?? this.shadowColorValue,
      duplicateOf: duplicateOf ?? this.duplicateOf,
      duplicateText: duplicateText ?? this.duplicateText,
      duplicateImagePath: duplicateImagePath ?? this.duplicateImagePath,
      locked: locked ?? this.locked,
      fontPreset: fontPreset ?? this.fontPreset,
      fontBoldMode: fontBoldMode ?? this.fontBoldMode,
      fontItalicMode: fontItalicMode ?? this.fontItalicMode,
      fontUnderline: fontUnderline ?? this.fontUnderline,
      fontStrike: fontStrike ?? this.fontStrike,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'size': size,
        'rotation': rotation,
        if (width != null) 'width': width,
        if (shapeScaleX != 1) 'shapeScaleX': shapeScaleX,
        if (shapeScaleY != 1) 'shapeScaleY': shapeScaleY,
        if (flipX) 'flipX': flipX,
        if (flipY) 'flipY': flipY,
        if (textColorValue != null) 'textColor': textColorValue,
        if (opacity != 1) 'opacity': opacity,
        if (letterSpacing != 0) 'letterSpacing': letterSpacing,
        if (strokeWidth != 0) 'strokeWidth': strokeWidth,
        if (strokeColorValue != null) 'strokeColor': strokeColorValue,
        if (shadowBlur != 0) 'shadowBlur': shadowBlur,
        if (shadowColorValue != null) 'shadowColor': shadowColorValue,
        if (duplicateOf != null) 'duplicateOf': duplicateOf,
        if (duplicateText != null) 'duplicateText': duplicateText,
        if (duplicateImagePath != null) 'duplicateImagePath': duplicateImagePath,
        if (locked) 'locked': locked,
        if (fontPreset != null) 'fontPreset': fontPreset,
        if (fontBoldMode != 0) 'fontBoldMode': fontBoldMode,
        if (fontItalicMode != 0) 'fontItalicMode': fontItalicMode,
        if (fontUnderline) 'fontUnderline': fontUnderline,
        if (fontStrike) 'fontStrike': fontStrike,
        if (zIndex != null) 'zIndex': zIndex,
      };

  factory VisitingCardFieldTransform.fromJson(Map<String, dynamic> json) {
    return VisitingCardFieldTransform(
      left: (json['left'] as num?)?.toDouble() ?? 0,
      top: (json['top'] as num?)?.toDouble() ?? 0,
      size: (json['size'] as num?)?.toDouble() ?? 0.14,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble(),
      shapeScaleX: (json['shapeScaleX'] as num?)?.toDouble() ?? 1,
      shapeScaleY: (json['shapeScaleY'] as num?)?.toDouble() ?? 1,
      flipX: json['flipX'] == true,
      flipY: json['flipY'] == true,
      textColorValue: (json['textColor'] as num?)?.toInt(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0,
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 0,
      strokeColorValue: (json['strokeColor'] as num?)?.toInt(),
      shadowBlur: (json['shadowBlur'] as num?)?.toDouble() ?? 0,
      shadowColorValue: (json['shadowColor'] as num?)?.toInt(),
      duplicateOf: json['duplicateOf'] as String?,
      duplicateText: json['duplicateText'] as String?,
      duplicateImagePath: json['duplicateImagePath'] as String?,
      locked: json['locked'] == true,
      fontPreset: (json['fontPreset'] as num?)?.toInt(),
      fontBoldMode: (json['fontBoldMode'] as num?)?.toInt() ?? 0,
      fontItalicMode: (json['fontItalicMode'] as num?)?.toInt() ?? 0,
      fontUnderline: json['fontUnderline'] == true,
      fontStrike: json['fontStrike'] == true,
      zIndex: (json['zIndex'] as num?)?.toInt(),
    );
  }

  static String keyOf(VisitingCardOverlayField field) => field.name;

  static VisitingCardOverlayField? fieldFromKey(String key) {
    for (final f in VisitingCardOverlayField.values) {
      if (f.name == key) return f;
    }
    return null;
  }
}

/// Front + back overlay transforms for a saved / editing card.
class VisitingCardFieldTransforms {
  const VisitingCardFieldTransforms({
    this.front = const {},
    this.back = const {},
  });

  final Map<String, VisitingCardFieldTransform> front;
  final Map<String, VisitingCardFieldTransform> back;

  bool get isEmpty => front.isEmpty && back.isEmpty;

  Map<String, VisitingCardFieldTransform> forSide(bool isFront) =>
      isFront ? front : back;

  Map<String, dynamic> toJson() => {
        'front': front.map((k, v) => MapEntry(k, v.toJson())),
        'back': back.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory VisitingCardFieldTransforms.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VisitingCardFieldTransforms();

    Map<String, VisitingCardFieldTransform> parse(dynamic raw) {
      if (raw is! Map) return const {};
      final out = <String, VisitingCardFieldTransform>{};
      raw.forEach((key, value) {
        if (value is Map) {
          out[key.toString()] = VisitingCardFieldTransform.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
      return out;
    }

    return VisitingCardFieldTransforms(
      front: parse(json['front']),
      back: parse(json['back']),
    );
  }
}
