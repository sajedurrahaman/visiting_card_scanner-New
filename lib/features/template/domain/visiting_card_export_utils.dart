import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Render the card at this long edge. A second upscale past the capture
/// only softens the picture and inflates the PNG.
const int kVisitingCardExportMaxEdgePx = 2048;
const double kMaxVisitingCardRasterPixelRatio = 8.0;

/// Horizontal ≈ 3.5∶2, vertical ≈ inverse of app aspect 0.63.
Size visitingCardTargetExportSize({required bool isHorizontal}) {
  final maxEdge = kVisitingCardExportMaxEdgePx.toDouble();
  if (isHorizontal) {
    // 3.5 / 2 = 1.75 (matches preview aspect)
    return Size(maxEdge, (maxEdge / 1.75).roundToDouble());
  }
  // preview aspect ≈ 0.63 → width/height
  return Size((maxEdge * 0.63).roundToDouble(), maxEdge);
}

double visitingCardCapturePixelRatio(
  RenderRepaintBoundary boundary, {
  required Size targetExportSize,
}) {
  final size = boundary.size;
  if (size.width <= 0 || size.height <= 0) {
    return kMaxVisitingCardRasterPixelRatio;
  }
  final scaleW = targetExportSize.width / size.width;
  final scaleH = targetExportSize.height / size.height;
  return min(min(scaleW, scaleH), kMaxVisitingCardRasterPixelRatio);
}

/// Drops the trailing right and bottom pixels. Capture anti-aliasing leaves
/// a hairline of the white page on those two edges.
Future<ui.Image> _trimTrailingEdge(ui.Image src, int inset) async {
  if (inset <= 0 || src.width <= inset || src.height <= inset) return src;
  final width = src.width - inset;
  final height = src.height - inset;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    src,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..isAntiAlias = false,
  );
  final picture = recorder.endRecording();
  try {
    final trimmed = await picture.toImage(width, height);
    src.dispose();
    return trimmed;
  } finally {
    picture.dispose();
  }
}

/// Wait until the preview has painted the requested side (after [setSide]).
Future<void> waitForVisitingCardCaptureFrame() async {
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(const Duration(milliseconds: 32));
  await WidgetsBinding.instance.endOfFrame;
}

/// High-quality PNG capture (Photo Collage Maker style).
Future<Uint8List> captureVisitingCardPngBytes(
  GlobalKey repaintKey, {
  required bool isHorizontal,
}) async {
  final context = repaintKey.currentContext;
  if (context == null) {
    throw StateError('Card capture key has no context');
  }
  final boundary = context.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Card capture boundary not found');
  }

  final target = visitingCardTargetExportSize(isHorizontal: isHorizontal);
  final pixelRatio = visitingCardCapturePixelRatio(
    boundary,
    targetExportSize: target,
  );

  var image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    image = await _trimTrailingEdge(image, 2);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('PNG encode returned null');
    }
    return byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
  } finally {
    image.dispose();
  }
}
