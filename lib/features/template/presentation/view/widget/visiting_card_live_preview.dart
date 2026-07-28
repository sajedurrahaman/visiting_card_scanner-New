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
      _jumpTo(_sideIndex);
    } else if (oldWidget.sideOverride != widget.sideOverride) {
      _jumpTo(_sideIndex);
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
    _jumpTo(widget.sideOverride ?? widget.vm.sideIndex);
    setState(() {});
  }

  void _jumpTo(int page) {
    if (!_pageController.hasClients) return;
    final current = _pageController.page?.round() ?? _pageController.initialPage;
    if (current == page) return;
    _ignorePageCallback = true;
    _pageController.jumpToPage(page);
    _ignorePageCallback = false;
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
                physics: widget.enableFieldTransform &&
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
        final interactive = widget.enableFieldTransform &&
            sideIndex == widget.vm.sideIndex;
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

    void addText(VisitingCardFieldPosition? pos, String value) {
      if (pos == null || value.trim().isEmpty) return;
      children.add(
        _PositionedField(
          cardSize: size,
          position: pos,
          child: Text(
            pos.uppercase ? value.toUpperCase() : value,
            maxLines: pos.maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: pos.textAlign,
            style: styleFor(pos),
          ),
        ),
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
      final display = pos.uppercase ? value.toUpperCase() : value;
      final baseStyle = nameStyleFor(pos, value);

      final Widget child;
      if (pos.hasSplitNameColors) {
        final parts = display.trim().split(RegExp(r'\s+'));
        final first = parts.first;
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        final firstColor = pos.firstNameColor ?? pos.color;
        final lastColor = pos.lastNameColor ?? pos.color;
        child = Text.rich(
          TextSpan(
            children: [
              TextSpan(text: first, style: baseStyle.copyWith(color: firstColor)),
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
        child = Text(
          display,
          maxLines: pos.maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: pos.textAlign,
          style: baseStyle.copyWith(color: pos.color),
        );
      }

      children.add(
        _PositionedField(
          cardSize: size,
          position: pos,
          child: child,
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
      final maxW = size.width * (t.width ?? configPos.width ?? 0.4);
      final fontSize = t.size;
      final style = styleFor(configPos, fontSize: fontSize);
      final display = configPos.uppercase ? value.toUpperCase() : value;

      // Tight box = actual painted text (no extra green-border padding).
      final painter = TextPainter(
        text: TextSpan(text: display, style: style),
        maxLines: configPos.maxLines,
        ellipsis: '…',
        textAlign: configPos.textAlign,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxW);
      final boxW = painter.width.clamp(1.0, maxW);
      final boxH = painter.height.clamp(1.0, size.height);

      final text = Text(
        display,
        maxLines: configPos.maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: configPos.textAlign,
        style: style,
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
      final box = size.width * t.size;
      final image = isAsset
          ? Image.asset(
              assetPath,
              key: ValueKey(assetPath),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            )
          : Image.file(
              File(assetPath),
              key: ValueKey(assetPath),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            );

      if (!interactive) {
        children.add(
          Positioned(
            left: size.width * t.left,
            top: size.height * t.top,
            width: box,
            height: box,
            child: Transform.rotate(angle: t.rotation, child: image),
          ),
        );
        return;
      }

      children.add(
        VisitingCardTransformOverlay(
          cardSize: size,
          left: size.width * t.left,
          top: size.height * t.top,
          boxWidth: box,
          boxHeight: box,
          rotation: t.rotation,
          selected: vm.selectedOverlay == field,
          onSelect: () => vm.selectOverlay(field),
          onDeselect: vm.clearOverlaySelection,
          onMove: (dx, dy) => vm.moveOverlay(field, dx, dy, size),
          onResize: (d) => vm.resizeOverlay(field, d, size),
          onRotate: (r) => vm.rotateOverlay(field, r),
          child: image,
        ),
      );
    }

    addName(side.name, vm.displayName);
    addText(side.designation, vm.displayDesignation);

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

    final phones =
        vm.phones.where((e) => e.value.trim().isNotEmpty).toList();
    final emails =
        vm.emails.where((e) => e.value.trim().isNotEmpty).toList();
    final websites =
        vm.websites.where((e) => e.value.trim().isNotEmpty).toList();

    addText(side.phone, phones.isEmpty ? '' : phones.first.value);
    addText(side.email, emails.isEmpty ? '' : emails.first.value);
    addText(side.website, websites.isEmpty ? '' : websites.first.value);
    addText(side.address, vm.displayAddress);

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

class _PositionedField extends StatelessWidget {
  const _PositionedField({
    required this.cardSize,
    required this.position,
    required this.child,
  });

  final Size cardSize;
  final VisitingCardFieldPosition position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final square = position.size != null
        ? cardSize.width * position.size!
        : null;

    return Positioned(
      left: position.left != null ? cardSize.width * position.left! : null,
      top: position.top != null ? cardSize.height * position.top! : null,
      right: position.right != null ? cardSize.width * position.right! : null,
      bottom:
          position.bottom != null ? cardSize.height * position.bottom! : null,
      width: square ??
          (position.width != null ? cardSize.width * position.width! : null),
      height: square ??
          (position.height != null
              ? cardSize.height * position.height!
              : null),
      child: child,
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
