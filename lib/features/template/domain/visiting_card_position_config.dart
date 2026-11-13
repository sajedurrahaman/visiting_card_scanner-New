import 'package:flutter/material.dart';

/// Font families used by visiting-card templates.
class VisitingCardFonts {
  static const sfPro = 'SF Pro';
  static const sfProText = 'SF Pro Text';
  static const inter = 'Inter';
  static const roboto = 'Roboto';
  static const montserrat = 'Montserrat';
}

/// One field's box on the visiting card.
///
/// All [left]/[top]/[right]/[bottom]/[width]/[height]/[size] values
/// are **fractions of the card size** (0.0 – 1.0).
///
/// Example: `left: 0.06` = 6% from left edge of the card.
///
/// For logo / QR, prefer [size] (square box = card width × size).
/// When [size] is set it overrides [width] / [height].
class VisitingCardFieldPosition {
  const VisitingCardFieldPosition({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.size,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w400,
    this.fontStyle = FontStyle.normal,
    this.color = const Color(0xFF1A1A1A),
    this.firstNameColor,
    this.lastNameColor,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.uppercase = false,
    this.letterSpacing = 0,
    this.heightFactor = 1.15,
    this.maxDisplayNameLength = 16,
    this.threeWordFontSize = 10,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  /// Square size for logo / QR — fraction of card **width** (0.0 – 1.0).
  /// Example: `size: 0.14` → box is 14% of card width on both sides.
  final double? size;

  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;

  /// Full-name color (also fallback when first/last not set).
  final Color color;

  /// Optional — first word of Name (e.g. EMMA).
  /// When set with [lastNameColor], name is split into two colors.
  final Color? firstNameColor;

  /// Optional — remaining words of Name (e.g. WILSON).
  final Color? lastNameColor;

  final TextAlign textAlign;
  final int maxLines;
  final bool uppercase;
  final double letterSpacing;
  final double heightFactor;

  /// Max characters shown for Name on this template field (avoids overflow).
  /// Override per name [VisitingCardFieldPosition] when a layout needs more/less.
  final int maxDisplayNameLength;

  /// Font size when the clipped name has 3+ words.
  final double threeWordFontSize;

  bool get hasSplitNameColors =>
      firstNameColor != null || lastNameColor != null;

  /// Truncates [rawName] to [maxDisplayNameLength] for card preview/export.
  String clipDisplayName(String rawName) {
    final trimmed = rawName.trim();
    final max = maxDisplayNameLength < 1 ? 1 : maxDisplayNameLength;
    if (trimmed.length <= max) return trimmed;
    return trimmed.substring(0, max);
  }

  /// Shrinks name text when it has three or more words so it stays on one line.
  double resolvedNameFontSize(String rawName) {
    final wordCount = clipDisplayName(
      rawName,
    ).split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    if (wordCount >= 3) return threeWordFontSize;
    return fontSize;
  }
}

/// Front or back side field positions for one template.
class VisitingCardSidePositions {
  const VisitingCardSidePositions({
    this.name,
    this.designation,
    this.company,
    this.tagline,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.logo,
    this.qr,
  });

  final VisitingCardFieldPosition? name;
  final VisitingCardFieldPosition? designation;
  final VisitingCardFieldPosition? company;

  /// Tag line (back side).
  final VisitingCardFieldPosition? tagline;
  final VisitingCardFieldPosition? phone;
  final VisitingCardFieldPosition? email;
  final VisitingCardFieldPosition? website;

  /// Location / address.
  final VisitingCardFieldPosition? address;
  final VisitingCardFieldPosition? logo;
  final VisitingCardFieldPosition? qr;
}

/// Front + back layout for one template.
class VisitingCardTemplatePositions {
  const VisitingCardTemplatePositions({
    required this.front,
    required this.back,
    this.fontFamily = VisitingCardFonts.sfPro,
  });

  final VisitingCardSidePositions front;
  final VisitingCardSidePositions back;

  /// Template-wide font (SF Pro / SF Pro Text / Inter / Roboto).
  final String fontFamily;
}

/// Manual position map — **edit each template block separately**.
///
/// Template ids: horizontal `h1`…`h20`, vertical `v1`…`v21`.
class VisitingCardPositionConfig {
  VisitingCardPositionConfig._();

  static VisitingCardTemplatePositions forTemplate({
    required String templateId,
    required bool isHorizontal,
  }) {
    if (isHorizontal) {
      return switch (templateId) {
        'h1' => horizontalTemplate1,
        'h2' => horizontalTemplate2,
        'h3' => horizontalTemplate3,
        'h4' => horizontalTemplate4,
        'h5' => horizontalTemplate5,
        'h6' => horizontalTemplate6,
        'h7' => horizontalTemplate7,
        'h8' => horizontalTemplate8,
        'h9' => horizontalTemplate9,
        'h10' => horizontalTemplate10,
        'h11' => horizontalTemplate11,
        'h12' => horizontalTemplate12,
        'h13' => horizontalTemplate13,
        'h14' => horizontalTemplate14,
        'h15' => horizontalTemplate15,
        'h16' => horizontalTemplate16,
        'h17' => horizontalTemplate17,
        'h18' => horizontalTemplate18,
        'h19' => horizontalTemplate19,
        'h20' => horizontalTemplate20,
        _ => horizontalTemplate1,
      };
    }
    return switch (templateId) {
      'v1' => verticalTemplate1,
      'v2' => verticalTemplate2,
      'v3' => verticalTemplate3,
      'v4' => verticalTemplate4,
      'v5' => verticalTemplate5,
      'v6' => verticalTemplate6,
      'v7' => verticalTemplate7,
      'v8' => verticalTemplate8,
      'v9' => verticalTemplate9,
      'v10' => verticalTemplate10,
      'v11' => verticalTemplate11,
      'v12' => verticalTemplate12,
      'v13' => verticalTemplate13,
      'v14' => verticalTemplate14,
      'v15' => verticalTemplate15,
      'v16' => verticalTemplate16,
      'v17' => verticalTemplate17,
      'v18' => verticalTemplate18,
      'v19' => verticalTemplate19,
      'v20' => verticalTemplate20,
      'v21' => verticalTemplate21,
      _ => verticalTemplate1,
    };
  }

  // ===========================================================================
  // HORIZONTAL TEMPLATE 1  (h1)
  // ===========================================================================

  /// Horizontal template front part - 1
  /// Name / Designation / Phone / Email / Web / Location
  ///
  /// Horizontal template back part - 1
  /// Logo / Tag line / QR code
  static const horizontalTemplate1 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.sfProText,
    front: VisitingCardSidePositions(
      // Name — first black, last orange
      name: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.14,
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        firstNameColor: Color(0xFF1A1A1A),
        lastNameColor: Color(0xFFF5A623),
        maxDisplayNameLength: 20,
        threeWordFontSize: 11.5,
      ),
      // Designation
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.23,
        width: 0.48,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B6B6B),
      ),
      // Phone
      phone: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.44,
        width: 0.40,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
      // Email
      email: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.545,
        width: 0.40,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
      // Web
      website: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.645,
        width: 0.40,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
      // Location
      address: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.745,
        width: 0.50,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (centered)
      logo: VisitingCardFieldPosition(
        left: 0.35, // (1 - 0.14) / 2
        top: 0.11,
        size: 0.27,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.37,
        top: 0.47,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.41, // (1 - 0.18) / 2
        top: 0.52,
        size: 0.14,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 2  (h2)
  // ===========================================================================

  /// Horizontal template front part - 2
  /// Horizontal template back part - 2
  static const horizontalTemplate2 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Logo (top-left)
      logo: VisitingCardFieldPosition(left: 0.29, top: 0.05, size: 0.16),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.30,
        top: 0.28,
        width: 0.40,
        fontSize: 3.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6B6B6B),
        uppercase: true,
      ),
      // Name — both black
      name: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.38,
        width: 0.48,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: false,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.47,
        width: 0.40,
        fontSize: 6,
        color: Color(0xFF8BC34A),
        uppercase: true,
      ),
      // Location (1st icon — map pin)
      address: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.16,
        width: 0.32,
        fontSize: 7,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
      email: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.305,
        width: 0.34,
        fontSize: 7,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.42,
        width: 0.34,
        fontSize: 7,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      // Website (4th / globe icon)
      website: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.52,
        width: 0.34,
        fontSize: 7,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(left: 0.40, top: 0.11, size: 0.19),
      tagline: VisitingCardFieldPosition(
        left: 0.41,
        top: 0.38,
        fontSize: 4,
        color: Color(0xFF404040),
        uppercase: true,
        fontWeight: FontWeight.w700,
      ),
      qr: VisitingCardFieldPosition(left: 0.43, top: 0.41, size: 0.12),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 3  (h3)
  // ===========================================================================

  /// Horizontal template front part - 3
  /// Horizontal template back part - 3
  static const horizontalTemplate3 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Logo (left black panel)
      logo: VisitingCardFieldPosition(left: 0.05, top: 0.10, size: 0.12),
      // company: VisitingCardFieldPosition(
      //   left: 0.03,
      //   top: 0.26,
      //   fontSize: 6,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFFFFFFFF),
      //   maxLines:2,
      //
      // ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.056,
        top: 0.265,
        width: 0.24,
        fontSize: 3,
        color: Color(0xFFFFFFFF),
        uppercase: true,
      ),
      // Name — right white
      name: VisitingCardFieldPosition(
        left: 0.555,
        top: 0.19,
        width: 0.52,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: false,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 19,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.555,
        top: 0.29,
        width: 0.50,
        fontSize: 6.5,
        color: Color(0xFFE53935),
        uppercase: true,
      ),
      // Icon serial (top → bottom): Address → Email → Phone → Website
      address: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.44,
        width: 0.38,
        fontSize: 7,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
      email: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.59,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.72,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.84,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (right white panel)
      logo: VisitingCardFieldPosition(left: 0.60, top: 0.20, size: 0.24),
      // company: VisitingCardFieldPosition(
      //   left: 0.54,
      //   top: 0.48,
      //   width: 0.46,
      //   fontSize: 13,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.52,
        width: 0.46,
        fontSize: 6,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.63, top: 0.58, size: 0.16),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 4  (h4)
  // ===========================================================================

  /// Horizontal template front part - 4
  /// Horizontal template back part - 4
  static const horizontalTemplate4 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Name — white (on green left)
      name: VisitingCardFieldPosition(
        left: 0.04,
        top: 0.08,
        width: 0.40,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: false,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.04,
        top: 0.17,
        fontSize: 6.5,
        color: Color(0xFFFFFFFF),
        uppercase: false,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.51,
        width: 0.32,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      email: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.625,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.735,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        maxLines: 3,
      ),
      // Logo (right white)
      logo: VisitingCardFieldPosition(left: 0.66, top: 0.08, size: 0.24),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.675,
        top: 0.40,
        width: 0.38,
        fontSize: 5.5,
        color: Color(0xFF6B6B6B),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.73, top: 0.725, size: 0.12),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline (left stack; QR optional)
      logo: VisitingCardFieldPosition(left: 0.10, top: 0.14, size: 0.28),
      tagline: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.52,
        width: 0.40,
        fontSize: 5.5,
        letterSpacing: 0.5,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      website: VisitingCardFieldPosition(
        left: 0.52,
        top: 0.81,
        width: 0.36,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 5  (h5)
  // ===========================================================================

  /// Horizontal template front part - 5
  /// Horizontal template back part - 5
  static const horizontalTemplate5 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Name — left white
      name: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.08,
        width: 0.45,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: false,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.20,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF2196F3),
      ),
      address: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.42,
        width: 0.36,
        fontSize: 7,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
      email: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.57,
        width: 0.36,
        fontSize: 7,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.68,
        width: 0.36,
        fontSize: 7,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.80,
        width: 0.36,
        fontSize: 7,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      // Logo (right dark panel)
      logo: VisitingCardFieldPosition(left: 0.68, top: 0.20, size: 0.18),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.695,
        top: 0.45,
        width: 0.34,
        fontSize: 4,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.695, top: 0.51, size: 0.14),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (dark bg)
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.26, size: 0.25),
      tagline: VisitingCardFieldPosition(
        left: 0.405,
        top: 0.55,
        width: 0.80,
        fontSize: 5,
        letterSpacing: 0.5,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 1  (v1)
  // ===========================================================================

  /// Vertical template front part - 1
  /// Name / Designation / Phone / Email / Web / Location
  ///
  /// Vertical template back part - 1
  /// Logo / Tag line / QR code
  static const verticalTemplate1 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Name — dark teal
      name: VisitingCardFieldPosition(
        left: 0.118,
        top: 0.06,
        width: 0.84,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        letterSpacing: 0.4,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF0D4F4C),
        maxDisplayNameLength: 22,
        threeWordFontSize: 16,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.118,
        top: 0.12,
        width: 0.84,
        fontSize: 11,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.225,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.29,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.423,
        width: 0.50,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.345,
        width: 0.50,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 4,
      ),
      // Logo (bottom dark branding)
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.68, size: 0.30),
      // Company
      // company: VisitingCardFieldPosition(
      //   left: 0.10,
      //   top: 0.82,
      //   width: 0.80,
      //   fontSize: 14,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFFFFFFFF),
      //   textAlign: TextAlign.center,
      // ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.835,
        width: 0.80,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (dark bg)
      logo: VisitingCardFieldPosition(left: 0.285, top: 0.24, size: 0.44),
      // company: VisitingCardFieldPosition(
      //   left: 0.08,
      //   top: 0.28,
      //   width: 0.84,
      //   fontSize: 16,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFFFFFFFF),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.455,
        width: 0.84,
        fontSize: 8,
        letterSpacing: 0.4,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.495, size: 0.20),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 2  (v2)
  // ===========================================================================

  /// Vertical template front part - 2
  /// Vertical template back part - 2
  static const verticalTemplate2 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Logo (top center)
      logo: VisitingCardFieldPosition(left: 0.36, top: 0.02, size: 0.28),
      // Company
      // company: VisitingCardFieldPosition(
      //   left: 0.38,
      //   top: 0.155,
      //   width: 0.80,
      //   fontSize: 15,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.16,
        width: 0.80,
        fontSize: 7,
        color: Color(0xFF1A1A1A),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      // Name
      name: VisitingCardFieldPosition(
        left: 0.136,
        top: 0.285,
        width: 0.84,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        letterSpacing: 0.4,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF2076FD),
        maxDisplayNameLength: 22,
        threeWordFontSize: 16,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.135,
        top: 0.335,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.434,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.48,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.525,
        width: 0.60,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(left: 0.275, top: 0.30, size: 0.48),
      // company: VisitingCardFieldPosition(
      //   left: 0.08,
      //   top: 0.49,
      //   width: 0.84,
      //   fontSize: 17,
      //   fontWeight: FontWeight.w700,
      //   letterSpacing: 0.4,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.29,
        top: 0.535,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF404040),
        letterSpacing: 0.4,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.56, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 3  (v3)
  // ===========================================================================

  /// Vertical template front part - 3
  /// Vertical template back part - 3
  static const verticalTemplate3 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.roboto,
    front: VisitingCardSidePositions(
      // Name
      name: VisitingCardFieldPosition(
        left: 0.068,
        top: 0.19,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: true,
        firstNameColor: Color(0xFF606060),
        lastNameColor: Color(0xFF713954),
        maxDisplayNameLength: 22,
        threeWordFontSize: 16,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.068,
        top: 0.24,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.38,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF606060),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.48,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF606060),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.57,
        width: 0.60,
        fontSize: 10,
        color: Color(0xFF606060),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(left: 0.285, top: 0.34, size: 0.44),
      // company: VisitingCardFieldPosition(
      //   left: 0.08,
      //   top: 0.49,
      //   width: 0.84,
      //   fontSize: 20,
      //   fontWeight: FontWeight.w700,
      //   letterSpacing: 0.4,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.325,
        top: 0.55,
        width: 0.84,
        fontSize: 9,
        color: Color(0xFF404040),
        letterSpacing: 0.5,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.59, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 4  (v4)
  // ===========================================================================

  /// Vertical template front part - 4
  /// Vertical template back part - 4
  static const verticalTemplate4 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Logo (top center)
      logo: VisitingCardFieldPosition(left: 0.36, top: 0.02, size: 0.28),
      // Company
      // company: VisitingCardFieldPosition(
      //   left: 0.38,
      //   top: 0.155,
      //   width: 0.80,
      //   fontSize: 15,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.16,
        width: 0.80,
        fontSize: 7,
        color: Color(0xFF1A1A1A),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      // Name
      name: VisitingCardFieldPosition(
        left: 0.136,
        top: 0.285,
        width: 0.84,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        letterSpacing: 0.4,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF6ACA2B),
        maxDisplayNameLength: 22,
        threeWordFontSize: 16,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.135,
        top: 0.335,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.434,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.48,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.21,
        top: 0.525,
        width: 0.60,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(left: 0.275, top: 0.30, size: 0.48),
      // company: VisitingCardFieldPosition(
      //   left: 0.08,
      //   top: 0.49,
      //   width: 0.84,
      //   fontSize: 17,
      //   fontWeight: FontWeight.w700,
      //   letterSpacing: 0.4,
      //   uppercase: true,
      //   color: Color(0xFF1A1A1A),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.29,
        top: 0.535,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF404040),
        letterSpacing: 0.4,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.56, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 5  (v5)
  // ===========================================================================

  /// Vertical template front part - 5
  /// Vertical template back part - 5
  static const verticalTemplate5 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      // Logo (top)
      logo: VisitingCardFieldPosition(left: 0.36, top: 0.72, size: 0.25),
      // company: VisitingCardFieldPosition(
      //   left: 0.10,
      //   top: 0.84,
      //   width: 0.80,
      //   fontSize: 16,
      //   fontWeight: FontWeight.w700,
      //   uppercase: true,
      //   color: Color(0xFFFFFFFF),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.87,
        width: 0.80,
        fontSize: 7.5,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.03,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 22,
        threeWordFontSize: 16,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.075,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF1A1A1A),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.24,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF1A1A1A),
      ),
      email: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.31,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF1A1A1A),
      ),
      website: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.37,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF1A1A1A),
      ),
      address: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.43,
        width: 0.60,
        fontSize: 10,
        color: Color(0xFF1A1A1A),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.32, size: 0.34),
      // company: VisitingCardFieldPosition(
      //   left: 0.08,
      //   top: 0.49,
      //   width: 0.84,
      //   fontSize: 20,
      //   fontWeight: FontWeight.w700,
      //   letterSpacing: 0.4,
      //   uppercase: true,
      //   color: Color(0xFFFFFFFF),
      //   textAlign: TextAlign.center,
      // ),
      tagline: VisitingCardFieldPosition(
        left: 0.345,
        top: 0.515,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        letterSpacing: 0.4,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.57, size: 0.20),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 6  (h6) — front logo, back QR
  // ===========================================================================

  static const horizontalTemplate6 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.16, top: 0.16, size: 0.20),
      tagline: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.32,
        fontSize: 6,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.537,
        top: 0.19,
        width: 0.52,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        uppercase: false,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.537,
        top: 0.28,
        width: 0.50,
        fontSize: 8,
        color: Color(0xFFF89A05),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.49,
        width: 0.58,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.605,
        width: 0.58,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.68,
        width: 0.38,
        fontSize: 8,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
      website: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.84,
        width: 0.58,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.24, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.46,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.41, top: 0.54, size: 0.18),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 7  (h7) — front logo, back QR
  // ===========================================================================

  static const horizontalTemplate7 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.15,
        width: 0.42,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.24,
        width: 0.42,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.46,
        width: 0.38,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      email: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.54,
        width: 0.38,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      website: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.62,
        width: 0.38,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.70,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        maxLines: 3,
      ),
      logo: VisitingCardFieldPosition(left: 0.72, top: 0.40, size: 0.22),
      tagline: VisitingCardFieldPosition(
        left: 0.72,
        top: 0.58,
        width: 0.80,
        fontSize: 6,
        color: Color(0xFF404040),
        uppercase: true,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.22, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.44,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.42, top: 0.51, size: 0.18),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 8  (h8) — front logo, no QR
  // ===========================================================================

  static const horizontalTemplate8 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.76, top: 0.42, size: 0.16),
      tagline: VisitingCardFieldPosition(
        left: 0.73,
        top: 0.56,
        width: 0.80,
        fontSize: 6,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.15,
        width: 0.58,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.25,
        width: 0.56,
        fontSize: 8,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.425,
        width: 0.50,
        fontSize: 7.5,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.54,
        width: 0.50,
        fontSize: 7.5,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.66,
        width: 0.50,
        fontSize: 7.5,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.765,
        width: 0.42,
        fontSize: 7.5,
        color: Color(0xFF404040),
        maxLines: 3,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.26, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.47,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.43, top: 0.55, size: 0.18),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 9  (h9) — no front logo, no QR
  // ===========================================================================

  static const horizontalTemplate9 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.12,
        width: 0.52,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        firstNameColor: Color(0xFFF50302),
        lastNameColor: Color(0xFFFFFFFF),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.62,
        top: 0.21,
        width: 0.50,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.52,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.62,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.72,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.81,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.39, top: 0.28, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.48,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.42, top: 0.55, size: 0.18),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 10  (h10) — front logo, no QR
  // ===========================================================================

  static const horizontalTemplate10 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.70, top: 0.32, size: 0.20),
      tagline: VisitingCardFieldPosition(
        left: 0.67,
        top: 0.49,
        width: 0.80,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        uppercase: true,
      ),
      name: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.14,
        width: 0.46,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.24,
        width: 0.44,
        fontSize: 8,
        color: Color(0xFF0D7377),
      ),
      address: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.405,
        width: 0.44,
        fontSize: 8,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.54,
        width: 0.44,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.645,
        width: 0.44,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.75,
        width: 0.44,
        fontSize: 8,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.28, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.48,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.42, top: 0.56, size: 0.18),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 11  (h11) — Inter, front logo + QR, back logo
  // ===========================================================================

  static const horizontalTemplate11 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.16,
        width: 0.42,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.24,
        width: 0.40,
        fontSize: 6,
        color: Color(0xFF00BDF2),
      ),
      logo: VisitingCardFieldPosition(left: 0.72, top: 0.08, size: 0.16),
      tagline: VisitingCardFieldPosition(
        left: 0.70,
        top: 0.28,
        width: 0.26,
        fontSize: 6,
        color: Color(0xFF00BDF2),
      ),
      qr: VisitingCardFieldPosition(left: 0.06, top: 0.62, size: 0.16),
      address: VisitingCardFieldPosition(
        left: 0.50,
        top: 0.46,
        width: 0.39,
        fontSize: 7,
        color: Color(0xFF08296C),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.55,
        top: 0.595,
        width: 0.34,
        fontSize: 7,
        color: Color(0xFF08296C),
        textAlign: TextAlign.right,
      ),
      email: VisitingCardFieldPosition(
        left: 0.55,
        top: 0.71,
        width: 0.34,
        fontSize: 7,
        color: Color(0xFF08296C),
        textAlign: TextAlign.right,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.55,
        top: 0.82,
        width: 0.34,
        fontSize: 7,
        color: Color(0xFF08296C),
        textAlign: TextAlign.right,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.14, top: 0.28, size: 0.20),
      tagline: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.54,
        width: 0.40,
        fontSize: 8,
        color: Color(0xFF00BDF2),
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 12  (h12) — Inter, front QR, back logo
  // ===========================================================================

  static const horizontalTemplate12 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.46,
        top: 0.16,
        width: 0.46,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.46,
        top: 0.28,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF59BA47),
      ),
      qr: VisitingCardFieldPosition(left: 0.06, top: 0.62, size: 0.16),
      phone: VisitingCardFieldPosition(
        left: 0.42,
        top: 0.52,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFFFDFEFF),
        textAlign: TextAlign.right,
      ),
      address: VisitingCardFieldPosition(
        left: 0.44,
        top: 0.60,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFFFDFEFF),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.42,
        top: 0.72,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFFFDFEFF),
        textAlign: TextAlign.right,
      ),
      email: VisitingCardFieldPosition(
        left: 0.42,
        top: 0.80,
        width: 0.42,
        fontSize: 7,
        color: Color(0xFFFDFEFF),
        textAlign: TextAlign.right,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.08, top: 0.42, size: 0.20),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.68,
        width: 0.42,
        fontSize: 8,
        color: Color(0xFF54C12A),
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 13  (h13) — Inter, no front logo/QR, back logo
  // ===========================================================================

  static const horizontalTemplate13 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.20,
        width: 0.70,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF032C40),
        firstNameColor: Color(0xFF032C40),
        lastNameColor: Color(0xFFB4DE00),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.33,
        width: 0.55,
        fontSize: 8,
        uppercase: true,
        color: Color(0xFF032C40),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.45,
        width: 0.46,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
      ),
      email: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.57,
        width: 0.46,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
      ),
      website: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.70,
        width: 0.46,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
      ),
      address: VisitingCardFieldPosition(
        left: 0.40,
        top: 0.81,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.40, top: 0.30, size: 0.22),
      tagline: VisitingCardFieldPosition(
        left: 0.37,
        top: 0.60,
        width: 0.64,
        fontSize: 8,
        uppercase: true,
        color: Color(0xFFB4DE00),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 14  (h14) — Inter, front + back logo, no tagline, no QR
  // ===========================================================================

  static const horizontalTemplate14 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.02, top: 0.09, size: 0.15),
      name: VisitingCardFieldPosition(
        left: 0.47,
        top: 0.16,
        width: 0.52,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF2E2E82),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.47,
        top: 0.28,
        width: 0.50,
        fontSize: 8,
        uppercase: true,
        color: Color(0xFF358DCC),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.53,
        top: 0.49,
        width: 0.46,
        fontSize: 8,
        color: Color(0xFF358DCC),
      ),
      website: VisitingCardFieldPosition(
        left: 0.53,
        top: 0.58,
        width: 0.46,
        fontSize: 8,
        color: Color(0xFF358DCC),
      ),
      email: VisitingCardFieldPosition(
        left: 0.53,
        top: 0.68,
        width: 0.46,
        fontSize: 8,
        color: Color(0xFF358DCC),
      ),
      address: VisitingCardFieldPosition(
        left: 0.53,
        top: 0.78,
        width: 0.46,
        fontSize: 8,
        color: Color(0xFF358DCC),
        maxLines: 3,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.24, size: 0.26),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 15  (h15) — Montserrat, back logo, no QR
  // ===========================================================================

  static const horizontalTemplate15 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.12,
        width: 0.52,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFBAA19),
        maxDisplayNameLength: 22,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.22,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.38,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      email: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.49,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.61,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.74,
        width: 0.48,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.38, top: 0.34, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.62,
        width: 0.56,
        fontSize: 7,
        color: Color(0xFFFBAA19),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 16  (h16) — Inter, back logo only, no QR
  // ===========================================================================

  static const horizontalTemplate16 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.38,
        width: 0.36,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF032C40),
        firstNameColor: Color(0xFF032C40),
        lastNameColor: Color(0xFF348F07),
        maxDisplayNameLength: 24,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.49,
        width: 0.36,
        fontSize: 7,
        uppercase: true,
        color: Color(0xFF032C40),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.58,
        top: 0.26,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.58,
        top: 0.37,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFF032C40),
      ),
      website: VisitingCardFieldPosition(
        left: 0.58,
        top: 0.47,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFF032C40),
      ),
      address: VisitingCardFieldPosition(
        left: 0.58,
        top: 0.57,
        width: 0.40,
        fontSize: 7,
        color: Color(0xFF032C40),
        maxLines: 3,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.42, top: 0.32, size: 0.24),
      tagline: VisitingCardFieldPosition(
        left: 0.42,
        top: 0.62,
        width: 0.64,
        fontSize: 7,
        uppercase: true,
        color: Color(0xFF348F07),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 17  (h17) — Montserrat, front + back logo, no QR
  // ===========================================================================

  static const horizontalTemplate17 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.11,
        width: 0.38,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        firstNameColor: Color(0xFFF50302),
        lastNameColor: Color(0xFFFFFFFF),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.07,
        top: 0.22,
        width: 0.36,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.53,
        width: 0.30,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.67,
        width: 0.30,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.81,
        width: 0.40,
        fontSize: 6,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      logo: VisitingCardFieldPosition(left: 0.70, top: 0.32, size: 0.22),
      tagline: VisitingCardFieldPosition(
        left: 0.72,
        top: 0.61,
        width: 0.42,
        fontSize: 6,
        color: Color(0xFF111525),
        textAlign: TextAlign.center,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.36, top: 0.16, size: 0.28),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.49,
        width: 0.56,
        fontSize: 7,
        color: Color(0xFF111525),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 18  (h18) — Inter, front logo + QR, back logo
  // Website uses its own green.
  // ===========================================================================

  static const horizontalTemplate18 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.08, top: 0.12, size: 0.22),
      name: VisitingCardFieldPosition(
        left: 0.585,
        top: 0.14,
        width: 0.60,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.28,
        width: 0.57,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.right,
      ),
      qr: VisitingCardFieldPosition(left: 0.08, top: 0.66, size: 0.16),
      address: VisitingCardFieldPosition(
        // Narrow the text area while keeping its right edge beside the icon.
        left: 0.57,
        top: 0.51,
        width: 0.30,
        fontSize: 6.5,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.62,
        width: 0.51,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
      ),
      email: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.72,
        width: 0.51,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.82,
        width: 0.51,
        fontSize: 7,
        color: Color(0xFF032C40),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.37, top: 0.40, size: 0.30),
      website: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.76,
        width: 0.64,
        fontSize: 9,
        color: Color(0xFF6CB03D),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 19  (h19) — Montserrat, front QR, back logo
  // ===========================================================================

  static const horizontalTemplate19 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(
          left: 0.118,
          top: 0.52,
          size: 0.15,
      ),
      name: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.08,
        width: 0.46,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0A0A),
        firstNameColor: Color(0xFFF50302),
        lastNameColor: Color(0xFF0A0A0A),
        maxDisplayNameLength: 18,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.19,
        width: 0.40,
        fontSize: 8,
        color: Color(0xFF0A0A0A),
      ),
      qr: VisitingCardFieldPosition(left: 0.78, top: 0.06, size: 0.14),
      phone: VisitingCardFieldPosition(
        left: 0.64,
        top: 0.51,
        width: 0.42,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      address: VisitingCardFieldPosition(
        left: 0.64,
        top: 0.67,
        width: 0.42,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.64,
        top: 0.87,
        width: 0.42,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.28, size: 0.30),
    ),
  );

  // ===========================================================================
  // HORIZONTAL TEMPLATE 20  (h20) — Montserrat, back logo, no tagline, no QR
  // ===========================================================================

  static const horizontalTemplate20 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.135,
        top: 0.08,
        width: 0.62,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 24,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.135,
        top: 0.32,
        width: 0.55,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        uppercase: true,
        color: Color(0xFF20438D),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.475,
        width: 0.50,
        fontSize: 8,
        color: Color(0xFF20438D),
      ),
      website: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.60,
        width: 0.50,
        fontSize: 8,
        color: Color(0xFF20438D),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.705,
        width: 0.50,
        fontSize: 8,
        color: Color(0xFF20438D),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.81,
        width: 0.50,
        fontSize: 8,
        color: Color(0xFF20438D),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.40, top: 0.32, size: 0.30),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 6  (v6) — front logo + front/back QR
  // ===========================================================================

  static const verticalTemplate6 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.22, top: 0.15, size: 0.32),
      tagline: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.245,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.34,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFF1A1A1A),
        maxDisplayNameLength: 22,
        threeWordFontSize: 14,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.26,
        top: 0.385,
        width: 0.80,
        fontSize: 11,
        color: Color(0xFFFC9612),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.485,
        width: 0.62,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.56,
        width: 0.62,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.63,
        width: 0.52,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.705,
        width: 0.40,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.40, size: 0.44),
      tagline: VisitingCardFieldPosition(
        left: 0.35,
        top: 0.53,
        width: 0.84,
        fontSize: 9,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.56, size: 0.24),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 7  (v7) — front logo + front/back QR
  // ===========================================================================

  static const verticalTemplate7 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.13, size: 0.36),
      tagline: VisitingCardFieldPosition(
        left: 0.32,
        top: 0.24,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFF000000),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.555,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFFDEC364),
        maxDisplayNameLength: 22,
        threeWordFontSize: 14,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.28,
        top: 0.60,
        width: 0.80,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.32,
        top: 0.745,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFFFFFFFF),
      ),
      email: VisitingCardFieldPosition(
        left: 0.32,
        top: 0.797,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.32,
        top: 0.845,
        width: 0.46,
        fontSize: 10,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.36, size: 0.44),
      tagline: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.50,
        width: 0.84,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.54, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 8  (v8) — front logo + front/back QR
  // ===========================================================================

  static const verticalTemplate8 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.15,
        top: 0.12,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        firstNameColor: Color(0xFF1A1A1A),
        lastNameColor: Color(0xFF2BBE9B),
        maxDisplayNameLength: 22,
        threeWordFontSize: 14,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.15,
        top: 0.17,
        width: 0.80,
        fontSize: 11,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.245,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.30,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.345,
        width: 0.58,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.78, size: 0.32),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.88,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        uppercase: true,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.30, size: 0.44),
      tagline: VisitingCardFieldPosition(
        left: 0.32,
        top: 0.44,
        width: 0.84,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
        uppercase: true,
      ),
      qr: VisitingCardFieldPosition(left: 0.38, top: 0.48, size: 0.20),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 9  (v9) — front logo + front/back QR
  // ===========================================================================

  static const verticalTemplate9 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.08, size: 0.32),
      tagline: VisitingCardFieldPosition(
        left: 0.35,
        top: 0.18,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.42,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFF6A1B9A),
        maxDisplayNameLength: 22,
        threeWordFontSize: 14,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.465,
        width: 0.80,
        fontSize: 11,
        color: Color(0xFF000000),
      ),
      address: VisitingCardFieldPosition(
        left: 0.30,
        top: 0.54,
        width: 0.58,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.30,
        top: 0.60,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.30,
        top: 0.655,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.30,
        top: 0.705,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.30, size: 0.44),
      tagline: VisitingCardFieldPosition(
        left: 0.34,
        top: 0.44,
        width: 0.84,
        fontSize: 9,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.48, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 10  (v10) — front logo + front/back QR
  // ===========================================================================

  static const verticalTemplate10 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.31,
        top: 0.18,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        color: Color(0xFF044756),
        maxDisplayNameLength: 22,
        threeWordFontSize: 14,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.31,
        top: 0.23,
        width: 0.80,
        fontSize: 11,
        color: Color(0xFF8DC641),
      ),
      email: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.32,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.38,
        width: 0.68,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.44,
        width: 0.50,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.75, size: 0.34),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.32, size: 0.44),
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.46, size: 0.20),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 11  (v11) — Montserrat, back logo + QR, no tagline
  // ===========================================================================

  static const verticalTemplate11 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.15,
        width: 0.80,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF000000),
        firstNameColor: Color(0xFF671F44),
        lastNameColor: Color(0xFF000000),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.20,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF000000),
      ),
      address: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.29,
        width: 0.58,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.365,
        width: 0.68,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.435,
        width: 0.68,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.51,
        width: 0.68,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.30, top: 0.34, size: 0.40),
      qr: VisitingCardFieldPosition(left: 0.36, top: 0.54, size: 0.26),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 12  (v12) — Roboto, front + back logo, no QR
  // ===========================================================================

  static const verticalTemplate12 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.roboto,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.34, top: 0.08, size: 0.36),
      name: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.46,
        width: 0.80,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.51,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFFFF0000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.69,
        width: 0.62,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.785,
        width: 0.62,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
      ),
      website: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.815,
        width: 0.62,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.91,
        width: 0.52,
        fontSize: 9,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.32, size: 0.40),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 13  (v13) — Montserrat, front logo, back logo + QR
  // ===========================================================================

  static const verticalTemplate13 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.31, top: 0.10, size: 0.38),
      name: VisitingCardFieldPosition(
        left: 0.15,
        top: 0.55,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0A0A),
        firstNameColor: Color(0xFF1E8FD8),
        lastNameColor: Color(0xFF0A0A0A),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.15,
        top: 0.595,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.70,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      website: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.76,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.82,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      address: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.88,
        width: 0.52,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.16, size: 0.20),
      logo: VisitingCardFieldPosition(left: 0.30, top: 0.62, size: 0.40),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.80,
        width: 0.76,
        fontSize: 8,
        color: Color(0xFF404041),
        textAlign: TextAlign.center,
      ),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 14  (v14) — Montserrat, front logo, back logo + QR
  // ===========================================================================

  static const verticalTemplate14 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.33, top: 0.12, size: 0.36),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.285,
        width: 0.72,
        fontSize: 8,
        color: Color(0xFF404041),
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.29,
        top: 0.46,
        width: 0.84,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF15A29),
        textAlign: TextAlign.center,
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.35,
        top: 0.51,
        width: 0.84,
        fontSize: 10,
        color: Color(0xFF000000),
        textAlign: TextAlign.center,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.33,
        top: 0.625,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.33,
        top: 0.69,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      website: VisitingCardFieldPosition(
        left: 0.33,
        top: 0.755,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      address: VisitingCardFieldPosition(
        left: 0.33,
        top: 0.815,
        width: 0.60,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.30, top: 0.25, size: 0.38),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.44,
        width: 0.76,
        fontSize: 8,
        color: Color(0xFF404041),
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.36, top: 0.66, size: 0.26),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 15  (v15) — Inter, back logo, no QR
  // ===========================================================================

  static const verticalTemplate15 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.44,
        width: 0.80,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color(0xFF6B6B6B),
        firstNameColor: Color(0xFF6B6B6B),
        lastNameColor: Color(0xFF6CC400),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.50,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.60,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
      ),
      email: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.657,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
        maxLines: 2,
      ),
      address: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.73,
        width: 0.52,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
      ),
      website: VisitingCardFieldPosition(
        left: 0.23,
        top: 0.78,
        width: 0.72,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.43, size: 0.40),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 16  (v16) — Inter, front + back logo, no QR
  // ===========================================================================

  static const verticalTemplate16 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.30, top: 0.12, size: 0.42),
      name: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.56,
        width: 0.84,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF032C40),
        firstNameColor: Color(0xFF032C40),
        lastNameColor: Color(0xFFF50302),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.13,
        top: 0.60,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF404041),
      ),
      address: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.68,
        width: 0.50,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.77,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.85,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      website: VisitingCardFieldPosition(
        left: 0.22,
        top: 0.93,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.46, size: 0.44),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 17  (v17) — Inter, front logo, back logo + QR
  // ===========================================================================

  static const verticalTemplate17 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.08, top: 0.08, size: 0.34),
      name: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.53,
        width: 0.82,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF032C40),
        firstNameColor: Color(0xFFB6CF32),
        lastNameColor: Color(0xFF032C40),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.58,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF404041),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.69,
        width: 0.74,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.75,
        width: 0.74,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      website: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.81,
        width: 0.74,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      address: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.88,
        width: 0.54,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.15, size: 0.38),
      tagline: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.33,
        width: 0.76,
        fontSize: 8,
        color: Color(0xFFB6CF32),
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.36, top: 0.36, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 18  (v18) — Inter, back logo + QR
  // ===========================================================================

  static const verticalTemplate18 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.08,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF032C40),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.12,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF404041),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.27,
        top: 0.22,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      email: VisitingCardFieldPosition(
        left: 0.27,
        top: 0.285,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
      address: VisitingCardFieldPosition(
        left: 0.27,
        top: 0.35,
        width: 0.50,
        fontSize: 9,
        color: Color(0xFF032C40),
        maxLines: 2,
      ),
      website: VisitingCardFieldPosition(
        left: 0.27,
        top: 0.42,
        width: 0.60,
        fontSize: 9,
        color: Color(0xFF032C40),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.24, size: 0.40),
      qr: VisitingCardFieldPosition(left: 0.40, top: 0.42, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 19  (v19) — Inter, back logo + QR, name capitals
  // ===========================================================================

  static const verticalTemplate19 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.038,
        width: 0.88,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF000000),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.08,
        width: 0.80,
        fontSize: 10,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.20,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.26,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
      ),
      website: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.32,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
      ),
      address: VisitingCardFieldPosition(
        left: 0.24,
        top: 0.38,
        width: 0.50,
        fontSize: 9,
        color: Color(0xFF000000),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.30, top: 0.28, size: 0.38),
      qr: VisitingCardFieldPosition(left: 0.36, top: 0.50, size: 0.22),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 20  (v20) — Inter, back logo + QR
  // ===========================================================================

  static const verticalTemplate20 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.inter,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.40,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF032C40),
        maxDisplayNameLength: 20,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.44,
        width: 0.75,
        fontSize: 10,
        color: Color(0xFF404041),
      ),
      address: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.56,
        width: 0.50,
        fontSize: 9,
        color: Color(0xFF000000),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.63,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.705,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
      ),
      website: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.77,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF000000),
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.32, top: 0.14, size: 0.38),
      tagline: VisitingCardFieldPosition(
        left: 0.38,
        top: 0.34,
        width: 0.84,
        fontSize: 8,
        color: Color(0xFF000000),
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(left: 0.36, top: 0.38, size: 0.26),
    ),
  );

  // ===========================================================================
  // VERTICAL TEMPLATE 21  (v21) — Montserrat, back logo, no QR
  // ===========================================================================

  static const verticalTemplate21 = VisitingCardTemplatePositions(
    fontFamily: VisitingCardFonts.montserrat,
    front: VisitingCardSidePositions(
      name: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.08,
        width: 0.84,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E82),
        maxDisplayNameLength: 18,
        uppercase: true,
      ),
      designation: VisitingCardFieldPosition(
        left: 0.16,
        top: 0.14,
        width: 0.80,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        uppercase: true,
        color: Color(0xFF358DCC),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.28,
        top: 0.325,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF2E2E82),
      ),
      email: VisitingCardFieldPosition(
        left: 0.28,
        top: 0.40,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF2E2E82),
      ),
      website: VisitingCardFieldPosition(
        left: 0.28,
        top: 0.48,
        width: 0.70,
        fontSize: 9,
        color: Color(0xFF2E2E82),
      ),
      address: VisitingCardFieldPosition(
        left: 0.28,
        top: 0.535,
        width: 0.60,
        fontSize: 9,
        color: Color(0xFF2E2E82),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      logo: VisitingCardFieldPosition(left: 0.28, top: 0.42, size: 0.48),
    ),
  );
}
