import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';

/// One row in the landscape Font style list.
class VisitingCardFontPreset {
  const VisitingCardFontPreset({
    required this.family,
    required this.weight,
    required this.uppercase,
    this.letterSpacing = 0,
    this.previewFontSize = 16,
  });

  final String family;
  final FontWeight weight;
  final bool uppercase;
  final double letterSpacing;
  final double previewFontSize;

  bool get bold => weight.value >= FontWeight.w600.value;

  static const presets = <VisitingCardFontPreset>[
    VisitingCardFontPreset(family: 'Inter', weight: FontWeight.w400, uppercase: false),
    VisitingCardFontPreset(
      family: 'Playfair Display',
      weight: FontWeight.w400,
      uppercase: false,
    ),
    VisitingCardFontPreset(family: 'Inter', weight: FontWeight.w700, uppercase: false),
    VisitingCardFontPreset(family: 'Inter', weight: FontWeight.w700, uppercase: true),
    VisitingCardFontPreset(
      family: 'Oswald',
      weight: FontWeight.w600,
      uppercase: true,
      letterSpacing: 1.4,
    ),
    VisitingCardFontPreset(
      family: 'Press Start 2P',
      weight: FontWeight.w400,
      uppercase: true,
      previewFontSize: 9,
    ),
    VisitingCardFontPreset(family: 'Roboto', weight: FontWeight.w400, uppercase: false),
    VisitingCardFontPreset(family: 'Montserrat', weight: FontWeight.w500, uppercase: false),
    VisitingCardFontPreset(family: 'Poppins', weight: FontWeight.w500, uppercase: false),
    VisitingCardFontPreset(family: 'Lato', weight: FontWeight.w400, uppercase: false),
    VisitingCardFontPreset(family: 'Raleway', weight: FontWeight.w500, uppercase: false),
    VisitingCardFontPreset(family: 'Nunito', weight: FontWeight.w600, uppercase: false),
    VisitingCardFontPreset(family: 'Josefin Sans', weight: FontWeight.w500, uppercase: false),
    VisitingCardFontPreset(family: 'Merriweather', weight: FontWeight.w400, uppercase: false),
    VisitingCardFontPreset(
      family: 'Libre Baskerville',
      weight: FontWeight.w400,
      uppercase: false,
    ),
    VisitingCardFontPreset(
      family: 'Cormorant Garamond',
      weight: FontWeight.w500,
      uppercase: false,
      previewFontSize: 18,
    ),
    VisitingCardFontPreset(
      family: 'Cinzel',
      weight: FontWeight.w600,
      uppercase: true,
    ),
    VisitingCardFontPreset(
      family: 'Bebas Neue',
      weight: FontWeight.w400,
      uppercase: true,
      letterSpacing: 1.2,
    ),
    VisitingCardFontPreset(family: 'Anton', weight: FontWeight.w400, uppercase: true),
    VisitingCardFontPreset(
      family: 'Dancing Script',
      weight: FontWeight.w400,
      uppercase: false,
      previewFontSize: 18,
    ),
    VisitingCardFontPreset(
      family: 'Pacifico',
      weight: FontWeight.w400,
      uppercase: false,
    ),
    VisitingCardFontPreset(
      family: 'Lobster',
      weight: FontWeight.w400,
      uppercase: false,
      previewFontSize: 18,
    ),
    VisitingCardFontPreset(
      family: 'Great Vibes',
      weight: FontWeight.w400,
      uppercase: false,
      previewFontSize: 20,
    ),
    VisitingCardFontPreset(family: 'Comfortaa', weight: FontWeight.w500, uppercase: false),
    VisitingCardFontPreset(family: 'Special Elite', weight: FontWeight.w400, uppercase: false),
  ];

  static VisitingCardFontPreset? of(int? index) {
    if (index == null || index < 0 || index >= presets.length) return null;
    return presets[index];
  }
}

/// Preview row: `01.` plus the selected field's own text.
String visitingCardFontPresetLabel(
  int index,
  VisitingCardFontPreset preset,
  String sample,
) {
  final trimmed = sample.trim();
  final name = trimmed.isEmpty
      ? ''
      : (preset.uppercase ? trimmed.toUpperCase() : trimmed);
  final number = (index + 1).toString().padLeft(2, '0');
  if (name.isEmpty) return '$number.';
  return '$number. $name';
}

String visitingCardStyledText(
  String raw,
  VisitingCardFieldTransform t, {
  required bool templateUppercase,
}) {
  final preset = VisitingCardFontPreset.of(t.fontPreset);
  final upper = preset?.uppercase ?? templateUppercase;
  return upper ? raw.toUpperCase() : raw;
}

TextStyle visitingCardGoogleStyle(String family, TextStyle style) {
  final resolved = GoogleFonts.getFont(family, textStyle: style);
  return resolved.copyWith(
    fontFamilyFallback: [
      ...?resolved.fontFamilyFallback,
      'sans-serif',
    ],
  );
}

/// Applies a field's font preset and B / I / U / strike on top of [base].
TextStyle applyVisitingCardFont(TextStyle base, VisitingCardFieldTransform t) {
  if (!t.hasFontOverride) return base;
  final preset = VisitingCardFontPreset.of(t.fontPreset);
  final templateWeight = base.fontWeight ?? FontWeight.w400;
  final templateStyle = base.fontStyle ?? FontStyle.normal;
  final weight = switch (t.fontBoldMode) {
    1 => FontWeight.w700,
    2 => FontWeight.w400,
    _ => preset?.weight ?? templateWeight,
  };
  final italic = switch (t.fontItalicMode) {
    1 => FontStyle.italic,
    2 => FontStyle.normal,
    _ => templateStyle,
  };
  final decorations = <TextDecoration>[
    if (t.fontUnderline) TextDecoration.underline,
    if (t.fontStrike) TextDecoration.overline,
  ];
  var style = base.copyWith(
    fontWeight: weight,
    fontStyle: italic,
    letterSpacing: (base.letterSpacing ?? 0) + (preset?.letterSpacing ?? 0),
    decoration: decorations.isEmpty
        ? TextDecoration.none
        : TextDecoration.combine(decorations),
    decorationColor: base.color,
  );
  final family = preset?.family;
  if (family != null) style = visitingCardGoogleStyle(family, style);
  return style;
}
