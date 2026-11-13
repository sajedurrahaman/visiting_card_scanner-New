import 'package:flutter/material.dart';

/// Drag-to-select marquee rectangle while the finger is down.
class VisitingCardMarqueePaint extends StatelessWidget {
  const VisitingCardMarqueePaint({super.key, required this.rect});

  final Rect rect;

  static const _fill = Color(0x332A9DF4);
  static const _stroke = Color(0xFF2A9DF4);

  @override
  Widget build(BuildContext context) {
    if (rect.width < 1 && rect.height < 1) return const SizedBox.shrink();
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width.abs().clamp(1.0, double.infinity),
      height: rect.height.abs().clamp(1.0, double.infinity),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _fill,
            border: Border.all(color: _stroke, width: 1.2),
          ),
        ),
      ),
    );
  }
}

/// Full-card alignment grid shown while moving a multi-selection.
class VisitingCardMoveGrid extends StatelessWidget {
  const VisitingCardMoveGrid({super.key});

  static const _line = Color(0x662A9DF4);
  static const _center = Color(0x992A9DF4);

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = VisitingCardMoveGrid._line
      ..strokeWidth = 0.6;
    final major = Paint()
      ..color = VisitingCardMoveGrid._center
      ..strokeWidth = 1.0;

    const cols = 12;
    const rows = 8;
    for (var i = 0; i <= cols; i++) {
      final x = size.width * i / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (var i = 0; i <= rows; i++) {
      final y = size.height * i / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    // Center guides.
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      major,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      major,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Group bounding box around every multi-selected field. Drag body to move all.
class VisitingCardGroupSelectionBox extends StatefulWidget {
  const VisitingCardGroupSelectionBox({
    super.key,
    required this.bounds,
    required this.cardSize,
    required this.onMove,
    required this.onGestureStart,
    required this.onGestureEnd,
  });

  final Rect bounds;
  final Size cardSize;
  final void Function(double dx, double dy) onMove;
  final VoidCallback onGestureStart;
  final VoidCallback onGestureEnd;

  @override
  State<VisitingCardGroupSelectionBox> createState() =>
      _VisitingCardGroupSelectionBoxState();
}

class _VisitingCardGroupSelectionBoxState
    extends State<VisitingCardGroupSelectionBox> {
  Offset? _lastGlobal;

  static const _pad = 6.0;
  static const _handle = 12.0;
  static const _border = Color(0xFF2A9DF4);

  @override
  Widget build(BuildContext context) {
    final b = widget.bounds.inflate(_pad);
    if (b.width < 4 || b.height < 4) return const SizedBox.shrink();

    return Positioned(
      left: b.left - _handle / 2,
      top: b.top - _handle / 2,
      width: b.width + _handle,
      height: b.height + _handle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: _handle / 2,
            top: _handle / 2,
            width: b.width,
            height: b.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) {
                widget.onGestureStart();
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
                widget.onGestureEnd();
              },
              onPanCancel: () {
                _lastGlobal = null;
                widget.onGestureEnd();
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _border,
                    width: 1.5,
                  ),
                  color: const Color(0x152A9DF4),
                ),
              ),
            ),
          ),
          _dot(left: 0, top: 0),
          _dot(left: b.width, top: 0),
          _dot(left: 0, top: b.height),
          _dot(left: b.width, top: b.height),
          _dot(left: b.width / 2, top: 0),
          _dot(left: b.width / 2, top: b.height),
          _dot(left: 0, top: b.height / 2),
          _dot(left: b.width, top: b.height / 2),
        ],
      ),
    );
  }

  Widget _dot({required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: _handle,
          height: _handle,
          decoration: BoxDecoration(
            color: _border.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty-card gesture layer: tap clears, pan starts marquee select.
class VisitingCardMarqueeLayer extends StatelessWidget {
  const VisitingCardMarqueeLayer({
    super.key,
    required this.cardSize,
    required this.hitTargets,
    required this.onTapClear,
    required this.onMarqueeStart,
    required this.onMarqueeUpdate,
    required this.onMarqueeEnd,
  });

  final Size cardSize;
  final List<({String key, Rect rect})> hitTargets;
  final VoidCallback onTapClear;
  final void Function(Offset local) onMarqueeStart;
  final void Function(Offset local) onMarqueeUpdate;
  final VoidCallback onMarqueeEnd;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTapClear,
        onPanStart: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          onMarqueeStart(box.globalToLocal(d.globalPosition));
        },
        onPanUpdate: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          onMarqueeUpdate(box.globalToLocal(d.globalPosition));
        },
        onPanEnd: (_) => onMarqueeEnd(),
        onPanCancel: onMarqueeEnd,
      ),
    );
  }
}
