import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Same idea as Photo Collage Maker (`collage_export_utils.dart`):
/// capture at a high raster ratio, then GPU-upscale to a print-size export.
const int kVisitingCardExportMaxEdgePx = 4096;
const double kMaxVisitingCardRasterPixelRatio = 4.0;

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

Future<ui.Image> _gpuRescaleImage(
  ui.Image src,
  int targetW,
  int targetH,
) async {
  if (src.width == targetW && src.height == targetH) return src;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    src,
    Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
    Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble()),
    Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true,
  );
  final picture = recorder.endRecording();
  try {
    final scaled = await picture.toImage(targetW, targetH);
    src.dispose();
    return scaled;
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
    final targetW = target.width.round();
    final targetH = target.height.round();
    if (image.width != targetW || image.height != targetH) {
      image = await _gpuRescaleImage(image, targetW, targetH);
    }

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
