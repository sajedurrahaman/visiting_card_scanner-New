import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/domain/visiting_card_contact_icon_layout.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_font_style.dart';
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_multi_select_chrome.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_transform_overlay.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

Widget _flipField(Widget child, VisitingCardFieldTransform t) {
  if (!t.flipX && !t.flipY) return child;
  return Transform.scale(
    alignment: Alignment.center,
    scaleX: t.flipX ? -1 : 1,
    scaleY: t.flipY ? -1 : 1,
    child: child,
  );
}

List<Shadow>? _fieldShadows(VisitingCardFieldTransform t) {
  if (t.shadowBlur <= 0) return null;
  return [
    Shadow(
      color: t.shadowColor ?? const Color(0xCC000000),
      blurRadius: t.shadowBlur,
      offset: Offset(t.shadowBlur * 0.25, t.shadowBlur * 0.4),
    ),
  ];
}

Widget _fadeField(Widget child, VisitingCardFieldTransform t) {
  final opacity = t.opacity.clamp(0.0, 1.0);
  if (opacity >= 0.999) return child;
  return Opacity(opacity: opacity, child: child);
}

Widget _strokeText({
  required Widget fill,
  required String text,
  required TextStyle style,
  required VisitingCardFieldTransform transform,
  required int? maxLines,
  required bool softWrap,
  required TextOverflow overflow,
  required TextAlign textAlign,
  required TextScaler? textScaler,
}) {
  if (transform.strokeWidth <= 0) return fill;
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = transform.strokeWidth
    ..color = transform.strokeColor ?? const Color(0xFF000000);
  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      Text(
        text,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: overflow,
        textAlign: textAlign,
        textScaler: textScaler,
        style: style.copyWith(foreground: paint, shadows: const <Shadow>[]),
      ),
      fill,
    ],
  );
}

class VisitingCardLivePreview extends StatefulWidget {
  const VisitingCardLivePreview({
    super.key,
    required this.vm,
    this.showPager = true,
    this.pagerOnly = false,
    this.sideOverride,
    this.onShowFront,
    this.onShowBack,
    this.enableFieldTransform = false,
    this.selectionBorderOnlyWhenSelected = false,
    this.eightPointSelection = false,
    this.singleLineText = false,
    this.matchEditorText = false,
    this.pageGap = 6,
  });

  final VisitingCardEditContactViewModel vm;
  final bool showPager;
  final bool pagerOnly;

  /// When set, render this side instead of [vm.sideIndex] (0 = front, 1 = back).
  final int? sideOverride;
  final VoidCallback? onShowFront;
  final VoidCallback? onShowBack;

  /// Edit mode: finger drag / resize / rotate for logo, qr, company, tagline.
  final bool enableFieldTransform;

  /// Landscape editor: show selection border only on the tapped field.
  final bool selectionBorderOnlyWhenSelected;

  /// Edit Contact Info: same 8-handle select frame as landscape, and the
  /// box hugs the text instead of the template field width.
  final bool eightPointSelection;

  /// Details preview: one line per field, same as the editor. Taglines still wrap.
  final bool singleLineText;

  /// Card Details: same font scale and text box as the card editor, so a
  /// position saved there lands on the same spot. No selection chrome.
  final bool matchEditorText;

  /// Space between the front and back faces while swiping. 0 keeps them flush.
  final double pageGap;

  @override
  State<VisitingCardLivePreview> createState() =>
      _VisitingCardLivePreviewState();
}

class _VisitingCardLivePreviewState extends State<VisitingCardLivePreview> {
  late final PageController _pageController;
  bool _ignorePageCallback = false;

  int get _sideIndex => widget.sideOverride ?? widget.vm.sideIndex;
  bool get _isFront => _sideIndex == 0;

