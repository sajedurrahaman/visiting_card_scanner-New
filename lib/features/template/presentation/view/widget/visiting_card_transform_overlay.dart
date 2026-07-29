import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// Collage-style interactive wrapper: drag, green selection border,
/// BR resize handle.
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
    this.tightBorder = false,
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

  /// Text overlays: no extra inset around the green border.
  final bool tightBorder;

  @override
  State<VisitingCardTransformOverlay> createState() =>
      _VisitingCardTransformOverlayState();
}

class _VisitingCardTransformOverlayState
    extends State<VisitingCardTransformOverlay> {
  Offset? _lastGlobal;
  final GlobalKey _boxKey = GlobalKey();

  static const _handle = 16.0;
  static const _borderColor = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    final handle = _handle.w;
    // Horizontal only — no vertical padding around the green border.
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
                  _lastGlobal = d.globalPosition;
                },
                onPanUpdate: (d) {
                  final last = _lastGlobal;
                  if (last == null) return;
                  final delta = d.globalPosition - last;
                  _lastGlobal = d.globalPosition;
                  widget.onMove(delta.dx, delta.dy);
                },
                onPanEnd: (_) => _lastGlobal = null,
                child: Container(
                  key: _boxKey,
                  // Border drawn on top — does not shrink child (no size jump).
                  foregroundDecoration: widget.selected
                      ? BoxDecoration(
                          border: Border.all(
                            color: _borderColor,
                            width: widget.tightBorder ? 1.0 : 1.5,
                          ),
                        )
                      : null,
                  child: widget.child,
                ),
              ),
            ),
            if (widget.selected) ...[
              // Bottom-right: resize
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) => widget.onResize(d.delta.dy),
                  child: _HandleButton(
                    size: handle,
                    icon: Icons.unfold_more_rounded,
                    iconAngleDegrees: 145,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HandleButton extends StatelessWidget {
  const _HandleButton({
    required this.size,
    required this.icon,
    this.iconAngleDegrees,
  });

  final double size;
  final IconData icon;
  final double? iconAngleDegrees;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: size * 0.55,
      color: ui.Colors.parentIconSelectTextColor,
    );
    if (iconAngleDegrees != null) {
      iconWidget = Transform.rotate(
        angle: iconAngleDegrees! * math.pi / 180,
        child: iconWidget,
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: ui.Colors.parentIconSelectTextColor,
          width: 1.2,
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
