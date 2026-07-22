import 'package:flutter/material.dart';
import 'package:visiting_card/features/template/domain/app_barcode_type.dart';

class RetailBarcodeGuards {
  static bool useDrawTextForBarHeights(AppBarcodeType type) {
    return type == AppBarcodeType.ean8 ||
        type == AppBarcodeType.ean13 ||
        type == AppBarcodeType.upcA ||
        type == AppBarcodeType.upcE ||
        type == AppBarcodeType.isbn;
  }

  static TextStyle invisibleEmbeddedDigitsStyle(double barCodeHeight) {
    return const TextStyle(
      color: Colors.transparent,
      fontSize: 14,
    );
  }
}
