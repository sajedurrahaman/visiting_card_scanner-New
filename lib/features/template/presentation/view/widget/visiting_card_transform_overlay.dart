import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// Collage-style interactive wrapper: drag, green selection border,
/// BR resize handle. Landscape adds padded frame + corner/edge handles.
class VisitingCardTransformOverlay extends StatefulWidget {
  const VisitingCardTransformOverlay({
    super.key,
    required this.cardSize,
    required this.left,
    required this.top,
    required this.boxWidth,
    required this.boxHeight,
    required this.rotation,
    required this.selected,
    required this.child,
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
    this.tightBorder = false,
    this.borderOnlyWhenSelected = false,
    this.showHandles = true,
  });

  final Size cardSize;
  final double left;
  final double top;
  final double boxWidth;
  final double boxHeight;
  final double rotation;
  final bool selected;
  final Widget child;
  final VoidCallback onSelect;
  final VoidCallback onDeselect;
  final void Function(double dx, double dy) onMove;
  final void Function(double delta) onResize;
  final void Function(double absoluteRadians) onRotate;

  /// Landscape: corner drag — proportional size change.
  /// [fixRight]/[fixBottom] keep the opposite corner anchored.
  final void Function(
    double pixelDelta, {
    required bool fixRight,
    required bool fixBottom,
  })? onUniformScale;

  /// Landscape: left/right center handles.
  /// [fixOpposite] true = keep right edge fixed (left handle).
  final void Function(
    double pixelDelta, {
    required bool fixOpposite,
  })? onStretchHorizontal;

  /// Landscape: top/bottom center handles.
  /// [fixOpposite] true = keep bottom edge fixed (top handle).
  final void Function(
    double pixelDelta, {
    required bool fixOpposite,
  })? onStretchVertical;

  final VoidCallback? onGestureStart;
  final VoidCallback? onGestureEnd;

  /// Text overlays: no extra inset around the green border.
  final bool tightBorder;

  /// When true (landscape editor), hide border until the field is selected,
  /// use 10px pad + corner/center 8pt handles.
  final bool borderOnlyWhenSelected;

  /// Landscape selection chrome. False hides the eight resize dots.
  final bool showHandles;

  @override
  State<VisitingCardTransformOverlay> createState() =>
      _VisitingCardTransformOverlayState();
}

