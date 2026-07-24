import 'package:visiting_card/features/template/presentation/helper/qr_bar_code_helper.dart';

/// Thin mapping only — initial text / hints / validators match PDF Scanner
/// `qr_bar_code_input_page.dart` + `QrBarCodeHelper`.
class QrBarcodeInputHelper {
  QrBarcodeInputHelper._();

  static const maxLength = 300;

  /// Prefill text from PDF Scanner controllers.
  static String initialTextForQrType(String type) {
    switch (type) {
      case 'Website':
        return 'http://';
      case 'Facebook':
        return 'https://www.facebook.com/';
      case 'Instagram':
        return 'https://www.instagram.com/';
      case 'X':
        return 'https://x.com/';
      case 'Spotify':
        return 'https://www.spotify.com/';
      case 'Viber':
        return 'https://www.viber.com/';
      default:
        return '';
    }
  }

  /// Hint text from PDF Scanner input forms.
  static String hintForQrType(String type) {
    switch (type) {
      case 'Website':
        return 'http://';
      case 'Wi-Fi':
        return 'Enter Name';
      case 'Text':
        return 'Type or Paste text';
      case 'Contacts':
        return 'Enter Name';
      case 'SMS':
        return 'Enter Number';
      case 'Phone':
      case 'WhatsApp':
        return 'Enter Number';
      case 'Location':
        return 'Enter Latitude';
      case 'Facebook':
        return 'https://www.facebook.com/';
      case 'Instagram':
        return 'https://www.instagram.com/';
      case 'Email':
        return 'Enter email address';
      case 'Viber':
        return 'https://www.viber.com/';
      case 'X':
        return 'https://x.com/';
      case 'Spotify':
        return 'https://www.spotify.com/';
      case 'Product':
        return 'Enter Number';
      default:
        return 'Type or Paste text';
    }
  }

  static String? validateQrPrimary(String type, String? value) {
    final v = value?.toString() ?? '';
    switch (type) {
      case 'Website':
      case 'Spotify':
        return QrBarCodeHelper.validateWebsiteURL(v.trim());
      case 'Wi-Fi':
        return QrBarCodeHelper.validateWiFiName(v.trim());
      case 'Text':
        return QrBarCodeHelper.validateText(v, maxLength);
      case 'Contacts':
        return QrBarCodeHelper.validateName(v);
      case 'SMS':
      case 'Phone':
      case 'WhatsApp':
        return QrBarCodeHelper.validatePhoneNumber(v);
      case 'Location':
        return QrBarCodeHelper.validateLatitude(v);
      case 'Facebook':
        return QrBarCodeHelper.validateFacebookUrl(v);
      case 'Instagram':
        return QrBarCodeHelper.validateInstagramURL(v.trim());
      case 'Email':
        return QrBarCodeHelper.validateEmail(v);
      case 'Viber':
        return QrBarCodeHelper.validateViberURL(v.trim());
      case 'X':
        return QrBarCodeHelper.validateTwitterURL(v);
      case 'Product':
        return QrBarCodeHelper.validateProduct(v.trim(), maxLength);
      default:
        return QrBarCodeHelper.validateText(v, maxLength);
    }
  }

  static String? validateQrSecondary(String type, String? value) {
    final v = value?.toString() ?? '';
    switch (type) {
      case 'Wi-Fi':
        return QrBarCodeHelper.validateWiFiPassword(v);
      case 'SMS':
        return QrBarCodeHelper.validateText(v, maxLength);
      case 'Location':
        return QrBarCodeHelper.validateLongitude(v);
      case 'Contacts':
        return QrBarCodeHelper.validatePhoneNumber(v);
      case 'WhatsApp':
        return QrBarCodeHelper.validateText(v, maxLength);
      default:
        return null;
    }
  }

  static String? validateQrTertiary(String type, String? value) {
    if (type == 'Contacts') {
      return QrBarCodeHelper.validateEmail(value);
    }
    return null;
  }

  static String hintForBarcodeType(String type) {
    switch (type) {
      case 'ISBN':
        return 'ISBN...';
      case 'ITF':
        return 'ITF...';
      case 'ITF-14':
        return 'ITF_14...';
      case 'MSI':
        return 'MSI...';
      case 'PDF417':
        return 'PDF_417...';
      case 'UPC-A':
        return 'UPC_A...';
      case 'UPC-E':
        return 'UPC_E...';
      case 'EAN-13':
        return 'Ean_13...';
      case 'EAN-8':
        return 'Ean_8...';
      case 'Data Matrix':
        return 'Data Matrix...';
      case 'Code 128':
        return 'Code128...';
      case 'Code 93':
        return 'Code_93';
      case 'Code 39':
        return 'Code39...';
      case 'Codabar':
        return 'Codabar...';
      case 'General Types':
      default:
        return 'General Types...';
    }
  }

  /// Same validators used in PDF Scanner barcode input forms.
  static String? validateBarcode(String type, String? value) {
    final v = (value ?? '').trim();
    switch (type) {
      case 'EAN-8':
        return QrBarCodeHelper.ean8BarCode(v);
      case 'EAN-13':
        return QrBarCodeHelper.ean13BarCode(v);
      case 'UPC-A':
        return QrBarCodeHelper.upcABarCode(v);
      case 'UPC-E':
        return QrBarCodeHelper.upcEBarCode(v);
      case 'Code 39':
        return QrBarCodeHelper.code39BarCode(v);
      case 'Code 93':
        return QrBarCodeHelper.code93BarCode(v);
      case 'Code 128':
        return QrBarCodeHelper.code128BarCode(v);
      case 'Codabar':
        return QrBarCodeHelper.codabarBarCode(v);
      case 'PDF417':
        return QrBarCodeHelper.pdf417BarCode(v);
      case 'ISBN':
        return QrBarCodeHelper.isbnBarCode(v);
      case 'Data Matrix':
        return QrBarCodeHelper.dataMatrixBarCode(v);
      case 'ITF':
        return QrBarCodeHelper.itfBarCode(v);
      case 'ITF-14':
        return QrBarCodeHelper.itf14BarCode(v);
      case 'MSI':
        return QrBarCodeHelper.msiBarCode(v);
      case 'General Types':
        // PDF Scanner generalTypesBarCodeInputForm uses code128BarCode.
        return QrBarCodeHelper.code128BarCode(v);
      default:
        return QrBarCodeHelper.code128BarCode(v);
    }
  }
}
