import 'package:flutter/material.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';

/// Layout helpers for the baked-in contact icons (phone / email / web / pin)
/// that ship inside template PNGs. We cover those pixels and draw interactive
/// overlays so users can select, move, resize, and replace them.
class VisitingCardContactIconLayout {
  VisitingCardContactIconLayout._();

  /// Icon box as a fraction of card width (matches typical template badges).
  static const double defaultSize = 0.052;

  /// Gap between the icon circle and the contact text.
  static const double textGap = 0.012;

  /// Slightly larger than [defaultSize] so the white cover fully hides the PNG.
  static const double coverScale = 1.18;

  static const Color fallbackAccent = Color(0xFF8BC34A);
  static const Color coverColor = Color(0xFFFFFFFF);

  static const contactIconFields = <VisitingCardOverlayField>[
    VisitingCardOverlayField.addressIcon,
    VisitingCardOverlayField.emailIcon,
    VisitingCardOverlayField.phoneIcon,
    VisitingCardOverlayField.websiteIcon,
  ];

  static IconData materialIcon(VisitingCardOverlayField field) =>
      switch (field) {
        VisitingCardOverlayField.addressIcon => Icons.location_on_rounded,
        VisitingCardOverlayField.emailIcon => Icons.email_rounded,
        VisitingCardOverlayField.phoneIcon => Icons.phone_rounded,
        VisitingCardOverlayField.websiteIcon => Icons.language_rounded,
        _ => Icons.circle,
      };

  /// Accent used for the default circular badge (usually designation color).
  static Color accentFor(VisitingCardSidePositions side) =>
      side.designation?.color ??
      side.name?.firstNameColor ??
      side.name?.color ??
      fallbackAccent;

  static VisitingCardFieldPosition? textPosFor(
    VisitingCardSidePositions side,
    VisitingCardOverlayField iconField,
  ) {
    return switch (iconField) {
      VisitingCardOverlayField.phoneIcon => side.phone,
      VisitingCardOverlayField.emailIcon => side.email,
      VisitingCardOverlayField.websiteIcon => side.website,
      VisitingCardOverlayField.addressIcon => side.address,
      _ => null,
    };
  }

  /// Default placement for a contact icon, derived from its text field.
  static VisitingCardFieldPosition? positionFor({
    required VisitingCardOverlayField iconField,
    required VisitingCardSidePositions side,
    String? templateId,
  }) {
    final override = _templateOverride(templateId, iconField);
    if (override != null) return override;

    final text = textPosFor(side, iconField);
    if (text == null || text.left == null || text.top == null) return null;

    final size = defaultSize;
    final textLeft = text.left!;
    final textTop = text.top!;
    final textWidth = text.width ?? 0.34;

    final double left;
    if (text.textAlign == TextAlign.right) {
      // Icon sits to the right of a right-aligned text block.
      left = (textLeft + textWidth + textGap).clamp(0.0, 0.95);
    } else {
      // Most templates: green badge immediately left of the contact line.
      left = (textLeft - size - textGap).clamp(0.0, 0.95);
    }

    // Nudge up slightly so the circle centers on a single text line.
    final top = (textTop - size * 0.12).clamp(0.0, 0.95);

    return VisitingCardFieldPosition(
      left: left,
      top: top,
      size: size,
      color: accentFor(side),
    );
  }

  /// Per-template fine-tuning for templates where the derived gap is off.
  static VisitingCardFieldPosition? _templateOverride(
    String? templateId,
    VisitingCardOverlayField iconField,
  ) {
    if (templateId == null) return null;
    final map = _overrides[templateId];
    if (map == null) return null;
    return map[iconField];
  }

  /// Pixel-measured from template PNGs (square size = fraction of card width).
  static const _overrides = <String, Map<VisitingCardOverlayField, VisitingCardFieldPosition>>{
    'h2': {
      VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
        left: 0.6147,
        top: 0.1778,
        size: 0.0459,
        color: Color(0xFF97CE20),
      ),
      VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
        left: 0.6147,
        top: 0.2888,
        size: 0.0459,
        color: Color(0xFF97CE20),
      ),
      VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
        left: 0.6147,
        top: 0.3984,
        size: 0.0459,
        color: Color(0xFF97CE20),
      ),
      VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
        left: 0.6147,
        top: 0.5094,
        size: 0.0459,
        color: Color(0xFF97CE20),
      ),
    },
  };
}