class _VisitingCardTransformOverlayState
    extends State<VisitingCardTransformOverlay> {
  Offset? _lastGlobal;
  final GlobalKey _boxKey = GlobalKey();

  static const _handle = 16.0;
  static const _landscapeHandle = 14.0;
  static const _landscapePad = 10.0;
  static const _landscapeBorderWidth = 1.5;
  static const _borderColor = ui.Colors.parentIconSelectTextColor;

  bool get _landscapeChrome => widget.borderOnlyWhenSelected;

  @override
  Widget build(BuildContext context) {
    if (_landscapeChrome && widget.selected) {
      return _buildLandscapeSelected();
    }
    if (_landscapeChrome && !widget.selected) {
      return _buildLandscapeUnselected();
    }
    return _buildDefault();
  }

  /// Unselected landscape field: tap to select only — never pan/move.
  Widget _buildLandscapeUnselected() {
    return Positioned(
      left: widget.left,
      top: widget.top,
      width: widget.boxWidth,
      height: widget.boxHeight,
      child: Transform.rotate(
        alignment: Alignment.topLeft,
        angle: widget.rotation,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onSelect,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildDefault() {
    final handle = _handle.w;
    final hitPadX = handle / 2;
    final hitPadBottom = handle / 2;

    return Positioned(
      left: widget.left - hitPadX,
      top: widget.top,
      width: widget.boxWidth + hitPadX * 2,
      height: widget.boxHeight + hitPadBottom,
      child: Transform.rotate(
        angle: widget.rotation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: hitPadX,
              top: 0,
              width: widget.boxWidth,
              height: widget.boxHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.selected) {
                    widget.onDeselect();
                  } else {
                    widget.onSelect();
                  }
                },
                onPanStart: (d) {
                  if (!widget.selected) widget.onSelect();
                  widget.onGestureStart?.call();
                  _lastGlobal = d.globalPosition;
                },
                onPanUpdate: (d) {
                  final last = _lastGlobal;
                  if (last == null) return;
                  final delta = d.globalPosition - last;
                  _lastGlobal = d.globalPosition;
                  widget.onMove(delta.dx, delta.dy);
                },
                onPanEnd: (_) {
                  _lastGlobal = null;
                  widget.onGestureEnd?.call();
                },
                onPanCancel: () {
                  _lastGlobal = null;
                  widget.onGestureEnd?.call();
                },
                child: Container(
                  key: _boxKey,
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(
                      color: _borderColor,
                      width: widget.selected
                          ? (widget.tightBorder ? 1.2 : 2.0)
                          : (widget.tightBorder ? 0.3 : 1.2),
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
            if (widget.selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => widget.onGestureStart?.call(),
                  onPanUpdate: (d) => widget.onResize(d.delta.dy),
                  onPanEnd: (_) => widget.onGestureEnd?.call(),
                  onPanCancel: () => widget.onGestureEnd?.call(),
                  child: _HandleButton(
                    size: handle,
                    icon: Icons.unfold_more_rounded,
                    iconAngleDegrees: 145,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeSelected() {
    const pad = _landscapePad;
    const handle = _landscapeHandle;
    final showHandles = widget.showHandles;
    final outer = showHandles ? handle : 0.0;
    final frameW = widget.boxWidth + pad * 2;
    final frameH = widget.boxHeight + pad * 2;

    return Positioned(
      left: widget.left - pad - outer / 2,
      top: widget.top - pad - outer / 2,
      width: frameW + outer,
      height: frameH + outer,
      child: Transform.rotate(
        alignment: _topLeftOfContent(
          outerWidth: frameW + outer,
          outerHeight: frameH + outer,
          originX: outer / 2 + pad,
          originY: outer / 2 + pad,
        ),
        angle: widget.rotation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: outer / 2,
              top: outer / 2,
              width: frameW,
              height: frameH,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDeselect,
                onPanStart: showHandles
                    ? (d) {
                        widget.onGestureStart?.call();
                        _lastGlobal = d.globalPosition;
                      }
                    : null,
                onPanUpdate: showHandles
                    ? (d) {
                        final last = _lastGlobal;
                        if (last == null) return;
                        final delta = d.globalPosition - last;
                        _lastGlobal = d.globalPosition;
                        widget.onMove(delta.dx, delta.dy);
                      }
                    : null,
                onPanEnd: showHandles
                    ? (_) {
                        _lastGlobal = null;
                        widget.onGestureEnd?.call();
                      }
                    : null,
                onPanCancel: showHandles
                    ? () {
                        _lastGlobal = null;
                        widget.onGestureEnd?.call();
                      }
                    : null,
                child: DecoratedBox(
                  key: _boxKey,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _borderColor,
                      width: _landscapeBorderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(pad),
                    child: SizedBox(
                      width: widget.boxWidth,
                      height: widget.boxHeight,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
            if (showHandles) ...[
              _cornerHandle(left: 0, top: 0, signX: -1, signY: -1),
              _cornerHandle(left: frameW, top: 0, signX: 1, signY: -1),
              _cornerHandle(left: 0, top: frameH, signX: -1, signY: 1),
              _cornerHandle(left: frameW, top: frameH, signX: 1, signY: 1),
              _edgeHandle(
                left: frameW / 2,
                top: 0,
                horizontal: false,
                sign: -1,
              ),
              _edgeHandle(
                left: frameW / 2,
                top: frameH,
                horizontal: false,
                sign: 1,
              ),
              _edgeHandle(
                left: 0,
                top: frameH / 2,
                horizontal: true,
                sign: -1,
              ),
              _edgeHandle(
                left: frameW,
                top: frameH / 2,
                horizontal: true,
                sign: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Rotation pivot is the field's top-left, not the handle frame's corner.
  Alignment _topLeftOfContent({
    required double outerWidth,
    required double outerHeight,
    required double originX,
    required double originY,
  }) {
    if (outerWidth <= 0 || outerHeight <= 0) return Alignment.topLeft;
    return Alignment(
      (originX / outerWidth) * 2 - 1,
      (originY / outerHeight) * 2 - 1,
    );
  }

  Widget _cornerHandle({
    required double left,
    required double top,
    required double signX,
    required double signY,
  }) {
    const handle = _landscapeHandle;
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => widget.onGestureStart?.call(),
        onPanUpdate: (d) {
          final delta = (d.delta.dx * signX + d.delta.dy * signY) / 2;
          final scale = widget.onUniformScale;
          if (scale != null) {
            // Left-side handles keep right fixed; top-side keep bottom fixed.
            scale(
              delta,
              fixRight: signX < 0,
              fixBottom: signY < 0,
            );
          } else {
            widget.onResize(delta);
          }
        },
        onPanEnd: (_) => widget.onGestureEnd?.call(),
        onPanCancel: () => widget.onGestureEnd?.call(),
        child: const _HandleButton(
          size: handle,
          filled: true,
          color: _borderColor,
        ),
      ),
    );
  }

  Widget _edgeHandle({
    required double left,
    required double top,
    required bool horizontal,
    required double sign,
  }) {
    const handle = _landscapeHandle;
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => widget.onGestureStart?.call(),
        onPanUpdate: (d) {
          if (horizontal) {
            final delta = d.delta.dx * sign;
            final stretch = widget.onStretchHorizontal;
            if (stretch != null) {
              // Left handle (sign < 0): grow/shrink with right edge fixed.
              stretch(delta, fixOpposite: sign < 0);
            } else {
              widget.onResize(delta);
            }
          } else {
            final delta = d.delta.dy * sign;
            final stretch = widget.onStretchVertical;
            if (stretch != null) {
              // Top handle (sign < 0): grow/shrink with bottom edge fixed.
              stretch(delta, fixOpposite: sign < 0);
            } else {
              widget.onResize(delta);
            }
          }
        },
        onPanEnd: (_) => widget.onGestureEnd?.call(),
        onPanCancel: () => widget.onGestureEnd?.call(),
        child: const _HandleButton(
          size: handle,
          filled: true,
          color: _borderColor,
        ),
      ),
    );
  }
}

class _HandleButton extends StatelessWidget {
  const _HandleButton({
    required this.size,
    this.icon,
    this.iconAngleDegrees,
    this.filled = false,
    this.color = ui.Colors.parentIconSelectTextColor,
  });

  final double size;
  final IconData? icon;
  final double? iconAngleDegrees;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    if (icon != null) {
      iconWidget = Icon(
        icon,
        size: size * 0.55,
        color: color,
      );
      if (iconAngleDegrees != null) {
        iconWidget = Transform.rotate(
          angle: iconAngleDegrees! * math.pi / 180,
          child: iconWidget,
        );
      }
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: filled ? 0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: iconWidget,
    );
  }
}
