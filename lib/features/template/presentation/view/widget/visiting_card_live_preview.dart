import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_font_style.dart';
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';
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
        style: style.copyWith(
          foreground: paint,
          shadows: const <Shadow>[],
        ),
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
  /// box hugs the text instead of the template field width. Fonts stay .sp.
  final bool eightPointSelection;

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
    final offset =
        _pageController.page ?? _pageController.initialPage.toDouble();
    // A finger swipe already owns the motion once it has crossed onto this
    // page. Taking over with animateToPage cuts that fling short.
    if (offset.round() == page) return;

    // Details/download preview has no in-widget pager. Jump so capture never
    // snapshots the mid-swipe frame (front-right + back-left stitched).
    // Arrow changes still animate, except while a capture is running.
    final animateSideChange = !widget.vm.jumpSideForCapture &&
        (widget.showPager || widget.enableFieldTransform);

    _ignorePageCallback = true;
    if (!animateSideChange) {
      _pageController.jumpToPage(page);
      _ignorePageCallback = false;
      return;
    }
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
      physics: widget.enableFieldTransform && widget.vm.hasSelection
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
      onPageChanged: _onPageChanged,
      children: [
        face(0),
        face(1),
      ],
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
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFF5F5F5),
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
            if (interactive)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.vm.clearOverlaySelection,
                ),
              ),
            ..._buildOverlayChildren(
              size: size,
              side: side,
              fontFamily: layout.fontFamily,
              isFront: isFront,
              interactive: interactive,
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOverlayChildren({
    required Size size,
    required VisitingCardSidePositions side,
    required String fontFamily,
    required bool isFront,
    required bool interactive,
  }) {
    final vm = widget.vm;
    final layers = <(int, int, Widget)>[];
    var layerSeq = 0;
    // Landscape editor uses its own sizing (no ScreenUtil .sp) so the
    // selection border matches the painted glyphs exactly.
    final landscapeFonts = widget.selectionBorderOnlyWhenSelected;
    // Edit Contact Info uses the 8-handle frame and intrinsic text width.
    // Landscape fonts stay on the landscape editor only.
    final landscape = landscapeFonts || widget.eightPointSelection;
    // Card box is 0.85 of the previous landscape size. Text follows that
    // ratio even when the old 1.35 cap would have kept glyphs the same size.
    final landscapeFontScale = landscapeFonts
        ? (size.width / 220.0).clamp(0.55, 1.15)
        : 1.0;
    const landscapeTextScaler = TextScaler.noScaling;

    double resolveFont(double designSize) {
      if (landscapeFonts) return designSize * landscapeFontScale;
      return designSize.sp;
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

    TextStyle styleFor(VisitingCardFieldPosition pos, {double? fontSize}) {
      final resolved = resolveFont(fontSize ?? pos.fontSize);
      if (fontFamily == VisitingCardFonts.inter) {
        return GoogleFonts.inter(
          fontSize: resolved,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return GoogleFonts.roboto(
          fontSize: resolved,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
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
        return GoogleFonts.inter(
          fontSize: resolved,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return GoogleFonts.roboto(
          fontSize: resolved,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
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
      final baseStyle = applyVisitingCardFont(
        nameStyleFor(
          pos,
          clipped,
        ).copyWith(
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
        final intrinsic =
            (painter.width + 1.0).clamp(1.0, availableWidth).toDouble();
        if (t.width != null) {
          final stretched =
              (size.width * t.width!).clamp(1.0, availableWidth).toDouble();
          landscapeWrap = stretched < intrinsic - 0.5;
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
      final boxH = (painter.height + (landscape ? 2.0 : 0.0))
          .clamp(1.0, size.height);

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
          maxLines: landscape
              ? (landscapeWrap ? null : 1)
              : pos.maxLines,
          softWrap: landscapeWrap,
          overflow: landscape
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          textScaler: landscapeFonts ? landscapeTextScaler : null,
        );
      } else {
        text = Text(
          display,
          maxLines: landscape
              ? (landscapeWrap ? null : 1)
              : pos.maxLines,
          softWrap: landscapeWrap,
          overflow: landscape
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
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

      addOverlay(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: vm.selectedOverlay == field,
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
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
      final isTagline = field == VisitingCardOverlayField.tagline;
      final configuredWidth = size.width * (t.width ?? configPos.width ?? 0.4);
      final availableWidth = (size.width - (size.width * t.left))
          .clamp(1.0, size.width)
          .toDouble();
      // Landscape: free line + select-border width (intrinsic / stretch).
      final maxW = landscape
          ? availableWidth
          : (isTagline
              ? configuredWidth.clamp(1.0, availableWidth).toDouble()
              : configuredWidth);
      final maxLines = isTagline ? null : configPos.maxLines;
      final display = visitingCardStyledText(
        value,
        t,
        templateUppercase: configPos.uppercase,
      );

      TextStyle measureStyleFor(double fontSize) => applyVisitingCardFont(
            styleFor(
              configPos,
              fontSize: fontSize,
            ).copyWith(
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
      }) =>
          TextPainter(
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
      if (landscape) {
        // Single-line intrinsic so select never forces a newline.
        painter = layoutText(measureStyle, double.infinity, lines: 1);
        final intrinsic =
            (painter.width + 1.0).clamp(1.0, availableWidth).toDouble();
        if (t.width != null) {
          final stretched =
              (size.width * t.width!).clamp(1.0, availableWidth).toDouble();
          landscapeWrap = isTagline || stretched < intrinsic - 0.5;
          boxW = stretched;
          painter = layoutText(
            measureStyle,
            boxW,
            lines: landscapeWrap ? null : 1,
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

      final boxH = (painter.height + (landscape ? 2.0 : 0.0))
          .clamp(1.0, size.height);

      final fill = Text(
        display,
        maxLines: landscape
            ? (landscapeWrap ? null : 1)
            : maxLines,
        softWrap: landscape ? landscapeWrap : isTagline,
        overflow: landscape
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
          maxLines: landscape ? (landscapeWrap ? null : 1) : maxLines,
          softWrap: landscape ? landscapeWrap : isTagline,
          overflow: landscape
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

      addOverlay(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: vm.selectedOverlay == field,
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
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
      addOverlay(
        _AspectFitTransformImage(
          key: ValueKey('transform-$field-$assetPath-$isFront'),
          cardSize: size,
          transform: t,
          assetPath: assetPath,
          isAsset: isAsset,
          interactive: interactive,
          selected: vm.selectedOverlay == field,
          borderOnlyWhenSelected: landscape,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
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

    if (vm.hasChosenLogo) {
      addTransformImage(
        field: VisitingCardOverlayField.logo,
        configPos: side.logo,
        assetPath: vm.logoAssetPath,
      );
    }
    if (vm.hasChosenQr) {
      addTransformImage(
        field: VisitingCardOverlayField.qr,
        configPos: side.qr,
        assetPath: vm.qrAssetPath,
      );
    }

    VisitingCardFieldPosition? posFor(VisitingCardOverlayField field) {
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
      final selected = vm.selectedDuplicateId == id;
      void place(Widget overlay) {
        addLayer(
          overlay,
          VisitingCardFieldTransform.stackZ(
            VisitingCardEditContactViewModel.duplicateKey(id),
            t,
          ),
        );
      }

      if (isIcon ||
          isShape ||
          isPhoto ||
          (source != null && source.isImageOverlay)) {
        final path = t.duplicateImagePath;
        if (path == null || path.isEmpty) return;
        final isAsset = path.startsWith('assets/');
        if (!isAsset && !File(path).existsSync()) return;
        place(
          _AspectFitTransformImage(
            key: ValueKey('dup-$id-$path'),
            cardSize: size,
            transform: t,
            assetPath: path,
            isAsset: isAsset,
            interactive: interactive,
            selected: selected,
            borderOnlyWhenSelected: landscape,
            onSelect: () => vm.selectDuplicate(id),
            onDeselect: vm.clearOverlaySelection,
            onMove: (dx, dy) =>
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
            onRotate: (r) =>
                vm.rotateOverlay(gestureField, r, duplicateId: id),
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
      final baseStyle = applyVisitingCardFont(
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
        final intrinsic =
            (painter.width + 1.0).clamp(1.0, available).toDouble();
        if (t.width != null) {
          final stretched =
              (size.width * t.width!).clamp(1.0, available).toDouble();
          landscapeWrap = stretched < intrinsic - 0.5;
          boxW = stretched;
          painter
            ..maxLines = landscapeWrap ? null : 1
            ..layout(maxWidth: boxW);
        } else {
          boxW = intrinsic;
        }
      } else {
        painter.layout(maxWidth: double.infinity);
        boxW = (painter.width + 1).clamp(1.0, available);
      }
      final boxH = (painter.height + (landscape ? 2.0 : 0.0))
          .clamp(1.0, size.height);
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
      place(
        VisitingCardTransformOverlay(
          key: ValueKey('dup-text-$id'),
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: selected,
          tightBorder: true,
          borderOnlyWhenSelected: landscape,
          showHandles: !t.locked,
          onSelect: () => vm.selectDuplicate(id),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) =>
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
          onRotate: (r) =>
              vm.rotateOverlay(gestureField, r, duplicateId: id),
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
    this.onUniformScale,
    this.onStretchHorizontal,
    this.onStretchVertical,
    this.onGestureStart,
    this.onGestureEnd,
    this.borderOnlyWhenSelected = false,
  });

  final Size cardSize;
  final VisitingCardFieldTransform transform;
  final String assetPath;
  final bool isAsset;
  final bool interactive;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final void Function(double dx, double dy) onMove;
  final void Function(double delta) onResize;
  final void Function(double absoluteRadians) onRotate;
  final void Function(
    double pixelDelta, {
    required bool fixRight,
    required bool fixBottom,
  })? onUniformScale;
  final void Function(
    double pixelDelta, {
    required bool fixOpposite,
  })? onStretchHorizontal;
  final void Function(
    double pixelDelta, {
    required bool fixOpposite,
  })? onStretchVertical;
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
    if (_isSvg) {
      _aspect = 1;
    } else {
      _resolveAspect();
    }
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

  (double, double) _boxFor(double aspect) {
    final maxSide = widget.cardSize.width * widget.transform.size;
    if (aspect >= 1) {
      return (maxSide, maxSide / aspect);
    }
    return (maxSide * aspect, maxSide);
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
        fit: BoxFit.contain,
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

    final tint = widget.transform.duplicateOf ==
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
          alignment:
              widget.borderOnlyWhenSelected ? Alignment.topLeft : Alignment.center,
          angle: widget.transform.rotation,
          child: _fadeField(_flipField(picture, widget.transform), widget.transform),
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
      showHandles: !widget.transform.locked,
      onSelect: widget.onSelect,
      onDeselect: widget.onDeselect,
      onMove: widget.onMove,
      onResize: widget.onResize,
      onUniformScale: widget.onUniformScale,
      onStretchHorizontal: widget.onStretchHorizontal,
      onStretchVertical: widget.onStretchVertical,
      onRotate: widget.onRotate,
      onGestureStart: widget.onGestureStart,
      onGestureEnd: widget.onGestureEnd,
      child: _fadeField(_flipField(picture, widget.transform), widget.transform),
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
