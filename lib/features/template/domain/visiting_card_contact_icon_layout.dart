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

  /// Slightly larger than [defaultSize] so the sampled background patch hides
  /// the icon baked into the template PNG.
  static const double coverScale = 1.18;

  static const Color fallbackAccent = Color(0xFF8BC34A);
  static const String orangeDiamondWebWidget = 'widget:orange-diamond-web';

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

  /// Separate assets used by the first ten horizontal backgrounds. Those
  /// backgrounds no longer contain baked-in contact icons.
  static bool hasSeparateTemplateIcons(
    String? templateId, {
    required bool isFront,
  }) => isFront && _templateIconAssets.containsKey(templateId);

  static String? templateIconAssetFor(
    String? templateId,
    VisitingCardOverlayField iconField, {
    required bool isFront,
  }) {
    if (!isFront) return null;
    return _templateIconAssets[templateId]?[iconField];
  }

  /// Template 7's original symbols are white glyphs without a badge.
  static Color? templateIconTintFor(
    String? templateId, {
    required bool isFront,
  }) => isFront && templateId == 'h7' ? Colors.white : null;

  /// Fallback accent used if the template image cannot be sampled.
  static Color accentFor(VisitingCardSidePositions side) =>
      side.name?.lastNameColor ??
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
    required bool isFront,
  }) {
    final templateOverrides = isFront ? _overrides[templateId] : null;
    if (templateOverrides != null) return templateOverrides[iconField];

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
  /// Pixel-measured from template PNGs (square size = fraction of card width).
  static const _overrides =
      <String, Map<VisitingCardOverlayField, VisitingCardFieldPosition>>{
        'h1': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0765,
            top: 0.4385,
            size: 0.044,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0765,
            top: 0.5374,
            size: 0.044,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0765,
            top: 0.6364,
            size: 0.044,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0765,
            top: 0.7353,
            size: 0.044,
          ),
        },
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
        'h3': {
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.5505,
            top: 0.4439,
            size: 0.052,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.5505,
            top: 0.5682,
            size: 0.052,
          ),
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.5505,
            top: 0.6939,
            size: 0.052,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.5505,
            top: 0.8182,
            size: 0.052,
          ),
        },
        'h4': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.5040,
            size: 0.039,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.6149,
            size: 0.039,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.7273,
            size: 0.039,
          ),
        },
        'h5': {
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.4385,
            size: 0.0466,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.5508,
            size: 0.0466,
          ),
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.6631,
            size: 0.0466,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0703,
            top: 0.7754,
            size: 0.0466,
          ),
        },
        'h6': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.5375,
            top: 0.4733,
            size: 0.050,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.5375,
            top: 0.5874,
            size: 0.050,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.5375,
            top: 0.6992,
            size: 0.050,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.5375,
            top: 0.8142,
            size: 0.050,
          ),
        },
        'h7': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0500,
            top: 0.4560,
            size: 0.035,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0500,
            top: 0.5390,
            size: 0.035,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0500,
            top: 0.6190,
            size: 0.035,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0500,
            top: 0.7030,
            size: 0.035,
          ),
        },
        'h8': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0650,
            top: 0.4160,
            size: 0.042,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0650,
            top: 0.5294,
            size: 0.042,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0650,
            top: 0.6444,
            size: 0.042,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0650,
            top: 0.7594,
            size: 0.042,
          ),
        },
        'h9': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0757,
            top: 0.5190,
            size: 0.040,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0757,
            top: 0.6120,
            size: 0.040,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0757,
            top: 0.7070,
            size: 0.040,
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0757,
            top: 0.8000,
            size: 0.040,
          ),
        },
        'h10': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0306,
            top: 0.5340,
            size: 0.032,
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0306,
            top: 0.6490,
            size: 0.032,
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0306,
            top: 0.7430,
            size: 0.032,
          ),
        },
      };

  static const _templateIconAssets = <String, Map<VisitingCardOverlayField, String>>{
    'h1': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/orange_filled_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/orange_filled_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/orange_filled_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/orange_filled_location.png',
    },
    'h2': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/lime_filled_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/lime_filled_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/lime_filled_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/lime_filled_location.png',
    },
    'h3': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/red_filled_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/red_filled_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/red_filled_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/red_filled_location.png',
    },
    'h4': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/green_diamond_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/green_diamond_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/green_diamond_location.png',
    },
    'h5': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/blue_filled_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/blue_filled_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/blue_filled_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/blue_filled_location.png',
    },
    'h6': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/orange_diamond_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/orange_diamond_email.png',
      VisitingCardOverlayField.websiteIcon: orangeDiamondWebWidget,
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/orange_diamond_location.png',
    },
    'h7': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/black_smartphone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/black_phone_detail.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/black_email.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/black_web.png',
    },
    'h8': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/orange_ring_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/orange_ring_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/orange_ring_link.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/orange_ring_location.png',
    },
    'h9': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/red_filled_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/red_filled_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/red_filled_web_alt.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/red_filled_location_alt.png',
    },
    'h10': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h10_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/black_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/black_web.png',
    },
  };
}
