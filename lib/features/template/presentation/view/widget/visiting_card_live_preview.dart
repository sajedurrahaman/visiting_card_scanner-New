import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/domain/visiting_card_position_config.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardLivePreview extends StatelessWidget {
  const VisitingCardLivePreview({
    super.key,
    required this.vm,
    this.showPager = true,
    this.pagerOnly = false,
    this.sideOverride,
    this.onShowFront,
    this.onShowBack,
  });

  final VisitingCardEditContactViewModel vm;
  final bool showPager;
  final bool pagerOnly;

  /// When set, render this side instead of [vm.sideIndex] (0 = front, 1 = back).
  final int? sideOverride;
  final VoidCallback? onShowFront;
  final VoidCallback? onShowBack;

  int get _sideIndex => sideOverride ?? vm.sideIndex;
  bool get _isFront => _sideIndex == 0;

  @override
  Widget build(BuildContext context) {
    if (pagerOnly) {
      return VisitingCardSidePager(
        currentPage: _sideIndex + 1,
        canGoPrevious: !_isFront,
        canGoNext: _isFront,
        onPrevious: onShowFront ?? vm.showFront,
        onNext: onShowBack ?? vm.showBack,
      );
    }

    final aspectRatio = vm.isHorizontal ? 1.75 : 0.63;
    final layout = VisitingCardPositionConfig.forTemplate(
      templateId: vm.templateId,
      isHorizontal: vm.isHorizontal,
    );
    final side = _isFront ? layout.front : layout.back;
    final backgroundAsset =
        _isFront ? vm.frontAssetWithoutData : vm.backAssetWithoutData;

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
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
                      ..._buildOverlayChildren(
                        size: size,
                        side: side,
                        fontFamily: layout.fontFamily,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (showPager) ...[
          SizedBox(height: 8.h),
          VisitingCardSidePager(
            currentPage: _sideIndex + 1,
            canGoPrevious: !_isFront,
            canGoNext: _isFront,
            onPrevious: onShowFront ?? vm.showFront,
            onNext: onShowBack ?? vm.showBack,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildOverlayChildren({
    required Size size,
    required VisitingCardSidePositions side,
    required String fontFamily,
  }) {
    final children = <Widget>[];

    TextStyle styleFor(VisitingCardFieldPosition pos) {
      final sizeSp = pos.fontSize.sp;
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

    void addName(VisitingCardFieldPosition? pos, String value) {
      if (pos == null || value.trim().isEmpty) return;
      final display = pos.uppercase ? value.toUpperCase() : value;
      final baseStyle = styleFor(pos);

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

    void addImage(VisitingCardFieldPosition? pos, String? assetPath) {
      if (pos == null || assetPath == null || assetPath.isEmpty) return;
      final isAsset = assetPath.startsWith('assets/');
      children.add(
        _PositionedField(
          cardSize: size,
          position: pos,
          child: isAsset
              ? Image.asset(assetPath, fit: BoxFit.contain)
              : Image.file(File(assetPath), fit: BoxFit.contain),
        ),
      );
    }

    addName(side.name, vm.displayName);
    addText(side.designation, vm.displayDesignation);
    addText(side.company, vm.displayCompany);
    addText(side.tagline, vm.displayTagline);

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
      addImage(side.logo, vm.logoAssetPath);
    }
    if (vm.hasChosenQr) {
      addImage(side.qr, vm.qrAssetPath);
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
