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
  static const String limeEmailWidget = 'widget:email-lime';
  static const String orangeEmailWidget = 'widget:email-orange';
  static const String navyOutlineEmailWidget = 'widget:email-navy-outline';
  static const String greenOutlineEmailWidget = 'widget:email-green-outline';
  static const String blueEmailWidget = 'widget:email-blue';

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
    // The add-card scratch editor starts with a plain canvas and no template
    // contact icons. Choosing a real template replaces this id and restores
    // its configured icon overlays.
    if (templateId == 'scratch') return null;

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
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.0485,
            top: 0.4130,
            size: 0.032,
            color: Color(0xFF414141),
          ),
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.0485,
            top: 0.5400,
            size: 0.032,
            color: Color(0xFF414141),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.0485,
            top: 0.6520,
            size: 0.032,
            color: Color(0xFF414141),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.0485,
            top: 0.7440,
            size: 0.032,
            color: Color(0xFF414141),
          ),
        },
        'h11': {
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.906,
            top: 0.462,
            size: 0.054,
            color: Color(0xFF00BDF2),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.906,
            top: 0.575,
            size: 0.054,
            color: Color(0xFF009DDA),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.906,
            top: 0.688,
            size: 0.054,
            color: Color(0xFF0063B0),
          ),
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.906,
            top: 0.800,
            size: 0.054,
            color: Color(0xFF0063B0),
          ),
        },
        'h12': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.874,
            top: 0.532,
            size: 0.026,
            color: Color(0xFF59BA47),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.874,
            top: 0.620,
            size: 0.026,
            color: Color(0xFF59BA47),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.874,
            top: 0.724,
            size: 0.026,
            color: Color(0xFF59BA47),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.874,
            top: 0.810,
            size: 0.026,
            color: Color(0xFF59BA47),
          ),
        },
        'h13': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.831,
            top: 0.431,
            size: 0.052,
            color: Color(0xFF032C40),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.831,
            top: 0.555,
            size: 0.047,
            color: Color(0xFF032C40),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.831,
            top: 0.680,
            size: 0.052,
            color: Color(0xFF032C40),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.831,
            top: 0.804,
            size: 0.052,
            color: Color(0xFF032C40),
          ),
        },
        'h14': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.468,
            top: 0.478,
            size: 0.041,
            color: Color(0xFF358DCC),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.468,
            top: 0.575,
            size: 0.041,
            color: Color(0xFF358DCC),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.468,
            top: 0.679,
            size: 0.041,
            color: Color(0xFF358DCC),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.468,
            top: 0.776,
            size: 0.043,
            color: Color(0xFF358DCC),
          ),
        },
        'h15': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.052,
            top: 0.375,
            size: 0.032,
            color: Color(0xFFFBAA19),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.052,
            top: 0.495,
            size: 0.032,
            color: Color(0xFFFBAA19),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.052,
            top: 0.612,
            size: 0.032,
            color: Color(0xFFFBAA19),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.052,
            top: 0.728,
            size: 0.032,
            color: Color(0xFFFBAA19),
          ),
        },
        'h16': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.519,
            top: 0.246,
            size: 0.042,
            color: Color(0xFF3A9808),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.519,
            top: 0.353,
            size: 0.042,
            color: Color(0xFF3A9808),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.519,
            top: 0.459,
            size: 0.042,
            color: Color(0xFF3A9808),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.519,
            top: 0.565,
            size: 0.042,
            color: Color(0xFF3A9808),
          ),
        },
        'h17': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.071,
            top: 0.512,
            size: 0.053,
            color: Color(0xFFF50302),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.071,
            top: 0.654,
            size: 0.053,
            color: Color(0xFFF50302),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.071,
            top: 0.794,
            size: 0.053,
            color: Color(0xFFF50302),
          ),
        },
        'h18': {
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.899,
            top: 0.508,
            size: 0.045,
            color: Color(0xFF76BC43),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.899,
            top: 0.610,
            size: 0.045,
            color: Color(0xFF76BC43),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.899,
            top: 0.712,
            size: 0.045,
            color: Color(0xFF76BC43),
          ),
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.899,
            top: 0.810,
            size: 0.045,
            color: Color(0xFF76BC43),
          ),
        },
        'h19': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.534,
            top: 0.472,
            size: 0.077,
            color: Color(0xFFF50302),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.534,
            top: 0.649,
            size: 0.077,
            color: Color(0xFFF50302),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.534,
            top: 0.827,
            size: 0.077,
            color: Color(0xFFF50302),
          ),
        },
        'h20': {
          VisitingCardOverlayField.phoneIcon: VisitingCardFieldPosition(
            left: 0.132,
            top: 0.472,
            size: 0.034,
            color: Color(0xFF20438D),
          ),
          VisitingCardOverlayField.websiteIcon: VisitingCardFieldPosition(
            left: 0.132,
            top: 0.594,
            size: 0.034,
            color: Color(0xFF20438D),
          ),
          VisitingCardOverlayField.emailIcon: VisitingCardFieldPosition(
            left: 0.132,
            top: 0.710,
            size: 0.034,
            color: Color(0xFF20438D),
          ),
          VisitingCardOverlayField.addressIcon: VisitingCardFieldPosition(
            left: 0.132,
            top: 0.813,
            size: 0.034,
            color: Color(0xFF20438D),
          ),
        },
      };

  static const _templateIconAssets = <String, Map<VisitingCardOverlayField, String>>{
    'h1': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h1_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h1_mail.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h1_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h1_location.png',
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
          'assets/images/visiting_card_contact_icons/red_filled_phone_alt.png',
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
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/orange_diamond_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/orange_diamond_location.png',
    },
    'h7': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/black_phone_detail.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/black_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/black_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/black_location.png',
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
          'assets/images/visiting_card_contact_icons/red_filled_email_alt.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/red_filled_web_alt.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/red_filled_location_alt.png',
    },
    'h10': {
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h10_location.png',
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h10_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/black_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/black_web.png',
    },
    'h11': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h11_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h11_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h11_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h11_location.png',
    },
    'h12': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h12_phone.png',
      VisitingCardOverlayField.emailIcon: limeEmailWidget,
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h12_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h12_location.png',
    },
    'h13': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h13_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h13_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h13_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h13_location.png',
    },
    'h14': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h14_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h14_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h14_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h14_location.png',
    },
    'h15': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h15_phone.png',
      VisitingCardOverlayField.emailIcon: orangeEmailWidget,
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h15_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h15_location.png',
    },
    'h16': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h16_phone.png',
      VisitingCardOverlayField.emailIcon: greenOutlineEmailWidget,
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h16_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h16_location.png',
    },
    'h17': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h17_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h17_email.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h17_location.png',
    },
    'h18': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h18_phone.png',
      VisitingCardOverlayField.emailIcon:
          'assets/images/visiting_card_contact_icons/h18_email.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h18_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h18_location.png',
    },
    'h19': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h19_phone.png',
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h19_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h19_location.png',
    },
    'h20': {
      VisitingCardOverlayField.phoneIcon:
          'assets/images/visiting_card_contact_icons/h20_phone.png',
      VisitingCardOverlayField.emailIcon: blueEmailWidget,
      VisitingCardOverlayField.websiteIcon:
          'assets/images/visiting_card_contact_icons/h20_web.png',
      VisitingCardOverlayField.addressIcon:
          'assets/images/visiting_card_contact_icons/h20_location.png',
    },
  };
}