  VoidCallback get _showFront => widget.onShowFront ?? widget.vm.showFront;
  VoidCallback get _showBack => widget.onShowBack ?? widget.vm.showBack;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _sideIndex);
    widget.vm.addListener(_onVmChanged);
    // The first frame measures fallback glyphs. A line that fits the real
    // font is then clamped and drawn with "…". Remeasure once it loads.
    WidgetsBinding.instance.addPostFrameCallback((_) => _remeasureAfterFonts());
  }

  Future<void> _remeasureAfterFonts() async {
    if (!mounted) return;
    try {
      await GoogleFonts.pendingFonts();
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant VisitingCardLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_onVmChanged);
      widget.vm.addListener(_onVmChanged);
      _animateTo(_sideIndex);
    } else if (oldWidget.sideOverride != widget.sideOverride) {
      _animateTo(_sideIndex);
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (!mounted) return;
    // Handle drags notify on every pixel. Animating the page then fights
    // the finger, so only follow side changes when a drag is not active.
    if (!widget.vm.overlayGestureActive) {
      _animateTo(widget.sideOverride ?? widget.vm.sideIndex);
    }
    setState(() {});
  }

  void _animateTo(int page) {
    if (!_pageController.hasClients) return;
    // A fractional page can round to the requested side while still showing
    // both faces. Capture must snap even when that side is already selected.
    if (widget.vm.jumpSideForCapture) {
      _ignorePageCallback = true;
      _pageController.jumpToPage(page);
      _ignorePageCallback = false;
      return;
    }
    final offset =
        _pageController.page ?? _pageController.initialPage.toDouble();
    // A finger swipe already owns the motion once it has crossed onto this
    // page. Taking over with animateToPage cuts that fling short.
    if (offset.round() == page) return;

    _ignorePageCallback = true;
    _pageController
        .animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          if (mounted) _ignorePageCallback = false;
        });
  }

  void _onPageChanged(int page) {
    if (_ignorePageCallback || widget.sideOverride != null) return;
    if (page == 0) {
      _showFront();
    } else {
      _showBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pagerOnly) {
      return VisitingCardSidePager(
        currentPage: _sideIndex + 1,
        canGoPrevious: !_isFront,
        canGoNext: _isFront,
        onPrevious: _showFront,
        onNext: _showBack,
      );
    }

    final aspectRatio = widget.vm.isHorizontal ? 1.75 : 0.63;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: _cardPager(),
          ),
        ),
        if (widget.showPager) ...[
          SizedBox(height: 8.h),
          VisitingCardSidePager(
            currentPage: _sideIndex + 1,
            canGoPrevious: !_isFront,
            canGoNext: _isFront,
            onPrevious: _showFront,
            onNext: _showBack,
          ),
        ],
      ],
    );
  }

  Widget _cardPager() {
    final gap = widget.pageGap;
    Widget face(int index) {
      final child = _buildCardFace(sideIndex: index);
      if (gap <= 0) return child;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: gap / 2),
        child: child,
      );
    }

    // Both sides stay built, same as the template tiles, so the first
    // finger swipe does not construct the other face mid-gesture.
    final pager = PageView(
      controller: _pageController,
      // Editor mode locks paging so marquee-drag select is not stolen by
      // the front/back PageView; use the side pager buttons instead.
      physics: widget.vm.jumpSideForCapture || widget.enableFieldTransform
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
      onPageChanged: _onPageChanged,
      children: [face(0), face(1)],
    );
    if (gap <= 0) return pager;
    // Pages are wider by [gap] and shifted out by half, so a settled face
    // still fills the card. The extra half on each side becomes a [gap]
    // strip only where the front and back meet mid-swipe.
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: -gap / 2,
          right: -gap / 2,
          top: 0,
          bottom: 0,
          child: pager,
        ),
      ],
    );
  }

  Widget _buildCardFace({required int sideIndex}) {
    final isFront = sideIndex == 0;
    final layout = VisitingCardPositionConfig.forTemplate(
      templateId: widget.vm.templateId,
      isHorizontal: widget.vm.isHorizontal,
    );
    final side = isFront ? layout.front : layout.back;
    final backgroundAsset = isFront
        ? widget.vm.frontAssetWithoutData
        : widget.vm.backAssetWithoutData;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final interactive =
            widget.enableFieldTransform && sideIndex == widget.vm.sideIndex;
        final hitTargets = <({String key, Rect rect})>[];
        final overlays = _buildOverlayChildren(
          size: size,
          side: side,
          backgroundAsset: backgroundAsset,
          fontFamily: layout.fontFamily,
          isFront: isFront,
          interactive: interactive,
          hitTargets: hitTargets,
        );
        final vm = widget.vm;
        Rect? groupBounds;
        if (interactive && vm.hasMultiSelection) {
          Rect? union;
          for (final t in hitTargets) {
            if (!vm.multiSelectedKeys.contains(t.key)) continue;
            union = union == null ? t.rect : union.expandToInclude(t.rect);
          }
          groupBounds = union;
        }
        final cardBackground = backgroundAsset.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(backgroundAsset, fit: BoxFit.cover)
            : Image.asset(
                backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFF5F5F5),
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              );
        return Stack(
          fit: StackFit.expand,
          children: [
            cardBackground,
            if (interactive)
              VisitingCardMarqueeLayer(
                cardSize: size,
                hitTargets: hitTargets,
                onTapClear: vm.clearOverlaySelection,
                onMarqueeStart: vm.beginMarquee,
                onMarqueeUpdate: (local) => vm.updateMarquee(local, hitTargets),
                onMarqueeEnd: vm.endMarquee,
              ),
            ...overlays,
            if (interactive && vm.marqueeActive && vm.marqueeRect != null)
              VisitingCardMarqueePaint(rect: vm.marqueeRect!),
            if (interactive && vm.showMoveGrid) const VisitingCardMoveGrid(),
            if (interactive && groupBounds != null)
              VisitingCardGroupSelectionBox(
                bounds: groupBounds,
                cardSize: size,
                onMove: (dx, dy) => vm.moveMultiSelection(dx, dy, size),
                onGestureStart: vm.beginOverlayGesture,
                onGestureEnd: vm.endOverlayGesture,
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOverlayChildren({
    required Size size,
    required VisitingCardSidePositions side,
    required String backgroundAsset,
    required String fontFamily,
    required bool isFront,
    required bool interactive,
    required List<({String key, Rect rect})> hitTargets,
  }) {
    final vm = widget.vm;
    final layers = <(int, int, Widget)>[];
    final multi = vm.hasMultiSelection;

    void trackHit(String key, double left, double top, double w, double h) {
      if (!interactive) return;
      hitTargets.add((key: key, rect: Rect.fromLTWH(left, top, w, h)));
    }

    bool keySelected(String key) => vm.isOverlayKeySelected(key);
    var layerSeq = 0;
    // Every editable preview uses the same card-relative typography. Using
    // ScreenUtil in Contact Info and a clamped scale in the landscape editor
    // changed intrinsic text widths (and right-aligned glyph positions).
    final landscapeFonts =
        widget.selectionBorderOnlyWhenSelected ||
        widget.matchEditorText ||
        widget.eightPointSelection;
    final landscape = landscapeFonts;
    // Template font sizes are logical pixels on a 320px-wide card. Never
    // clamp this ratio: zooming or rotating must scale the whole card equally.
    final fontScale = landscapeFonts ? size.width / 320.0 : 1.0;
    final textInset = landscapeFonts ? fontScale : 1.0;
    const landscapeTextScaler = TextScaler.noScaling;

    double resolveFont(double designSize) {
      if (landscapeFonts) return designSize * fontScale;
      return designSize.sp;
    }

    TextStyle applyFont(TextStyle base, VisitingCardFieldTransform t) {
      final style = applyVisitingCardFont(base, t);
      return style.copyWith(
        letterSpacing: (style.letterSpacing ?? 0) * fontScale,
      );
    }

    void addLayer(Widget overlay, int z) {
      layers.add((z, layerSeq++, overlay));
    }

    void addOverlay(Widget overlay, VisitingCardOverlayField field) {
      addLayer(
        overlay,
        VisitingCardFieldTransform.stackZ(
          VisitingCardFieldTransform.keyOf(field),
          vm.overlayFor(field, isFront: isFront),
        ),
      );
    }

    TextStyle withFallback(TextStyle style) {
      return style.copyWith(
        fontFamilyFallback: [...?style.fontFamilyFallback, 'sans-serif'],
      );
    }

    TextStyle styleFor(VisitingCardFieldPosition pos, {double? fontSize}) {
      final resolved = resolveFont(fontSize ?? pos.fontSize);
      if (fontFamily == VisitingCardFonts.inter) {
        return withFallback(
          GoogleFonts.inter(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return withFallback(
          GoogleFonts.roboto(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      if (fontFamily == VisitingCardFonts.montserrat) {
        return withFallback(
          GoogleFonts.montserrat(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: resolved,
        fontWeight: pos.fontWeight,
        fontStyle: pos.fontStyle,
        color: pos.color,
        letterSpacing: pos.letterSpacing,
        height: pos.heightFactor,
      );
    }

    TextStyle nameStyleFor(VisitingCardFieldPosition pos, String rawName) {
      final resolved = resolveFont(pos.resolvedNameFontSize(rawName));
      if (fontFamily == VisitingCardFonts.inter) {
        return withFallback(
          GoogleFonts.inter(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return withFallback(
          GoogleFonts.roboto(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      if (fontFamily == VisitingCardFonts.montserrat) {
        return withFallback(
          GoogleFonts.montserrat(
            fontSize: resolved,
            fontWeight: pos.fontWeight,
            fontStyle: pos.fontStyle,
            color: pos.color,
            letterSpacing: pos.letterSpacing,
            height: pos.heightFactor,
          ),
        );
      }
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: resolved,
        fontWeight: pos.fontWeight,
        fontStyle: pos.fontStyle,
        color: pos.color,
        letterSpacing: pos.letterSpacing,
        height: pos.heightFactor,
      );
    }

    void addName(VisitingCardFieldPosition? pos, String value) {
      if (pos == null || value.trim().isEmpty) return;
      const field = VisitingCardOverlayField.name;
      final clipped = pos.clipDisplayName(value);
      final t = vm.resolvedTransform(field, isFront: isFront);
      final display = visitingCardStyledText(
        clipped,
        t,
        templateUppercase: pos.uppercase,
      );
      // Landscape: free line + select-border width (intrinsic text, or
      // user-stretched width). Portrait keeps template width.
      final availableWidth = (size.width - (size.width * t.left))
          .clamp(1.0, size.width)
          .toDouble();
      final maxW = landscape
          ? availableWidth
          : size.width * (t.width ?? pos.width ?? 0.48);
      final shadows = _fieldShadows(t);
      final baseStyle = applyFont(
        nameStyleFor(pos, clipped).copyWith(
          fontSize: resolveFont(t.size),
          // height: 1.0 clips descenders inside the select box on landscape.
          height: landscape ? pos.heightFactor : 1.0,
          letterSpacing: pos.letterSpacing + t.letterSpacing,
          shadows: shadows,
        ),
        t,
      );

      final painter = TextPainter(
        text: TextSpan(text: display, style: baseStyle),
        maxLines: 1,
        textAlign: pos.textAlign,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.longestLine,
        textScaler: landscapeFonts ? landscapeTextScaler : TextScaler.linear(1),
      );
      late double boxW;
      var landscapeWrap = false;
      if (landscape) {
        painter.layout(maxWidth: double.infinity);
        // Use full layout width (+1px) so soft-wrap never triggers on select.
        final intrinsic = (painter.width + textInset)
            .clamp(1.0, availableWidth)
            .toDouble();
        if (t.width != null) {
          final stretched = (size.width * t.width!)
              .clamp(1.0, availableWidth)
              .toDouble();
          landscapeWrap = stretched < intrinsic - 0.5 * textInset;
          boxW = stretched;
          painter
            ..maxLines = landscapeWrap ? null : 1
            ..layout(maxWidth: boxW);
        } else {
          boxW = intrinsic;
        }
      } else {
        painter
          ..maxLines = pos.maxLines
          ..ellipsis = '…'
          ..layout(maxWidth: maxW);
        boxW = painter.width.clamp(1.0, maxW);
      }
      final boxH = (painter.height + (landscape ? 2.0 * textInset : 0.0)).clamp(
        1.0,
        size.height,
      );

      Widget text;
      if (pos.hasSplitNameColors) {
        final parts = display.trim().split(RegExp(r'\s+'));
        final first = parts.first;
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        final firstColor = t.textColor ?? pos.firstNameColor ?? pos.color;
        final lastColor = t.textColor ?? pos.lastNameColor ?? pos.color;
        text = Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: first,
                style: baseStyle.copyWith(color: firstColor),
              ),
              if (last.isNotEmpty)
                TextSpan(
                  text: ' $last',
                  style: baseStyle.copyWith(color: lastColor),
                ),
            ],
          ),
          maxLines: landscape ? (landscapeWrap ? null : 1) : pos.maxLines,
          softWrap: landscapeWrap,
          overflow: landscape ? TextOverflow.visible : TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        );
      } else {
        text = Text(
          display,
          maxLines: landscape ? (landscapeWrap ? null : 1) : pos.maxLines,
          softWrap: landscapeWrap,
          overflow: landscape ? TextOverflow.visible : TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          style: baseStyle.copyWith(color: t.textColor ?? pos.color),
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        );
      }
      text = _fadeField(
        _strokeText(
          fill: text,
          text: display,
          style: baseStyle,
          transform: t,
          maxLines: landscape ? (landscapeWrap ? null : 1) : pos.maxLines,
          softWrap: landscapeWrap,
          overflow: landscape ? TextOverflow.visible : TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        ),
        t,
      );

      if (!interactive) {
        addLayer(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: boxW,
            height: boxH,
            child: Transform.rotate(
              alignment: landscape ? Alignment.topLeft : Alignment.center,
              angle: t.rotation,
              child: _flipField(text, t),
            ),
          ),
          VisitingCardFieldTransform.stackZ(
            VisitingCardFieldTransform.keyOf(field),
            t,
          ),
        );
        return;
      }

      trackHit(
        VisitingCardFieldTransform.keyOf(field),
        size.width * t.left,
        size.height * t.top,
        boxW,
        boxH,
      );
      addOverlay(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: keySelected(VisitingCardFieldTransform.keyOf(field)),
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked && !multi,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: () =>
              multi ? vm.selectOverlay(field) : vm.clearOverlaySelection(),
          onMove: multi
              ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
              : (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onUniformScale: landscape
              ? (d, {required fixRight, required fixBottom}) =>
                    vm.scaleOverlayUniform(
                      field,
                      d,
                      size,
                      fixRight: fixRight,
                      fixBottom: fixBottom,
                      seedWidthFraction: boxW / size.width,
                      seedHeightPx: boxH,
                    )
              : null,
          onStretchHorizontal: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: true,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedWidthFraction: boxW / size.width,
                )
              : null,
          onStretchVertical: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: false,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedHeightPx: boxH,
                )
              : null,
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: _flipField(text, t),
        ),
        field,
      );
    }

    void addTransformText({
      required VisitingCardOverlayField field,
      required VisitingCardFieldPosition? configPos,
      required String value,
    }) {
      if (configPos == null || value.trim().isEmpty) return;
      final t = vm.resolvedTransform(field, isFront: isFront);
      final isAddress = field == VisitingCardOverlayField.address;
      final isTagline = field == VisitingCardOverlayField.tagline;
      final hugLine = landscape || widget.singleLineText;
      final configuredWidth = size.width * (t.width ?? configPos.width ?? 0.4);
      final availableWidth = (size.width - (size.width * t.left))
          .clamp(1.0, size.width)
          .toDouble();
      // Landscape: free line + select-border width (intrinsic / stretch).
      final maxW = hugLine
          ? availableWidth
          : (isTagline
                ? configuredWidth.clamp(1.0, availableWidth).toDouble()
                : configuredWidth);
      final maxLines = isAddress ? 2 : (isTagline ? null : configPos.maxLines);
      final display = visitingCardStyledText(
        value,
        t,
        templateUppercase: configPos.uppercase,
      );

      TextStyle measureStyleFor(double fontSize) => applyFont(
        styleFor(configPos, fontSize: fontSize).copyWith(
          // height: 1.0 clips glyph bottoms in the landscape select border.
          height: landscape ? configPos.heightFactor : 1.0,
          letterSpacing: configPos.letterSpacing + t.letterSpacing,
          shadows: _fieldShadows(t),
        ),
        t,
      );

      TextPainter layoutText(
        TextStyle style,
        double layoutMaxW, {
        int? lines,
        bool allowEllipsis = false,
      }) => TextPainter(
        text: TextSpan(text: display, style: style),
        maxLines: lines,
        ellipsis: allowEllipsis ? '…' : null,
        textAlign: configPos.textAlign,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.longestLine,
        textScaler: landscapeFonts ? landscapeTextScaler : TextScaler.linear(1),
      )..layout(maxWidth: layoutMaxW);

      var measureStyle = measureStyleFor(t.size);
      late TextPainter painter;
      late double boxW;
      var landscapeWrap = false;
      if (isAddress) {
        // Keep the input as one value; wrap only the card presentation in the
        // template's address area (or the width set by the resize handles).
        boxW = configuredWidth.clamp(1.0, availableWidth).toDouble();
        landscapeWrap = true;
        painter = layoutText(measureStyle, boxW, lines: 2, allowEllipsis: true);
      } else if (hugLine) {
        // Single-line intrinsic so select never forces a newline.
        painter = layoutText(measureStyle, double.infinity, lines: 1);
        final intrinsic = (painter.width + textInset)
            .clamp(1.0, availableWidth)
            .toDouble();
        if (t.width != null) {
          final stretched = (size.width * t.width!)
              .clamp(1.0, availableWidth)
              .toDouble();
          landscapeWrap = isTagline || stretched < intrinsic - 0.5 * textInset;
          boxW = stretched;
          painter = layoutText(
            measureStyle,
            boxW,
            lines: landscapeWrap ? null : 1,
          );
        } else if (configPos.textAlign == TextAlign.right &&
            configPos.width != null) {
          // Icon-side fields: keep a fixed right edge (left+width) so short
          // text (phone) and long text (address) share the same icon gap.
          final areaW = (size.width * configPos.width!)
              .clamp(1.0, availableWidth)
              .toDouble();
          landscapeWrap =
              isTagline ||
              (configPos.maxLines > 1 && intrinsic > areaW + 0.5 * textInset);
          boxW = areaW;
          painter = layoutText(
            measureStyle,
            boxW,
            lines: landscapeWrap ? (configPos.maxLines) : 1,
            allowEllipsis: !landscapeWrap && !isTagline,
          );
        } else if (isTagline) {
          landscapeWrap = true;
          boxW = intrinsic;
          painter = layoutText(measureStyle, boxW);
        } else {
          boxW = intrinsic;
        }
      } else {
        painter = layoutText(
          measureStyle,
          maxW,
          lines: maxLines,
          allowEllipsis: !isTagline,
        );
        boxW = painter.width.clamp(1.0, maxW);
      }

      // Keep all wrapped tagline lines within the card when its font has been
      // enlarged. The largest fitting size is used, so the resize control
      // remains useful without ever clipping the final words.
      if (isTagline) {
        final availableHeight = (size.height - (size.height * t.top))
            .clamp(1.0, size.height)
            .toDouble();
        if (painter.height > availableHeight) {
          var low = 1.0;
          var high = t.size;
          var bestStyle = measureStyleFor(low);
          var bestPainter = layoutText(bestStyle, boxW);
          for (var i = 0; i < 18; i++) {
            final candidateSize = (low + high) / 2;
            final candidateStyle = measureStyleFor(candidateSize);
            final candidatePainter = layoutText(candidateStyle, boxW);
            if (candidatePainter.height <= availableHeight) {
              low = candidateSize;
              bestStyle = candidateStyle;
              bestPainter = candidatePainter;
            } else {
              high = candidateSize;
            }
          }
          measureStyle = bestStyle;
          painter = bestPainter;
        }
      }

      final boxH = (painter.height + (landscape ? 2.0 * textInset : 0.0)).clamp(
        1.0,
        size.height,
      );

      final fill = Text(
        display,
        maxLines: isAddress
            ? 2
            : (hugLine ? (landscapeWrap ? null : 1) : maxLines),
        softWrap: isAddress || (hugLine ? landscapeWrap : isTagline),
        overflow: isAddress
            ? TextOverflow.ellipsis
            : hugLine
            ? TextOverflow.visible
            : (isTagline ? TextOverflow.visible : TextOverflow.ellipsis),
        textAlign: configPos.textAlign,
        style: t.textColor == null
            ? measureStyle
            : measureStyle.copyWith(color: t.textColor),
        textScaler: landscapeFonts ? landscapeTextScaler : null,
      );
      final text = _fadeField(
        _strokeText(
          fill: fill,
          text: display,
          style: measureStyle,
          transform: t,
          maxLines: isAddress
              ? 2
              : (hugLine ? (landscapeWrap ? null : 1) : maxLines),
          softWrap: isAddress || (hugLine ? landscapeWrap : isTagline),
          overflow: isAddress
              ? TextOverflow.ellipsis
              : hugLine
              ? TextOverflow.visible
              : (isTagline ? TextOverflow.visible : TextOverflow.ellipsis),
          textAlign: configPos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        ),
        t,
      );

      if (!interactive) {
        addLayer(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: boxW,
            height: boxH,
            child: Transform.rotate(
              alignment: landscape ? Alignment.topLeft : Alignment.center,
              angle: t.rotation,
              child: _flipField(text, t),
            ),
          ),
          VisitingCardFieldTransform.stackZ(
            VisitingCardFieldTransform.keyOf(field),
            t,
          ),
        );
        return;
      }

      trackHit(
        VisitingCardFieldTransform.keyOf(field),
        size.width * t.left,
        size.height * t.top,
        boxW,
        boxH,
      );
      addOverlay(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: keySelected(VisitingCardFieldTransform.keyOf(field)),
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked && !multi,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: () =>
              multi ? vm.selectOverlay(field) : vm.clearOverlaySelection(),
          onMove: multi
              ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
              : (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onUniformScale: landscape
              ? (d, {required fixRight, required fixBottom}) =>
                    vm.scaleOverlayUniform(
                      field,
                      d,
                      size,
                      fixRight: fixRight,
                      fixBottom: fixBottom,
                      seedWidthFraction: boxW / size.width,
                      seedHeightPx: boxH,
                    )
              : null,
          onStretchHorizontal: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: true,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedWidthFraction: boxW / size.width,
                )
              : null,
          onStretchVertical: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: false,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedHeightPx: boxH,
                )
              : null,
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: _flipField(text, t),
        ),
        field,
      );
    }

    void addTransformImage({
      required VisitingCardOverlayField field,
      required VisitingCardFieldPosition? configPos,
      required String? assetPath,
    }) {
      if (configPos == null || assetPath == null || assetPath.isEmpty) return;
      final isAsset = assetPath.startsWith('assets/');
      if (!isAsset && !File(assetPath).existsSync()) return;

      final t = vm.resolvedTransform(field, isFront: isFront);
      final imgBox = size.width * t.size;
      trackHit(
        VisitingCardFieldTransform.keyOf(field),
        size.width * t.left,
        size.height * t.top,
        imgBox,
        imgBox,
      );
      addOverlay(
        _AspectFitTransformImage(
          key: ValueKey('transform-$field-$assetPath-$isFront'),
          cardSize: size,
          transform: t,
          assetPath: assetPath,
          isAsset: isAsset,
          interactive: interactive,
          selected: keySelected(VisitingCardFieldTransform.keyOf(field)),
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked && !multi,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: () =>
              multi ? vm.selectOverlay(field) : vm.clearOverlaySelection(),
          onMove: multi
              ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
              : (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onUniformScale: landscape
              ? (d, {required fixRight, required fixBottom}) =>
                    vm.scaleOverlayUniform(
                      field,
                      d,
                      size,
                      fixRight: fixRight,
                      fixBottom: fixBottom,
                    )
              : null,
          onStretchHorizontal: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: true,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                )
              : null,
          onStretchVertical: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: false,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                )
              : null,
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
        ),
        field,
      );
    }

    addName(side.name, vm.displayName);
    addTransformText(
      field: VisitingCardOverlayField.designation,
      configPos: side.designation,
      value: vm.displayDesignation,
    );
    addTransformText(
      field: VisitingCardOverlayField.company,
      configPos: side.company,
      value: vm.displayCompany,
    );
    addTransformText(
      field: VisitingCardOverlayField.tagline,
      configPos: side.tagline,
      value: vm.displayTagline,
    );

    final phones = vm.phones.where((e) => e.value.trim().isNotEmpty).toList();
    final emails = vm.emails.where((e) => e.value.trim().isNotEmpty).toList();
    final websites = vm.websites
        .where((e) => e.value.trim().isNotEmpty)
        .toList();

    addTransformText(
      field: VisitingCardOverlayField.phone,
      configPos: side.phone,
      value: phones.isEmpty ? '' : phones.first.value,
    );
    addTransformText(
      field: VisitingCardOverlayField.email,
      configPos: side.email,
      value: emails.isEmpty ? '' : emails.first.value,
    );
    addTransformText(
      field: VisitingCardOverlayField.website,
      configPos: side.website,
      value: websites.isEmpty ? '' : websites.first.value,
    );
    addTransformText(
      field: VisitingCardOverlayField.address,
      configPos: side.address,
      value: vm.displayAddress,
    );

    if (vm.hasLogoOnSide(front: isFront)) {
      addTransformImage(
        field: VisitingCardOverlayField.logo,
        configPos: side.logo,
        assetPath: vm.logoForSide(front: isFront),
      );
    }
    if (vm.hasChosenQr) {
      addTransformImage(
        field: VisitingCardOverlayField.qr,
        configPos: side.qr,
        assetPath: vm.qrAssetPath,
      );
    }

    void addContactIcon(VisitingCardOverlayField field) {
      final seed = VisitingCardContactIconLayout.positionFor(
        iconField: field,
        side: side,
        templateId: vm.templateId,
        isFront: isFront,
      );
      if (seed == null) return;

      final hidden = vm.isContactIconHidden(field, isFront: isFront);
      final t = vm.resolvedTransform(field, isFront: isFront);
      final customPath = vm.contactIconAsset(field, isFront: isFront);
      final hasSeparateTemplateIcons =
          VisitingCardContactIconLayout.hasSeparateTemplateIcons(
            vm.templateId,
            isFront: isFront,
          );
      final templateIconPath =
          VisitingCardContactIconLayout.templateIconAssetFor(
            vm.templateId,
            field,
            isFront: isFront,
          );
      final seedLeftFrac = seed.left ?? 0;
      final seedTopFrac = seed.top ?? 0;
      final seedSize = seed.size ?? VisitingCardContactIconLayout.defaultSize;
      final artwork = hasSeparateTemplateIcons
          ? null
          : _ContactIconArtworkCache.forIcon(
              assetPath: backgroundAsset,
              cardAspectRatio: size.width / size.height,
              left: seedLeftFrac,
              top: seedTopFrac,
              size: seedSize,
            );
      // New backgrounds have no baked icons, so their individual PNG assets
      // are always rendered as independent, movable overlays.
      final needsDrawnIcon =
          hasSeparateTemplateIcons ||
          customPath != null ||
          (t.left - seedLeftFrac).abs() > 0.004 ||
          (t.top - seedTopFrac).abs() > 0.004 ||
          (t.size - seedSize).abs() > 0.004 ||
          t.rotation.abs() > 0.01 ||
          hidden;

      if (needsDrawnIcon && !hasSeparateTemplateIcons) {
        final seedLeft = size.width * seedLeftFrac;
        final seedTop = size.height * seedTopFrac;
        final seedBox = size.width * seedSize;
        final coverBox = seedBox * VisitingCardContactIconLayout.coverScale;
        final coverPad = (coverBox - seedBox) / 2;
        addLayer(
          Positioned(
            left: seedLeft - coverPad,
            top: seedTop - coverPad,
            width: coverBox,
            height: coverBox,
            child: _TemplateBackgroundCover(artwork: artwork!),
          ),
          // Keep the source patch below every movable overlay. Otherwise a
          // moved icon with a lower/custom z-index can be painted underneath
          // this square patch.
          -0x7FFFFFFF,
        );
      }

      if (hidden) return;

      final box = size.width * t.size;
      final accent = seed.color;
      final Widget drawn;
      if (hasSeparateTemplateIcons) {
        drawn = customPath != null
            ? _ContactIconVisual(
                field: field,
                accent: accent,
                customAssetPath: customPath,
              )
            : _TemplateContactIconAsset(
                assetPath: templateIconPath!,
                tint: VisitingCardContactIconLayout.templateIconTintFor(
                  vm.templateId,
                  isFront: isFront,
                ),
              );
      } else if (needsDrawnIcon) {
        drawn = _TemplateContactIconVisual(
          field: field,
          fallbackAccent: accent,
          customAssetPath: customPath,
          artwork: artwork!,
        );
      } else {
        drawn = const SizedBox.expand();
      }
      final iconChild = _fadeField(drawn, t);

      if (!interactive) {
        addLayer(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: box,
            height: box,
            child: Transform.rotate(
              alignment: landscape ? Alignment.topLeft : Alignment.center,
              angle: t.rotation,
              child: _flipField(iconChild, t),
            ),
          ),
          VisitingCardFieldTransform.stackZ(
            VisitingCardFieldTransform.keyOf(field),
            t,
          ),
        );
        return;
      }

      trackHit(
        VisitingCardFieldTransform.keyOf(field),
        size.width * t.left,
        size.height * t.top,
        box,
        box,
      );
      addOverlay(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: box,
          boxHeight: box,
          rotation: t.rotation,
          selected: keySelected(VisitingCardFieldTransform.keyOf(field)),
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked && !multi,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: () =>
              multi ? vm.selectOverlay(field) : vm.clearOverlaySelection(),
          onMove: multi
              ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
              : (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onUniformScale: landscape
              ? (d, {required fixRight, required fixBottom}) =>
                    vm.scaleOverlayUniform(
                      field,
                      d,
                      size,
                      fixRight: fixRight,
                      fixBottom: fixBottom,
                    )
              : null,
          onStretchHorizontal: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: true,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                )
              : null,
          onStretchVertical: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  field,
                  horizontal: false,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                )
              : null,
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: _flipField(iconChild, t),
        ),
        field,
      );
    }

    for (final iconField in VisitingCardContactIconLayout.contactIconFields) {
      addContactIcon(iconField);
    }

    VisitingCardFieldPosition? posFor(VisitingCardOverlayField field) {
      if (field.isContactIcon) {
        return VisitingCardContactIconLayout.positionFor(
          iconField: field,
          side: side,
          templateId: vm.templateId,
          isFront: isFront,
        );
      }
      return switch (field) {
        VisitingCardOverlayField.name => side.name,
        VisitingCardOverlayField.designation => side.designation,
        VisitingCardOverlayField.company => side.company,
        VisitingCardOverlayField.tagline => side.tagline,
        VisitingCardOverlayField.phone => side.phone,
        VisitingCardOverlayField.email => side.email,
        VisitingCardOverlayField.website => side.website,
        VisitingCardOverlayField.address => side.address,
        VisitingCardOverlayField.logo => side.logo,
        VisitingCardOverlayField.qr => side.qr,
        VisitingCardOverlayField.phoneIcon ||
        VisitingCardOverlayField.emailIcon ||
        VisitingCardOverlayField.websiteIcon ||
        VisitingCardOverlayField.addressIcon => null,
      };
    }

    void paintDuplicate(String id, VisitingCardFieldTransform t) {
      final isCustom =
          t.duplicateOf == VisitingCardEditContactViewModel.customTextSource;
      final isIcon =
          t.duplicateOf == VisitingCardEditContactViewModel.customIconSource;
      final isShape =
          t.duplicateOf == VisitingCardEditContactViewModel.customShapeSource;
      final isPhoto =
          t.duplicateOf == VisitingCardEditContactViewModel.customImageSource;
      final source = isCustom || isIcon || isShape || isPhoto
          ? null
          : VisitingCardFieldTransform.fieldFromKey(t.duplicateOf ?? '');
      if (!isCustom && !isIcon && !isShape && !isPhoto && source == null) {
        return;
      }
      final pos = isIcon || isShape || isPhoto
          ? null
          : isCustom
          ? const VisitingCardFieldPosition(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              heightFactor: 1.15,
            )
          : posFor(source!);
      final gestureField = source ?? VisitingCardOverlayField.name;
      void place(Widget overlay) {
        addLayer(
          overlay,
          VisitingCardFieldTransform.stackZ(
            VisitingCardEditContactViewModel.duplicateKey(id),
            t,
          ),
        );
      }

      final isContactIconDup = source?.isContactIcon ?? false;
      if (isContactIconDup) {
        final box = size.width * t.size;
        final accent = VisitingCardContactIconLayout.accentFor(side);
        final path = t.duplicateImagePath;
        final iconChild = _fadeField(
          _ContactIconVisual(
            field: source!,
            accent: accent,
            customAssetPath: (path == null || path.isEmpty) ? null : path,
          ),
          t,
        );
        if (!interactive) {
          place(
            Positioned(
              left: size.width * t.left,
              top: size.height * t.top,
              width: box,
              height: box,
              child: Transform.rotate(
                alignment: landscape ? Alignment.topLeft : Alignment.center,
                angle: t.rotation,
                child: _flipField(iconChild, t),
              ),
            ),
          );
          return;
        }
        trackHit(
          VisitingCardEditContactViewModel.duplicateKey(id),
          size.width * t.left,
          size.height * t.top,
          box,
          box,
        );
        place(
          VisitingCardTransformOverlay(
            cardSize: size,
            left: size.width * t.left,
            top: size.height * t.top,
            boxWidth: box,
            boxHeight: box,
            rotation: t.rotation,
            selected: keySelected(
              VisitingCardEditContactViewModel.duplicateKey(id),
            ),
            tightBorder: true,
            borderOnlyWhenSelected: landscape,
            showHandles: !t.locked && !multi,
            onSelect: () => vm.selectDuplicate(id),
            onDeselect: () =>
                multi ? vm.selectDuplicate(id) : vm.clearOverlaySelection(),
            onMove: multi
                ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
                : (dx, dy) => vm.moveOverlay(
                    gestureField,
                    dx,
                    dy,
                    size,
                    duplicateId: id,
                  ),
            onResize: (d) =>
                vm.resizeOverlay(gestureField, d, size, duplicateId: id),
            onUniformScale: landscape
                ? (d, {required fixRight, required fixBottom}) =>
                      vm.scaleOverlayUniform(
                        gestureField,
                        d,
                        size,
                        fixRight: fixRight,
                        fixBottom: fixBottom,
                        duplicateId: id,
                      )
                : null,
            onStretchHorizontal: landscape
                ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                    gestureField,
                    horizontal: true,
                    pixelDelta: d,
                    cardSize: size,
                    fixOpposite: fixOpposite,
                    duplicateId: id,
                  )
                : null,
            onStretchVertical: landscape
                ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                    gestureField,
                    horizontal: false,
                    pixelDelta: d,
                    cardSize: size,
                    fixOpposite: fixOpposite,
                    duplicateId: id,
                  )
                : null,
            onRotate: (r) => vm.rotateOverlay(gestureField, r, duplicateId: id),
            onGestureStart: vm.beginOverlayGesture,
            onGestureEnd: vm.endOverlayGesture,
            child: _flipField(iconChild, t),
          ),
        );
        return;
      }

      if (isIcon ||
          isShape ||
          isPhoto ||
          (source != null && source.isImageOverlay)) {
        final path = t.duplicateImagePath;
        if (path == null || path.isEmpty) return;
        final isAsset = path.startsWith('assets/');
        if (!isAsset && !File(path).existsSync()) return;
        final dupImgBox = size.width * t.size;
        trackHit(
          VisitingCardEditContactViewModel.duplicateKey(id),
          size.width * t.left,
          size.height * t.top,
          dupImgBox,
          dupImgBox,
        );
        place(
          _AspectFitTransformImage(
            key: ValueKey('dup-$id-$path'),
            cardSize: size,
            transform: t,
            assetPath: path,
            isAsset: isAsset,
            interactive: interactive,
            selected: keySelected(
              VisitingCardEditContactViewModel.duplicateKey(id),
            ),
            borderOnlyWhenSelected: landscape,
            showHandles: !t.locked && !multi,
            onResizeShape: isShape
                ? (
                    delta,
                    box, {
                    required horizontal,
                    required fixRight,
                    required fixBottom,
                  }) {
                    vm.stretchOverlayAxis(
                      gestureField,
                      horizontal: horizontal,
                      pixelDelta: delta,
                      cardSize: size,
                      duplicateId: id,
                      fixOpposite: horizontal ? fixRight : fixBottom,
                      seedWidthFraction: box.width / size.width,
                      seedHeightPx: box.height,
                    );
                  }
                : null,
            onSelect: () => vm.selectDuplicate(id),
            onDeselect: () =>
                multi ? vm.selectDuplicate(id) : vm.clearOverlaySelection(),
            onMove: multi
                ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
                : (dx, dy) => vm.moveOverlay(
                    gestureField,
                    dx,
                    dy,
                    size,
                    duplicateId: id,
                  ),
            onResize: (d) =>
                vm.resizeOverlay(gestureField, d, size, duplicateId: id),
            onUniformScale: landscape
                ? (d, {required fixRight, required fixBottom}) =>
                      vm.scaleOverlayUniform(
                        gestureField,
                        d,
                        size,
                        fixRight: fixRight,
                        fixBottom: fixBottom,
                        duplicateId: id,
                      )
                : null,
            onStretchHorizontal: landscape
                ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                    gestureField,
                    horizontal: true,
                    pixelDelta: d,
                    cardSize: size,
                    fixOpposite: fixOpposite,
                    duplicateId: id,
                  )
                : null,
            onStretchVertical: landscape
                ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                    gestureField,
                    horizontal: false,
                    pixelDelta: d,
                    cardSize: size,
                    fixOpposite: fixOpposite,
                    duplicateId: id,
                  )
                : null,
            onRotate: (r) => vm.rotateOverlay(gestureField, r, duplicateId: id),
            onGestureStart: vm.beginOverlayGesture,
            onGestureEnd: vm.endOverlayGesture,
          ),
        );
        return;
      }

      if (pos == null) return;
      final raw = t.duplicateText ?? '';
      if (raw.trim().isEmpty) return;
      final display = visitingCardStyledText(
        raw,
        t,
        templateUppercase: pos.uppercase,
      );
      final baseStyle = applyFont(
        styleFor(pos, fontSize: t.size).copyWith(
          height: landscape ? pos.heightFactor : 1.0,
          letterSpacing: pos.letterSpacing + t.letterSpacing,
          shadows: _fieldShadows(t),
        ),
        t,
      );
      final fillColor = t.textColor ?? pos.color;
      final painter = TextPainter(
        text: TextSpan(
          text: display,
          style: baseStyle.copyWith(color: fillColor),
        ),
        maxLines: 1,
        textAlign: pos.textAlign,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.longestLine,
        textScaler: landscapeFonts ? landscapeTextScaler : TextScaler.linear(1),
      );
      final available = (size.width - size.width * t.left)
          .clamp(1.0, size.width)
          .toDouble();
      late final double boxW;
      var landscapeWrap = false;
      if (landscape) {
        painter.layout(maxWidth: double.infinity);
        final intrinsic = (painter.width + textInset)
            .clamp(1.0, available)
            .toDouble();
        if (t.width != null) {
          final stretched = (size.width * t.width!)
              .clamp(1.0, available)
              .toDouble();
          landscapeWrap = stretched < intrinsic - 0.5 * textInset;
          boxW = stretched;
          painter
            ..maxLines = landscapeWrap ? null : 1
            ..layout(maxWidth: boxW);
        } else {
          boxW = intrinsic;
        }
      } else {
        painter.layout(maxWidth: double.infinity);
        boxW = (painter.width + textInset).clamp(1.0, available);
      }
      final boxH = (painter.height + (landscape ? 2.0 * textInset : 0.0)).clamp(
        1.0,
        size.height,
      );
      final Widget fill;
      if (source == VisitingCardOverlayField.name &&
          pos.hasSplitNameColors &&
          t.textColor == null) {
        final parts = display.trim().split(RegExp(r'\s+'));
        final first = parts.first;
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        final firstColor = pos.firstNameColor ?? pos.color;
        final lastColor = pos.lastNameColor ?? pos.color;
        fill = Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: first,
                style: baseStyle.copyWith(color: firstColor),
              ),
              if (last.isNotEmpty)
                TextSpan(
                  text: ' $last',
                  style: baseStyle.copyWith(color: lastColor),
                ),
            ],
          ),
          maxLines: landscape ? (landscapeWrap ? null : 1) : 1,
          softWrap: landscapeWrap,
          overflow: TextOverflow.visible,
          textAlign: pos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        );
      } else {
        fill = Text(
          display,
          maxLines: landscape ? (landscapeWrap ? null : 1) : 1,
          softWrap: landscapeWrap,
          overflow: TextOverflow.visible,
          textAlign: pos.textAlign,
          style: baseStyle.copyWith(color: fillColor),
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        );
      }
      final text = _fadeField(
        _strokeText(
          fill: fill,
          text: display,
          style: baseStyle.copyWith(color: fillColor),
          transform: t,
          maxLines: landscape ? (landscapeWrap ? null : 1) : 1,
          softWrap: landscapeWrap,
          overflow: TextOverflow.visible,
          textAlign: pos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        ),
        t,
      );
      if (!interactive) {
        place(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: boxW,
            height: boxH,
            child: Transform.rotate(
              alignment: landscape ? Alignment.topLeft : Alignment.center,
              angle: t.rotation,
              child: _flipField(text, t),
            ),
          ),
        );
        return;
      }
      trackHit(
        VisitingCardEditContactViewModel.duplicateKey(id),
        size.width * t.left,
        size.height * t.top,
        boxW,
        boxH,
      );
      place(
        VisitingCardTransformOverlay(
          key: ValueKey('dup-text-$id'),
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: keySelected(
            VisitingCardEditContactViewModel.duplicateKey(id),
          ),
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked && !multi,
          onSelect: () => vm.selectDuplicate(id),
          onDeselect: () =>
              multi ? vm.selectDuplicate(id) : vm.clearOverlaySelection(),
          onMove: multi
              ? (dx, dy) => vm.moveMultiSelection(dx, dy, size)
              : (dx, dy) =>
                    vm.moveOverlay(gestureField, dx, dy, size, duplicateId: id),
          onResize: (d) =>
              vm.resizeOverlay(gestureField, d, size, duplicateId: id),
          onUniformScale: landscape
              ? (d, {required fixRight, required fixBottom}) =>
                    vm.scaleOverlayUniform(
                      gestureField,
                      d,
                      size,
                      fixRight: fixRight,
                      fixBottom: fixBottom,
                      seedWidthFraction: boxW / size.width,
                      seedHeightPx: boxH,
                      duplicateId: id,
                    )
              : null,
          onStretchHorizontal: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  gestureField,
                  horizontal: true,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedWidthFraction: boxW / size.width,
                  duplicateId: id,
                )
              : null,
          onStretchVertical: landscape
              ? (d, {required fixOpposite}) => vm.stretchOverlayAxis(
                  gestureField,
                  horizontal: false,
                  pixelDelta: d,
                  cardSize: size,
                  fixOpposite: fixOpposite,
                  seedHeightPx: boxH,
                  duplicateId: id,
                )
              : null,
          onRotate: (r) => vm.rotateOverlay(gestureField, r, duplicateId: id),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: _flipField(text, t),
        ),
      );
    }

    final sideOverlays = landscape
        ? (isFront ? vm.frontOverlays : vm.backOverlays)
        : vm.currentOverlays;
    for (final entry in sideOverlays.entries) {
      if (!entry.key.startsWith('dup:')) continue;
      paintDuplicate(entry.key.substring(4), entry.value);
    }

    layers.sort((a, b) {
      final byZ = a.$1.compareTo(b.$1);
      if (byZ != 0) return byZ;
      return a.$2.compareTo(b.$2);
    });
    return [for (final layer in layers) layer.$3];
  }
}

