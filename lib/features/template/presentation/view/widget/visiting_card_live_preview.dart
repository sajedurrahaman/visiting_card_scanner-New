import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_transform_overlay.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

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
    _animateTo(widget.sideOverride ?? widget.vm.sideIndex);
    setState(() {});
  }

  void _animateTo(int page) {
    if (!_pageController.hasClients) return;
    final offset =
        _pageController.page ?? _pageController.initialPage.toDouble();
    if ((offset - page).abs() < 0.001) return;

    // Details/download preview has no in-widget pager. Jump so capture never
    // snapshots the mid-swipe frame (front-right + back-left stitched).
    final animateSideChange =
        widget.showPager || widget.enableFieldTransform;

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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: PageView.builder(
                controller: _pageController,
                itemCount: 2,
                // Allow finger swipe 1/2 ↔ 2/2; lock only while an overlay
                // is selected so move/rotate/resize keep winning gestures.
                physics:
                    widget.enableFieldTransform &&
                        widget.vm.selectedOverlay != null
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                onPageChanged: _onPageChanged,
                itemBuilder: (_, index) => _buildCardFace(sideIndex: index),
              ),
            ),
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
    final children = <Widget>[];

    TextStyle styleFor(VisitingCardFieldPosition pos, {double? fontSize}) {
      final sizeSp = (fontSize ?? pos.fontSize).sp;
      if (fontFamily == VisitingCardFonts.inter) {
        return GoogleFonts.inter(
          fontSize: sizeSp,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return GoogleFonts.roboto(
          fontSize: sizeSp,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSp,
        fontWeight: pos.fontWeight,
        fontStyle: pos.fontStyle,
        color: pos.color,
        letterSpacing: pos.letterSpacing,
        height: pos.heightFactor,
      );
    }

    TextStyle nameStyleFor(VisitingCardFieldPosition pos, String rawName) {
      final sizeSp = pos.resolvedNameFontSize(rawName).sp;
      if (fontFamily == VisitingCardFonts.inter) {
        return GoogleFonts.inter(
          fontSize: sizeSp,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      if (fontFamily == VisitingCardFonts.roboto) {
        return GoogleFonts.roboto(
          fontSize: sizeSp,
          fontWeight: pos.fontWeight,
          fontStyle: pos.fontStyle,
          color: pos.color,
          letterSpacing: pos.letterSpacing,
          height: pos.heightFactor,
        );
      }
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeSp,
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
      final display = pos.uppercase ? clipped.toUpperCase() : clipped;
      final t = vm.resolvedTransform(field, isFront: isFront);
      final maxW = size.width * (t.width ?? pos.width ?? 0.48);
      final baseStyle = nameStyleFor(
        pos,
        clipped,
      ).copyWith(fontSize: t.size.sp, height: 1.0);

      final Widget text;
      if (pos.hasSplitNameColors) {
        final parts = display.trim().split(RegExp(r'\s+'));
        final first = parts.first;
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        final firstColor = pos.firstNameColor ?? pos.color;
        final lastColor = pos.lastNameColor ?? pos.color;
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
          maxLines: pos.maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: pos.textAlign,
        );
      } else {
        text = Text(
          display,
          maxLines: pos.maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          style: baseStyle.copyWith(color: pos.color),
        );
      }

      final painter = TextPainter(
        text: TextSpan(text: display, style: baseStyle),
        maxLines: pos.maxLines,
        ellipsis: '…',
        textAlign: pos.textAlign,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxW);
      final boxW = painter.width.clamp(1.0, maxW);
      final boxH = painter.height.clamp(1.0, size.height);

      if (!interactive) {
        children.add(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: boxW,
            height: boxH,
            child: Transform.rotate(angle: t.rotation, child: text),
          ),
        );
        return;
      }

      children.add(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: vm.selectedOverlay == field,
          tightBorder: true,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: text,
        ),
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
      final maxW = isTagline
          ? configuredWidth.clamp(1.0, availableWidth).toDouble()
          : configuredWidth;
      final maxLines = isTagline ? null : configPos.maxLines;
      final display = configPos.uppercase ? value.toUpperCase() : value;

      TextStyle measureStyleFor(double fontSize) =>
          styleFor(configPos, fontSize: fontSize).copyWith(height: 1.0);

      TextPainter layoutText(TextStyle style) => TextPainter(
        text: TextSpan(text: display, style: style),
        maxLines: maxLines,
        // A tagline must always show its complete text; it wraps instead
        // of replacing the end of the text with an ellipsis.
        ellipsis: isTagline ? null : '…',
        textAlign: configPos.textAlign,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxW);

      var measureStyle = measureStyleFor(t.size);
      var painter = layoutText(measureStyle);

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
          var bestPainter = layoutText(bestStyle);
          for (var i = 0; i < 18; i++) {
            final candidateSize = (low + high) / 2;
            final candidateStyle = measureStyleFor(candidateSize);
            final candidatePainter = layoutText(candidateStyle);
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

      final boxW = painter.width.clamp(1.0, maxW);
      final boxH = painter.height.clamp(1.0, size.height);

      final text = Text(
        display,
        maxLines: maxLines,
        softWrap: isTagline,
        overflow: isTagline ? TextOverflow.visible : TextOverflow.ellipsis,
        textAlign: configPos.textAlign,
        style: measureStyle,
      );

      if (!interactive) {
        children.add(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: boxW,
            height: boxH,
            child: Transform.rotate(angle: t.rotation, child: text),
          ),
        );
        return;
      }

      children.add(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: boxW,
          boxHeight: boxH,
          rotation: t.rotation,
          selected: vm.selectedOverlay == field,
          tightBorder: true,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
          child: text,
        ),
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
      children.add(
        _AspectFitTransformImage(
          key: ValueKey('transform-$field-$assetPath-$isFront'),
          cardSize: size,
          transform: t,
          assetPath: assetPath,
          isAsset: isAsset,
          interactive: interactive,
          selected: vm.selectedOverlay == field,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onRotate: (r) => vm.rotateOverlay(field, r),
          onGestureStart: vm.beginOverlayGesture,
          onGestureEnd: vm.endOverlayGesture,
        ),
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

    return children;
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
    this.onGestureStart,
    this.onGestureEnd,
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
  final VoidCallback? onGestureStart;
  final VoidCallback? onGestureEnd;

  @override
  State<_AspectFitTransformImage> createState() =>
      _AspectFitTransformImageState();
}

class _AspectFitTransformImageState extends State<_AspectFitTransformImage> {
  /// width / height; null until decoded.
  double? _aspect;

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

    final image = widget.isAsset
        ? Image.asset(
            widget.assetPath,
            key: ValueKey(widget.assetPath),
            fit: BoxFit.fill,
            width: boxW,
            height: boxH,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : Image.file(
            File(widget.assetPath),
            key: ValueKey(widget.assetPath),
            fit: BoxFit.fill,
            width: boxW,
            height: boxH,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          );

    if (!widget.interactive) {
      return Positioned(
        left: left,
        top: top,
        width: boxW,
        height: boxH,
        child: Transform.rotate(angle: widget.transform.rotation, child: image),
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
      onSelect: widget.onSelect,
      onDeselect: widget.onDeselect,
      onMove: widget.onMove,
      onResize: widget.onResize,
      onRotate: widget.onRotate,
      onGestureStart: widget.onGestureStart,
      onGestureEnd: widget.onGestureEnd,
      child: image,
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
