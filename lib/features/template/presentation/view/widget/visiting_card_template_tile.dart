import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class VisitingCardTemplateTile extends StatefulWidget {
  const VisitingCardTemplateTile({
    super.key,
    required this.item,
    required this.isHorizontal,
    required this.isSelected,
    required this.sideIndex,
    required this.onTap,
    required this.onShowFront,
    required this.onShowBack,
  });

  final VisitingCardTemplateItem item;
  final bool isHorizontal;
  final bool isSelected;
  final int sideIndex;
  final VoidCallback onTap;
  final VoidCallback onShowFront;
  final VoidCallback onShowBack;

  static const _totalSides = 2;

  @override
  State<VisitingCardTemplateTile> createState() =>
      _VisitingCardTemplateTileState();
}

class _VisitingCardTemplateTileState extends State<VisitingCardTemplateTile> {
  late final PageController _pageController;
  bool _ignorePageCallback = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.sideIndex);
  }

  @override
  void didUpdateWidget(covariant VisitingCardTemplateTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sideIndex != widget.sideIndex) {
      _jumpTo(widget.sideIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpTo(int page) {
    if (!_pageController.hasClients) return;
    final current =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (current == page) return;
    _ignorePageCallback = true;
    _pageController.jumpToPage(page);
    _ignorePageCallback = false;
  }

  void _onPageChanged(int page) {
    if (_ignorePageCallback) return;
    if (page == 0) {
      widget.onShowFront();
    } else {
      widget.onShowBack();
    }
  }

  Widget _sideImage(String asset) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 28.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.isHorizontal ? 1.75 : 0.63;
    final isFront = widget.sideIndex == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                _sideImage(widget.item.frontAsset),
                _sideImage(widget.item.backAsset),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 2.h,
              child: _TemplateSidePager(
                currentPage: widget.sideIndex + 1,
                totalPages: VisitingCardTemplateTile._totalSides,
                canGoPrevious: !isFront,
                canGoNext: isFront,
                onPrevious: widget.onShowFront,
                onNext: widget.onShowBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateSidePager extends StatelessWidget {
  const _TemplateSidePager({
    required this.currentPage,
    required this.totalPages,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PagerArrowButton(
          asset: canGoPrevious
              ? ui.AppAssets.activeLeftSideArrow
              : ui.AppAssets.inactiveLeftSideArrow,
          onTap: canGoPrevious ? onPrevious : null,
        ),
        SizedBox(width: 1.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
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
            '$currentPage/$totalPages',
            style: ui.AppTextStyles.iconUnderText(
              color: const Color(0xFF1A1A1A),
            ).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(width: 1.w),
        _PagerArrowButton(
          asset: canGoNext
              ? ui.AppAssets.activeRightSideArrow
              : ui.AppAssets.inactiveRightSideArrow,
          onTap: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

class _PagerArrowButton extends StatelessWidget {
  const _PagerArrowButton({
    required this.asset,
    required this.onTap,
  });

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SvgPicture.asset(
        asset,
        width: 28.w,
        height: 28.w,
      ),
    );
  }
}