/// Sizes logo/QR box to the image aspect ratio so the green border has no
/// vertical (or horizontal) letterbox padding.
class _AspectFitTransformImage extends StatefulWidget {
  const _AspectFitTransformImage({
    super.key,
    required this.cardSize,
    required this.transform,
    required this.assetPath,
    required this.isAsset,
    required this.interactive,
    required this.selected,
    required this.onSelect,
    required this.onDeselect,
    required this.onMove,
    required this.onResize,
    required this.onRotate,
    this.onResizeShape,
    this.onUniformScale,
    this.onStretchHorizontal,
    this.onStretchVertical,
    this.onGestureStart,
    this.onGestureEnd,
    this.borderOnlyWhenSelected = false,
    this.showHandles = true,
  });

  final void Function(
    double delta,
    Size box, {
    required bool horizontal,
    required bool fixRight,
    required bool fixBottom,
  })?
  onResizeShape;

  final Size cardSize;
  final VisitingCardFieldTransform transform;
  final String assetPath;
  final bool isAsset;
  final bool interactive;
  final bool selected;
  final bool showHandles;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final void Function(double dx, double dy) onMove;
  final void Function(double delta) onResize;
  final void Function(double absoluteRadians) onRotate;
  final void Function(
    double pixelDelta, {
    required bool fixRight,
    required bool fixBottom,
  })?
  onUniformScale;
  final void Function(double pixelDelta, {required bool fixOpposite})?
  onStretchHorizontal;
  final void Function(double pixelDelta, {required bool fixOpposite})?
  onStretchVertical;
  final VoidCallback? onGestureStart;
  final VoidCallback? onGestureEnd;
  final bool borderOnlyWhenSelected;

