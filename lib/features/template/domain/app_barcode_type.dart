import 'package:barcode_widget/barcode_widget.dart';

enum AppBarcodeType {
  general,
  pdf417,
  ean8,
  ean13,
  upcA,
  upcE,
  code39,
  code93,
  codabar,
  isbn,
  code128,
  dataMatrix,
  itf,
  itf14,
  msi,
}

extension AppBarcodeTypeX on AppBarcodeType {
  static AppBarcodeType fromLabel(String label) {
    switch (label) {
      case 'PDF417':
        return AppBarcodeType.pdf417;
      case 'EAN-8':
        return AppBarcodeType.ean8;
      case 'EAN-13':
        return AppBarcodeType.ean13;
      case 'UPC-A':
        return AppBarcodeType.upcA;
      case 'UPC-E':
        return AppBarcodeType.upcE;
      case 'Code 39':
        return AppBarcodeType.code39;
      case 'Code 93':
        return AppBarcodeType.code93;
      case 'Codabar':
        return AppBarcodeType.codabar;
      case 'ISBN':
        return AppBarcodeType.isbn;
      case 'Code 128':
        return AppBarcodeType.code128;
      case 'Data Matrix':
        return AppBarcodeType.dataMatrix;
      case 'ITF':
        return AppBarcodeType.itf;
      case 'ITF-14':
        return AppBarcodeType.itf14;
      case 'MSI':
        return AppBarcodeType.msi;
      default:
        return AppBarcodeType.general;
    }
  }

  Barcode toBarcode() {
    switch (this) {
      case AppBarcodeType.pdf417:
        return Barcode.pdf417();
      case AppBarcodeType.ean8:
        return Barcode.ean8();
      case AppBarcodeType.ean13:
        return Barcode.ean13();
      case AppBarcodeType.upcA:
        return Barcode.upcA();
      case AppBarcodeType.upcE:
        return Barcode.upcE(fallback: true);
      case AppBarcodeType.code39:
        return Barcode.code39();
      case AppBarcodeType.code93:
        return Barcode.code93();
      case AppBarcodeType.codabar:
        return Barcode.codabar();
      case AppBarcodeType.isbn:
        return Barcode.isbn(drawEndChar: false, drawIsbn: false);
      case AppBarcodeType.dataMatrix:
        return Barcode.dataMatrix();
      case AppBarcodeType.itf:
        return Barcode.itf();
      case AppBarcodeType.itf14:
        return Barcode.itf14();
      case AppBarcodeType.msi:
      case AppBarcodeType.code128:
      case AppBarcodeType.general:
        return Barcode.code128();
    }
  }
}
