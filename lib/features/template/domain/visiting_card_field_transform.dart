/// Interactive overlay fields that users can drag / resize / rotate.
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
  });

  final double left;
  final double top;
  final double size;
  final double rotation;
  final double? width;

  VisitingCardFieldTransform copyWith({
    double? left,
    double? top,
    double? size,
    double? rotation,
    double? width,
  }) {
    return VisitingCardFieldTransform(
      left: left ?? this.left,
      top: top ?? this.top,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      width: width ?? this.width,
    );
  }

  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'size': size,
        'rotation': rotation,
        if (width != null) 'width': width,
      };

  factory VisitingCardFieldTransform.fromJson(Map<String, dynamic> json) {
    return VisitingCardFieldTransform(
      left: (json['left'] as num?)?.toDouble() ?? 0,
      top: (json['top'] as num?)?.toDouble() ?? 0,
      size: (json['size'] as num?)?.toDouble() ?? 0.14,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble(),
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