  @override
  State<_AspectFitTransformImage> createState() =>
      _AspectFitTransformImageState();
}

class _AspectFitTransformImageState extends State<_AspectFitTransformImage> {
  /// width / height; null until decoded.
  double? _aspect;

  bool get _isSvg => widget.assetPath.toLowerCase().endsWith('.svg');

  @override
  void initState() {
    super.initState();
    _resolveAspect();
  }

  @override
  void didUpdateWidget(covariant _AspectFitTransformImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _aspect = null;
      _resolveAspect();
    }
  }

  void _resolveAspect() {
    if (_isSvg && widget.isAsset) {
      rootBundle
          .loadString(widget.assetPath)
          .then((source) {
            final viewBox = RegExp(
              r'\bviewBox="([^"]+)"',
            ).firstMatch(source)?.group(1);
            double? aspect;
            if (viewBox != null) {
              final values = viewBox
                  .trim()
                  .split(RegExp(r'[\s,]+'))
                  .map(double.tryParse)
                  .toList();
              if (values.length == 4 &&
                  values[2] != null &&
                  values[3] != null &&
                  values[3]! > 0) {
                aspect = values[2]! / values[3]!;
              }
            }
            if (aspect == null || aspect <= 0) {
              final width = RegExp(r'\bwidth="([\d.]+)').firstMatch(source);
              final height = RegExp(r'\bheight="([\d.]+)').firstMatch(source);
              final widthValue = double.tryParse(width?.group(1) ?? '');
              final heightValue = double.tryParse(height?.group(1) ?? '');
              if (widthValue != null &&
                  heightValue != null &&
                  heightValue > 0) {
                aspect = widthValue / heightValue;
              }
            }
            if (!mounted) return;
            setState(() => _aspect = aspect != null && aspect > 0 ? aspect : 1);
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() => _aspect = 1);
          });
      return;
    }

    final ImageProvider provider = widget.isAsset
        ? AssetImage(widget.assetPath)
        : FileImage(File(widget.assetPath));
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        stream.removeListener(listener);
        if (!mounted || h <= 0) return;
        setState(() => _aspect = w / h);
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!mounted) return;
        setState(() => _aspect = 1);
      },
    );
    stream.addListener(listener);
  }

  bool get _isShape =>
      widget.transform.duplicateOf ==
      VisitingCardEditContactViewModel.customShapeSource;

  (double, double) _boxFor(double aspect) {
    final maxSide = widget.cardSize.width * widget.transform.size;
    final width = aspect >= 1 ? maxSide : maxSide * aspect;
    final height = aspect >= 1 ? maxSide / aspect : maxSide;
    return (
      width * (_isShape ? widget.transform.shapeScaleX : 1),
      height * (_isShape ? widget.transform.shapeScaleY : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspect ?? 1.0;
    final (boxW, boxH) = _boxFor(aspect);
    final left = widget.cardSize.width * widget.transform.left;
    final top = widget.cardSize.height * widget.transform.top;

    final Widget image;
    if (_isSvg && widget.isAsset) {
      image = SvgPicture.asset(
        widget.assetPath,
        key: ValueKey(widget.assetPath),
        width: boxW,
        height: boxH,
        fit: _isShape ? BoxFit.fill : BoxFit.contain,
      );
    } else if (widget.isAsset) {
      image = Image.asset(
        widget.assetPath,
        key: ValueKey(widget.assetPath),
        fit: BoxFit.fill,
        width: boxW,
        height: boxH,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    } else {
      image = Image.file(
        File(widget.assetPath),
        key: ValueKey(widget.assetPath),
        fit: BoxFit.fill,
        width: boxW,
        height: boxH,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    final tint =
        widget.transform.duplicateOf ==
            VisitingCardEditContactViewModel.customShapeSource
        ? widget.transform.textColor
        : null;
    final picture = tint == null
        ? image
        : ColorFiltered(
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            child: image,
          );

    if (!widget.interactive) {
      return Positioned(
        left: left,
        top: top,
        width: boxW,
        height: boxH,
        child: Transform.rotate(
          alignment: widget.borderOnlyWhenSelected
              ? Alignment.topLeft
              : Alignment.center,
          angle: widget.transform.rotation,
          child: _fadeField(
            _flipField(picture, widget.transform),
            widget.transform,
          ),
        ),
      );
    }

    return VisitingCardTransformOverlay(
      cardSize: widget.cardSize,
      left: left,
      top: top,
      boxWidth: boxW,
      boxHeight: boxH,
      rotation: widget.transform.rotation,
      selected: widget.selected,
      tightBorder: true,
      borderOnlyWhenSelected: widget.borderOnlyWhenSelected,
      showHandles: widget.showHandles && !widget.transform.locked,
      onSelect: widget.onSelect,
      onDeselect: widget.onDeselect,
      onMove: widget.onMove,
      onResize: widget.onResize,
      onUniformScale: widget.onUniformScale,
      onStretchHorizontal: widget.onResizeShape == null
          ? widget.onStretchHorizontal
          : (delta, {required fixOpposite}) => widget.onResizeShape!(
              delta,
              Size(boxW, boxH),
              horizontal: true,
              fixRight: fixOpposite,
              fixBottom: false,
            ),
      onStretchVertical: widget.onResizeShape == null
          ? widget.onStretchVertical
          : (delta, {required fixOpposite}) => widget.onResizeShape!(
              delta,
              Size(boxW, boxH),
              horizontal: false,
              fixRight: false,
              fixBottom: fixOpposite,
            ),
      onRotate: widget.onRotate,
      onGestureStart: widget.onGestureStart,
      onGestureEnd: widget.onGestureEnd,
      child: _fadeField(
        _flipField(picture, widget.transform),
        widget.transform,
      ),
    );
  }
}

class VisitingCardSidePager extends StatelessWidget {
  const VisitingCardSidePager({
    super.key,
    required this.currentPage,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: canGoPrevious ? onPrevious : null,
          child: SvgPicture.asset(
            canGoPrevious
                ? ui.AppAssets.activeLeftSideArrow
                : ui.AppAssets.inactiveLeftSideArrow,
            width: 28.w,
            height: 28.w,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$currentPage/2',
            style: ui.AppTextStyles.iconUnderText(
              color: const Color(0xFF1A1A1A),
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
          ),
        ),
        GestureDetector(
          onTap: canGoNext ? onNext : null,
          child: SvgPicture.asset(
            canGoNext
                ? ui.AppAssets.activeRightSideArrow
                : ui.AppAssets.inactiveRightSideArrow,
            width: 28.w,
            height: 28.w,
          ),
        ),
      ],
    );
  }
}

/// Generated duplicate contact icon or a replaced SVG/image.
class _ContactIconVisual extends StatelessWidget {
  const _ContactIconVisual({
    required this.field,
    required this.accent,
    this.customAssetPath,
  });

  final VisitingCardOverlayField field;
  final Color accent;
  final String? customAssetPath;

  @override
  Widget build(BuildContext context) {
    final path = customAssetPath?.trim();
    if (path != null && path.isNotEmpty) {
      final isAsset = path.startsWith('assets/');
      final isSvg = path.toLowerCase().endsWith('.svg');
      if (isSvg && isAsset) {
        return SvgPicture.asset(path, fit: BoxFit.contain);
      }
      if (isAsset) {
        return Image.asset(path, fit: BoxFit.contain);
      }
      if (File(path).existsSync()) {
        return Image.file(File(path), fit: BoxFit.contain);
      }
    }

    final icon = Icon(
      VisitingCardContactIconLayout.materialIcon(field),
      color: Colors.white,
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.58,
          heightFactor: 0.58,
          child: FittedBox(child: icon),
        ),
      ),
    );
  }
}

class _ContactIconArtwork {
  const _ContactIconArtwork({this.backgroundColor, this.iconPng});

  final Color? backgroundColor;
  final Uint8List? iconPng;
}

/// Extracts each template's baked icon so moving it preserves the exact
/// artwork, while sampling the source background to clear its old position.
class _ContactIconArtworkCache {
  static final Map<String, Future<_ContactIconArtwork>> _artwork = {};
  static final Map<String, Future<img.Image?>> _images = {};

  static Future<_ContactIconArtwork> forIcon({
    required String assetPath,
    required double cardAspectRatio,
    required double left,
    required double top,
    required double size,
  }) {
    final key = [
      assetPath,
      cardAspectRatio.toStringAsFixed(4),
      left.toStringAsFixed(4),
      top.toStringAsFixed(4),
      size.toStringAsFixed(4),
    ].join('|');
    return _artwork.putIfAbsent(
      key,
      () => _readArtwork(
        assetPath: assetPath,
        cardAspectRatio: cardAspectRatio,
        left: left,
        top: top,
        size: size,
      ),
    );
  }

  static Future<_ContactIconArtwork> _readArtwork({
    required String assetPath,
    required double cardAspectRatio,
    required double left,
    required double top,
    required double size,
  }) async {
    const fallback = _ContactIconArtwork();
    if (!assetPath.toLowerCase().endsWith('.png')) return fallback;

    final image = await _imageFor(assetPath);
    if (image == null || image.width == 0 || image.height == 0) {
      return fallback;
    }

    final centerX = image.width * (left + size / 2);
    final centerY = image.height * (top + size * cardAspectRatio / 2);
    final radiusX = image.width * size * 0.70;
    final radiusY = image.height * size * cardAspectRatio * 0.70;
    final outsidePixels = <(int, int, int)>[];
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = (centerX + math.cos(angle) * radiusX).round();
      final y = (centerY + math.sin(angle) * radiusY).round();
      final pixel = image.getPixel(
        x.clamp(0, image.width - 1).toInt(),
        y.clamp(0, image.height - 1).toInt(),
      );
      outsidePixels.add((
        _channel8(pixel.rNormalized),
        _channel8(pixel.gNormalized),
        _channel8(pixel.bNormalized),
      ));
    }

    final backgroundColor = _dominantColor(outsidePixels) ?? Colors.white;
    return _ContactIconArtwork(
      backgroundColor: backgroundColor,
      iconPng: _extractIcon(
        image,
        centerX: centerX,
        centerY: centerY,
        size: size,
        backgroundSamples: outsidePixels,
      ),
    );
  }

  /// Copies the original icon box and makes only the connected background
  /// pixels transparent. This keeps badge shapes and even glyphs that use the
  /// same color as the surrounding template intact (for example, green glyphs
  /// inside a white diamond on a green card).
  static Uint8List? _extractIcon(
    img.Image source, {
    required double centerX,
    required double centerY,
    required double size,
    required List<(int, int, int)> backgroundSamples,
  }) {
    final cropSide = (source.width * size).round().clamp(1, source.width);
    final sourceLeft = (centerX - cropSide / 2).round();
    final sourceTop = (centerY - cropSide / 2).round();
    final sourceCrop = img.Image(
      width: cropSide,
      height: cropSide,
      numChannels: 4,
    );
    final transparentBackground = List<bool>.filled(cropSide * cropSide, false);
    final queue = <int>[];

    bool inBounds(int x, int y) =>
        x >= 0 && y >= 0 && x < source.width && y < source.height;

    int pixelIndex(int x, int y) => y * cropSide + x;

    void markBackground(int x, int y) {
      final index = pixelIndex(x, y);
      if (transparentBackground[index]) return;
      transparentBackground[index] = true;
      queue.add(index);
    }

    // Pixels outside the source image are already transparent and act as
    // background seeds for icons close to a card edge.
    for (var y = 0; y < cropSide; y++) {
      for (var x = 0; x < cropSide; x++) {
        final sourceX = sourceLeft + x;
        final sourceY = sourceTop + y;
        if (!inBounds(sourceX, sourceY)) {
          markBackground(x, y);
          sourceCrop.setPixelRgba(x, y, 0, 0, 0, 0);
        } else {
          final pixel = source.getPixel(sourceX, sourceY);
          sourceCrop.setPixelRgba(
            x,
            y,
            _channel8(pixel.rNormalized),
            _channel8(pixel.gNormalized),
            _channel8(pixel.bNormalized),
            _channel8(pixel.aNormalized),
          );
        }
      }
    }

    void seedBackground(int x, int y) {
      final sourceX = sourceLeft + x;
      final sourceY = sourceTop + y;
      if (!inBounds(sourceX, sourceY)) {
        markBackground(x, y);
        return;
      }
      final pixel = source.getPixel(sourceX, sourceY);
      final isTransparent = pixel.aNormalized < 0.04;
      final isSampledBackground = backgroundSamples.any((sample) {
        final (r, g, b) = sample;
        return (pixel.r - r).abs() +
                (pixel.g - g).abs() +
                (pixel.b - b).abs() <=
            50;
      });
      if (isTransparent || isSampledBackground) markBackground(x, y);
    }

    for (var x = 0; x < cropSide; x++) {
      seedBackground(x, 0);
      seedBackground(x, cropSide - 1);
    }
    for (var y = 0; y < cropSide; y++) {
      seedBackground(0, y);
      seedBackground(cropSide - 1, y);
    }

    bool isBackgroundStep(int fromX, int fromY, int toX, int toY) {
      final fromSourceX = sourceLeft + fromX;
      final fromSourceY = sourceTop + fromY;
      final toSourceX = sourceLeft + toX;
      final toSourceY = sourceTop + toY;
      if (!inBounds(fromSourceX, fromSourceY) ||
          !inBounds(toSourceX, toSourceY)) {
        return true;
      }
      final from = source.getPixel(fromSourceX, fromSourceY);
      final to = source.getPixel(toSourceX, toSourceY);
      if (to.aNormalized < 0.04) return true;
      // Follow smooth color changes in gradients, but stop at the hard edges
      // of icon artwork so its interior remains connected and untouched.
      return (from.r - to.r).abs() <= 24 &&
          (from.g - to.g).abs() <= 24 &&
          (from.b - to.b).abs() <= 24;
    }

    const neighbors = <(int, int)>[(1, 0), (-1, 0), (0, 1), (0, -1)];
    for (var head = 0; head < queue.length; head++) {
      final index = queue[head];
      final x = index % cropSide;
      final y = index ~/ cropSide;
      for (final (dx, dy) in neighbors) {
        final nextX = x + dx;
        final nextY = y + dy;
        if (nextX < 0 || nextY < 0 || nextX >= cropSide || nextY >= cropSide) {
          continue;
        }
        final nextIndex = pixelIndex(nextX, nextY);
        if (transparentBackground[nextIndex] ||
            !isBackgroundStep(x, y, nextX, nextY)) {
          continue;
        }
        transparentBackground[nextIndex] = true;
        queue.add(nextIndex);
      }
    }

    var artworkPixels = 0;
    for (var y = 0; y < cropSide; y++) {
      for (var x = 0; x < cropSide; x++) {
        final index = pixelIndex(x, y);
        if (transparentBackground[index]) {
          sourceCrop.setPixelRgba(x, y, 0, 0, 0, 0);
        } else if (sourceCrop.getPixel(x, y).aNormalized > 0.04) {
          artworkPixels++;
        }
      }
    }

    if (artworkPixels < 8 || artworkPixels > cropSide * cropSide * 0.94) {
      return null;
    }
    return Uint8List.fromList(img.encodePng(sourceCrop));
  }

  static Future<img.Image?> _imageFor(String assetPath) {
    final cached = _images[assetPath];
    if (cached != null) return cached;

    final pending = _loadImage(assetPath);
    _images[assetPath] = pending;
    while (_images.length > 4) {
      _images.remove(_images.keys.first);
    }
    return pending;
  }

  static Future<img.Image?> _loadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return img.decodeImage(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } catch (_) {
      return null;
    }
  }

  static int _colorKey(int r, int g, int b) =>
      ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);

  static int _channel8(num value) =>
      (value * 255).round().clamp(0, 255).toInt();

  static Color? _dominantColor(List<(int, int, int)> pixels) {
    final buckets = <int, _ArtworkColorBucket>{};
    for (final (r, g, b) in pixels) {
      (buckets[_colorKey(r, g, b)] ??= _ArtworkColorBucket()).add(r, g, b);
    }
    if (buckets.isEmpty) return null;
    return buckets.values.reduce((a, b) => a.count >= b.count ? a : b).color;
  }
}

