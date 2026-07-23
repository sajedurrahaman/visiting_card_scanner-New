import 'package:flutter/material.dart';

class VisitingCardScanBoxOverlay extends StatelessWidget {
  const VisitingCardScanBoxOverlay({
    super.key,
    required this.onScreenSizeUpdated,
    required this.getScanningBoxRect,
    required this.capturedImageCount,
    required this.isBothSides,
  });

  final ValueChanged<Size> onScreenSizeUpdated;
  final Rect Function(Size screenSize) getScanningBoxRect;
  final int capturedImageCount;
  final bool isBothSides;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onScreenSizeUpdated(screenSize);
        });

        final scanBox = getScanningBoxRect(screenSize);
        final sideText = !isBothSides
            ? 'Front'
            : (capturedImageCount == 0 ? 'Front' : 'Back');

        return Stack(
          children: [
            CustomPaint(
              painter: _ScanningBoxPainter(scanBox),
              size: screenSize,
            ),
            Positioned(
              left: scanBox.left,
              top: scanBox.top,
              width: scanBox.width,
              height: scanBox.height,
              child: Center(
                child: Text(
                  sideText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanningBoxPainter extends CustomPainter {
  _ScanningBoxPainter(this.scanBox);

  final Rect scanBox;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanBox.top), overlayPaint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        scanBox.bottom,
        size.width,
        size.height - scanBox.bottom,
      ),
      overlayPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, scanBox.top, scanBox.left, scanBox.height),
      overlayPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        scanBox.right,
        scanBox.top,
        size.width - scanBox.right,
        scanBox.height,
      ),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(scanBox, borderPaint);

    final guidePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    void corner(Offset a, Offset b) => canvas.drawLine(a, b, guidePaint);

    corner(Offset(scanBox.left, scanBox.top),
        Offset(scanBox.left + cornerLength, scanBox.top));
    corner(Offset(scanBox.left, scanBox.top),
        Offset(scanBox.left, scanBox.top + cornerLength));
    corner(Offset(scanBox.right, scanBox.top),
        Offset(scanBox.right - cornerLength, scanBox.top));
    corner(Offset(scanBox.right, scanBox.top),
        Offset(scanBox.right, scanBox.top + cornerLength));
    corner(Offset(scanBox.left, scanBox.bottom),
        Offset(scanBox.left + cornerLength, scanBox.bottom));
    corner(Offset(scanBox.left, scanBox.bottom),
        Offset(scanBox.left, scanBox.bottom - cornerLength));
    corner(Offset(scanBox.right, scanBox.bottom),
        Offset(scanBox.right - cornerLength, scanBox.bottom));
    corner(Offset(scanBox.right, scanBox.bottom),
        Offset(scanBox.right, scanBox.bottom - cornerLength));
  }

  @override
  bool shouldRepaint(covariant _ScanningBoxPainter oldDelegate) =>
      oldDelegate.scanBox != scanBox;
}
