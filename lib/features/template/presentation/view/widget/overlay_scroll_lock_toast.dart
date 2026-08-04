import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// When [locked] (an overlay field is selected), page scroll is blocked.
/// A drag attempt then shows [message] (debounced), unless an overlay
/// move/resize gesture is active.
class OverlayScrollLockToast extends StatefulWidget {
  const OverlayScrollLockToast({
    super.key,
    required this.locked,
    required this.isOverlayGestureActive,
    required this.child,
    this.message = 'Deselect the item first',
  });

  final bool locked;
  final bool Function() isOverlayGestureActive;
  final Widget child;
  final String message;

  @override
  State<OverlayScrollLockToast> createState() => _OverlayScrollLockToastState();
}

class _OverlayScrollLockToastState extends State<OverlayScrollLockToast> {
  DateTime? _lastToastAt;
  Timer? _pendingToast;

  @override
  void dispose() {
    _pendingToast?.cancel();
    super.dispose();
  }

  void _scheduleToastCheck() {
    if (!widget.locked) return;
    _pendingToast?.cancel();
    // Wait briefly so overlay onPanStart can mark gesture active first.
    _pendingToast = Timer(const Duration(milliseconds: 50), () {
      if (!mounted || !widget.locked) return;
      if (widget.isOverlayGestureActive()) return;
      final now = DateTime.now();
      if (_lastToastAt != null &&
          now.difference(_lastToastAt!) < const Duration(seconds: 2)) {
        return;
      }
      _lastToastAt = now;
      ui.AppToast.show(context, message: widget.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (event.delta.dy.abs() > 2 || event.delta.dx.abs() > 2) {
          _scheduleToastCheck();
        }
      },
      child: widget.child,
    );
  }
}