class _ArtworkColorBucket {
  int count = 0;
  int red = 0;
  int green = 0;
  int blue = 0;

  void add(int r, int g, int b) {
    count++;
    red += r;
    green += g;
    blue += b;
  }

  Color get color => Color.fromARGB(
    255,
    (red / count).round(),
    (green / count).round(),
    (blue / count).round(),
  );
}

class _TemplateBackgroundCover extends StatelessWidget {
  const _TemplateBackgroundCover({required this.artwork});

  final Future<_ContactIconArtwork> artwork;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ContactIconArtwork>(
      future: artwork,
      builder: (context, snapshot) => ColoredBox(
        // Keep the original baked icon visible until its matching background
        // color is ready; a white fallback flashes as a square on dark cards.
        color: snapshot.data?.backgroundColor ?? Colors.transparent,
      ),
    );
  }
}

class _TemplateContactIconAsset extends StatelessWidget {
  const _TemplateContactIconAsset({required this.assetPath, this.tint});

  final String assetPath;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    if (assetPath == VisitingCardContactIconLayout.orangeDiamondWebWidget) {
      return const _OrangeDiamondWebsiteIcon();
    }

    Widget image = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
    if (tint != null) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(tint!, BlendMode.srcIn),
        child: image,
      );
    }
    return image;
  }
}

