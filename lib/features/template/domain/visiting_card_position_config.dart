import 'package:flutter/material.dart';

/// Font families used by visiting-card templates.
class VisitingCardFonts {
  static const sfPro = 'SF Pro';
  static const sfProText = 'SF Pro Text';
  static const inter = 'Inter';
  static const roboto = 'Roboto';
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

  bool get hasSplitNameColors =>
      firstNameColor != null || lastNameColor != null;
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
/// Template ids: horizontal `h1`…`h5`, vertical `v1`…`v5`.
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
        _ => horizontalTemplate1,
      };
    }
    return switch (templateId) {
      'v1' => verticalTemplate1,
      'v2' => verticalTemplate2,
      'v3' => verticalTemplate3,
      'v4' => verticalTemplate4,
      'v5' => verticalTemplate5,
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
        left: 0.06,
        top: 0.10,
        width: 0.48,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        maxLines: 2,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        firstNameColor: Color(0xFF1A1A1A),
        lastNameColor: Color(0xFFF5A623),
      ),
      // Designation
      designation: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.20,
        width: 0.48,
        fontSize: 10,
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
        width: 0.40,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 2,
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
        left: 0.09,
        top: 0.465,
        width: 0.80,
        fontSize: 8,
        color: Color(0xFF404040),
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.41, // (1 - 0.18) / 2
        top: 0.54,
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
      logo: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.05,
        size: 0.14,
      ),
      // Company under logo
      company: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.20,
        width: 0.40,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.25,
        top: 0.28,
        width: 0.40,
        fontSize: 8,
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
        maxLines: 2,
        uppercase: false,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.20,
        top: 0.47,
        width: 0.40,
        fontSize: 8,
        color: Color(0xFF8BC34A),
        uppercase: true,
      ),
      // Location (1st icon — map pin)
      address: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.19,
        width: 0.34,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      email: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.30,
        width: 0.34,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.41,
        width: 0.34,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      // Website (4th / globe icon)
      website: VisitingCardFieldPosition(
        left: 0.68,
        top: 0.52,
        width: 0.34,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF404040),
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(
        left: 0.43,
        top: 0.08,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.34,
        width: 0.80,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.46,
        width: 0.80,
        fontSize: 10,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.41,
        bottom: 0.08,
        size: 0.18,
      ),
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
      logo: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.14,
        size: 0.14,
      ),
      // Company
      company: VisitingCardFieldPosition(
        left: 0.02,
        top: 0.38,
        width: 0.24,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.02,
        top: 0.48,
        width: 0.24,
        fontSize: 7,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      // Name — right white
      name: VisitingCardFieldPosition(
        left: 0.40,
        top: 0.12,
        width: 0.52,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: false,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.40,
        top: 0.28,
        width: 0.50,
        fontSize: 10,
        color: Color(0xFFE53935),
        uppercase: true,
      ),
      phone: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.42,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.54,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.66,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.78,
        width: 0.42,
        fontSize: 9,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (right white panel)
      logo: VisitingCardFieldPosition(
        left: 0.66,
        top: 0.10,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.34,
        width: 0.46,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.48,
        top: 0.46,
        width: 0.46,
        fontSize: 9,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.64,
        bottom: 0.10,
        size: 0.18,
      ),
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
        left: 0.05,
        top: 0.10,
        width: 0.40,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: false,
        color: Color(0xFFFFFFFF),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.48,
        width: 0.32,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      email: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.62,
        width: 0.32,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
      ),
      address: VisitingCardFieldPosition(
        left: 0.12,
        top: 0.74,
        width: 0.32,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        maxLines: 2,
      ),
      // Logo (right white)
      logo: VisitingCardFieldPosition(
        left: 0.66,
        top: 0.12,
        size: 0.14,
      ),
      // Company
      company: VisitingCardFieldPosition(
        left: 0.55,
        top: 0.38,
        width: 0.38,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.55,
        top: 0.50,
        width: 0.38,
        fontSize: 8,
        color: Color(0xFF6B6B6B),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline (left stack; QR optional)
      logo: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.14,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.40,
        width: 0.40,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.06,
        top: 0.54,
        width: 0.40,
        fontSize: 9,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.14,
        bottom: 0.10,
        size: 0.18,
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
        maxLines: 2,
        uppercase: false,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.05,
        top: 0.22,
        width: 0.42,
        fontSize: 10,
        color: Color(0xFF2196F3),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.40,
        width: 0.36,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.52,
        width: 0.36,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.64,
        width: 0.36,
        fontSize: 9,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.14,
        top: 0.76,
        width: 0.36,
        fontSize: 9,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      // Logo (right dark panel)
      logo: VisitingCardFieldPosition(
        left: 0.70,
        top: 0.18,
        size: 0.14,
      ),
      // Company
      company: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.42,
        width: 0.34,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.60,
        top: 0.54,
        width: 0.34,
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (dark bg)
      logo: VisitingCardFieldPosition(
        left: 0.43,
        top: 0.08,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.34,
        width: 0.80,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.46,
        width: 0.80,
        fontSize: 10,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.41,
        bottom: 0.08,
        size: 0.18,
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
        left: 0.08,
        top: 0.06,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF0D4F4C),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.14,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.26,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.34,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.42,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.50,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
      // Logo (bottom dark branding)
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.68,
        size: 0.14,
      ),
      // Company
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.82,
        width: 0.80,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.90,
        width: 0.80,
        fontSize: 10,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (dark bg)
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.12,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.28,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.36,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.36,
        bottom: 0.12,
        size: 0.18,
      ),
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
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.04,
        size: 0.14,
      ),
      // Company
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.15,
        width: 0.80,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      // Tagline
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.21,
        width: 0.80,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      // Name
      name: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.32,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF1565C0),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.42,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF1A1A1A),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.54,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.62,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.70,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.12,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.28,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.36,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.36,
        bottom: 0.12,
        size: 0.18,
      ),
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
        left: 0.08,
        top: 0.10,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: true,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.20,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.38,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.46,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.54,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.62,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
    back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.12,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.28,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.36,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.36,
        bottom: 0.12,
        size: 0.18,
      ),
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
      // Logo (top)
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.04,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.15,
        width: 0.80,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.21,
        width: 0.80,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.32,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: false,
        fontStyle: FontStyle.italic,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.42,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.54,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.62,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.70,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.78,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.12,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.28,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.36,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF404040),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.36,
        bottom: 0.12,
        size: 0.18,
      ),
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
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.04,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.15,
        width: 0.80,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFF1A1A1A),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.10,
        top: 0.21,
        width: 0.80,
        fontSize: 9,
        color: Color(0xFF6B6B6B),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      name: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.32,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 2,
        uppercase: true,
        color: Color(0xFF1A1A1A),
      ),
      designation: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.42,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFF6B6B6B),
      ),
      phone: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.54,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      email: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.62,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      website: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.70,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
      ),
      address: VisitingCardFieldPosition(
        left: 0.18,
        top: 0.78,
        width: 0.70,
        fontSize: 10,
        color: Color(0xFF404040),
        maxLines: 2,
      ),
    ),
back: VisitingCardSidePositions(
      // Logo → Company → Tagline → QR (dark bg)
      logo: VisitingCardFieldPosition(
        left: 0.36,
        top: 0.12,
        size: 0.14,
      ),
      company: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.28,
        width: 0.84,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        uppercase: true,
        color: Color(0xFFFFFFFF),
        textAlign: TextAlign.center,
      ),
      tagline: VisitingCardFieldPosition(
        left: 0.08,
        top: 0.36,
        width: 0.84,
        fontSize: 11,
        color: Color(0xFFFFFFFF),
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      qr: VisitingCardFieldPosition(
        left: 0.36,
        bottom: 0.12,
        size: 0.18,
      ),
    ),
  );
}
