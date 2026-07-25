import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

enum ParentScanMode { visitingCard, qrCode, barcode }

/// PDF Scanner–style snap mode strip (scroll to change camera mode).
/// Selected label is theme green; fixed triangle sits under the center item.
class ParentScanModeStrip extends StatefulWidget {
  const ParentScanModeStrip({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ParentScanMode selected;
  final ValueChanged<ParentScanMode> onChanged;

  static const green = Color(0xFF05B560);

  static String labelFor(ParentScanMode mode) {
    switch (mode) {
      case ParentScanMode.visitingCard:
        return 'Visiting Card';
      case ParentScanMode.qrCode:
        return 'QR Code';
      case ParentScanMode.barcode:
        return 'Barcode';
    }
  }

  @override
  State<ParentScanModeStrip> createState() => _ParentScanModeStripState();
}

class _ParentScanModeStripState extends State<ParentScanModeStrip> {
  late final ScrollController _scrollController;
  double _itemWidth = 110;
  int _centeredIndex = 0;
  int _dragStartIndex = 0;
  bool _programmaticScroll = false;

  static const _modes = ParentScanMode.values;
  static const _minItemWidth = 90.0;
  static const _maxItemWidth = 160.0;
  static const _itemExtraPadding = 24.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _centeredIndex = _modes.indexOf(widget.selected).clamp(0, _modes.length - 1);
    _dragStartIndex = _centeredIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculateItemWidth();
  }

  @override
  void didUpdateWidget(covariant ParentScanModeStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      final next = _modes.indexOf(widget.selected).clamp(0, _modes.length - 1);
      if (next != _centeredIndex) {
        setState(() {
          _centeredIndex = next;
          _dragStartIndex = next;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToIndex(next, animate: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _recalculateItemWidth() {
    if (!mounted) return;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    const normalStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    const boldStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    double maxTextWidth = 0;
    for (final mode in _modes) {
      final label = ParentScanModeStrip.labelFor(mode);
      maxTextWidth = max(
        maxTextWidth,
        _measureTextWidth(label, normalStyle, textScale),
      );
      maxTextWidth = max(
        maxTextWidth,
        _measureTextWidth(label, boldStyle, textScale),
      );
    }

    final next =
        (maxTextWidth + _itemExtraPadding).clamp(_minItemWidth, _maxItemWidth);
    if ((next - _itemWidth).abs() < 0.5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _centeredIndex =
            _modes.indexOf(widget.selected).clamp(0, _modes.length - 1);
        _dragStartIndex = _centeredIndex;
        _scrollToIndex(_centeredIndex, animate: false);
      });
      return;
    }

    setState(() => _itemWidth = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centeredIndex =
          _modes.indexOf(widget.selected).clamp(0, _modes.length - 1);
      _dragStartIndex = _centeredIndex;
      _scrollToIndex(_centeredIndex, animate: false);
    });
  }

  double _measureTextWidth(String text, TextStyle style, double textScale) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(textScale),
      maxLines: 1,
    )..layout();
    return painter.size.width;
  }

  double get _centerPadding =>
      MediaQuery.sizeOf(context).width / 2 - _itemWidth / 2;

  int _indexAtCenter() {
    if (!_scrollController.hasClients) return 0;
    return (_scrollController.offset / _itemWidth)
        .round()
        .clamp(0, _modes.length - 1);
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final offset = index * _itemWidth;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final clamped = offset.clamp(0.0, maxExtent);

    _programmaticScroll = true;
    if (animate) {
      _scrollController
          .animateTo(
        clamped,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      )
          .then((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _programmaticScroll = false;
            _dragStartIndex = index;
          }
        });
      });
    } else {
      _scrollController.jumpTo(clamped);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _programmaticScroll = false;
        _dragStartIndex = index;
      });
    }
  }

  void _onScroll() {
    if (_programmaticScroll || !_scrollController.hasClients) return;
    final index = _indexAtCenter();
    if (index != _centeredIndex) {
      setState(() => _centeredIndex = index);
    }
  }

  void _snapAndSelect() {
    final rawIndex = _indexAtCenter();
    final index = rawIndex
        .clamp(_dragStartIndex - 1, _dragStartIndex + 1)
        .clamp(0, _modes.length - 1);
    _scrollToIndex(index);
    setState(() => _centeredIndex = index);
    final mode = _modes[index];
    if (mode != widget.selected) {
      widget.onChanged(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _dragStartIndex = _indexAtCenter();
              }
              if (notification is ScrollEndNotification &&
                  !_programmaticScroll) {
                _snapAndSelect();
              }
              return false;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              physics: _SnapToItemScrollPhysics(itemWidth: _itemWidth),
              padding: EdgeInsets.symmetric(horizontal: _centerPadding),
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = mode == widget.selected;
                final isCentered = index == _centeredIndex;
                final highlight = isSelected || isCentered;
                return GestureDetector(
                  onTap: () {
                    _scrollToIndex(index);
                    setState(() => _centeredIndex = index);
                    if (mode != widget.selected) {
                      widget.onChanged(mode);
                    }
                  },
                  child: SizedBox(
                    width: _itemWidth,
                    child: Center(
                      child: Text(
                        ParentScanModeStrip.labelFor(mode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ui.AppFonts.sfPro,
                          color: highlight
                              ? ParentScanModeStrip.green
                              : Colors.white,
                          fontSize: 14,
                          fontWeight:
                              highlight ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                ui.AppAssets.scanModeSelectorIcon,
                height: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapToItemScrollPhysics extends ScrollPhysics {
  const _SnapToItemScrollPhysics({
    required this.itemWidth,
    super.parent,
  });

  final double itemWidth;

  @override
  _SnapToItemScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapToItemScrollPhysics(
      itemWidth: itemWidth,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final currentIndex = (position.pixels / itemWidth).round();
    var targetIndex = currentIndex;
    if (velocity > tolerance.velocity) {
      targetIndex = currentIndex + 1;
    } else if (velocity < -tolerance.velocity) {
      targetIndex = currentIndex - 1;
    }
    final maxIndex = (position.maxScrollExtent / itemWidth).round();
    targetIndex = targetIndex.clamp(0, maxIndex);
    return targetIndex * itemWidth;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final target = _getTargetPixels(
      position,
      toleranceFor(position),
      velocity,
    ).clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: toleranceFor(position),
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