class _OrangeDiamondWebsiteIcon extends StatelessWidget {
  const _OrangeDiamondWebsiteIcon();

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8A00);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: math.pi / 4,
                  child: SizedBox.square(
                    dimension: side * 0.67,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: orange,
                          width: math.max(1, side * 0.035).toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.48,
                  heightFactor: 0.48,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      orange,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/visiting_card_contact_icons/black_web.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TemplateContactIconVisual extends StatelessWidget {
  const _TemplateContactIconVisual({
    required this.field,
    required this.fallbackAccent,
    required this.customAssetPath,
    required this.artwork,
  });

  final VisitingCardOverlayField field;
  final Color fallbackAccent;
  final String? customAssetPath;
  final Future<_ContactIconArtwork> artwork;

  @override
  Widget build(BuildContext context) {
    if (customAssetPath != null && customAssetPath!.trim().isNotEmpty) {
      return _ContactIconVisual(
        field: field,
        accent: fallbackAccent,
        customAssetPath: customAssetPath,
      );
    }

    return FutureBuilder<_ContactIconArtwork>(
      future: artwork,
      builder: (context, snapshot) {
        final sampled = snapshot.data;
        if (sampled == null) {
          return const SizedBox.expand();
        }
        final iconPng = sampled.iconPng;
        if (iconPng != null) {
          return Image.memory(
            iconPng,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          );
        }
        return _ContactIconVisual(field: field, accent: fallbackAccent);
      },
    );
  }
}
