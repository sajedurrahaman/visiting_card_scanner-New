import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Port of PDF Scanner `Helper.validateUrl` (QRCode/widget/helper.dart).
class UrlHelper {
  static bool validateUrl(String value) {
    final urlRegExp = RegExp(
      r"^(?:(http(?:s)?|ftp(?:s)?|sftp?|smtp?|imap?|pop3?|telnet?|ssh?|ldap?|rtsp?|sip?|gopher?|ws(?:s)?)://)?"
      r"((?:[a-zA-Z0-9-]+\.)*)"
      r"([a-zA-Z0-9-]+)\."
      r"([a-zA-Z]{2,})"
      r"(:\d{1,5})?"
      r"(/[^?#]*)?"
      r"(\?[^#]*)?"
      r"(#[^\s]*)?$",
    );
    return urlRegExp.hasMatch(value);
  }
}

class QrBarCodeHelper {
  static bool blankSpaceValidation(String? value) {
    return value!.trim().isNotEmpty;
  }

  static bool hasOnlyAlphanumeric(String input) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(input);
  }

  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  // static websiteValidator(value){
  //   if(!Helper.validateWebsite(value)){
  //     return "Please Enter valid Website.(Ex: www.something.com)";
  //   }
  //   return null;
  // }

  //It ensures that the URL starts with http:// or https://.
  // It checks that the second-level domain does not contain only numbers.
  // It ensures that the top-level domain (TLD) and the second-level domain are not the same.
  // It prevents the user from inputting a second-level domain with only numbers (e.g., www.3457).
  // It disallows any blank spaces in the URL.
  // It ensures that the top-level domain (TLD) is not a single character.
  static validateWebsiteURL(String value) {
    if (value.isEmpty) {
      return 'Website URL is required';
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (!UrlHelper.validateUrl(value)) {
      return 'Invalid Website URL Ex-http://www.example.com';
    }
    return null;
  }

  static String? ean8BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Must be exactly 8 digits
    if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
      return 'Barcode must be exactly 8 digits';
    }

    final digits = value.trim().split('').map(int.parse).toList();
    final sum = digits
        .asMap()
        .entries
        .take(7) // first 7 digits
        .map((e) => e.key % 2 == 0 ? e.value * 3 : e.value)
        .reduce((a, b) => a + b);

    final checksum = (10 - (sum % 10)) % 10;

    if (digits[7] != checksum) {
      return 'Invalid EAN-8 checksum, should be $checksum';
    }

    return null; // valid
  }

  static String? ean13BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Must be exactly 13 digits
    if (!RegExp(r'^\d{13}$').hasMatch(value.trim())) {
      return 'Barcode must be exactly 13 digits';
    }

    // Check EAN-13 checksum
    final digits = value.trim().split('').map(int.parse).toList();

    final sum = digits
        .asMap()
        .entries
        .take(12) // first 12 digits
        .map((e) => e.key % 2 == 0
            ? e.value
            : e.value *
                3) // even index = odd position *1, odd index = even position *3
        .reduce((a, b) => a + b);

    final checksum = (10 - (sum % 10)) % 10;

    if (digits[12] != checksum) {
      return 'Invalid EAN-13 checksum, should be $checksum';
    }

    return null; // valid
  }

  static String? upcABarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Must be exactly 12 digits
    if (!RegExp(r'^\d{12}$').hasMatch(value.trim())) {
      return 'Barcode must be exactly 12 digits';
    }

    // Check UPC-A checksum
    final digits = value.trim().split('').map(int.parse).toList();

    final sum = digits
        .asMap()
        .entries
        .take(11) // first 11 digits
        .map((e) => e.key % 2 == 0
            ? e.value * 3
            : e.value) // odd index = even position *3, even index = odd position *1
        .reduce((a, b) => a + b);

    final checksum = (10 - (sum % 10)) % 10;

    if (digits[11] != checksum) {
      return 'Invalid UPC-A checksum, should be $checksum';
    }

    return null; // valid
  }

  static String? upcEBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    final trimmed = value.trim();

    // Must be exactly 8 digits
    if (!RegExp(r'^\d{8}$').hasMatch(trimmed)) {
      return 'Barcode must be exactly 8 digits';
    }

    // First digit must be 0 or 1
    if (trimmed[0] != '0' && trimmed[0] != '1') {
      return 'First digit must be 0 or 1';
    }

    // Validate check digit using UPC-E → UPC-A expansion
    final calculatedCheck = _calculateUpcECheckDigit(trimmed);
    if (int.parse(trimmed[7]) != calculatedCheck) {
      return 'Invalid UPC-E checksum, should be $calculatedCheck';
    }

    return null;
  }

  static int _calculateUpcECheckDigit(String upcE) {
    final n = upcE[0];
    final e1 = upcE[1];
    final e2 = upcE[2];
    final e3 = upcE[3];
    final e4 = upcE[4];
    final e5 = upcE[5];
    final e6 = int.parse(upcE[6]);

    String upcA11;
    if (e6 == 0) {
      upcA11 = '$n$e1${e2}00000$e3$e4$e5'; // ← 5 zeros
    } else if (e6 == 1) {
      upcA11 = '$n$e1${e2}10000$e3$e4$e5'; // ← 1 + 4 zeros
    } else if (e6 == 2) {
      upcA11 = '$n$e1${e2}20000$e3$e4$e5'; // ← 2 + 4 zeros
    } else if (e6 == 3) {
      upcA11 = '$n$e1$e2${e3}00000$e4$e5'; // ← 5 zeros
    } else if (e6 == 4) {
      upcA11 = '$n$e1$e2$e3${e4}00000$e5'; // ← 5 zeros
    } else {
      upcA11 = '$n$e1$e2$e3$e4${e5}0000$e6'; // ← 4 zeros
    }

    final digits = upcA11.split('').map(int.parse).toList();
    final sum = digits
        .asMap()
        .entries
        .map((e) => e.key % 2 == 0 ? e.value * 3 : e.value)
        .reduce((a, b) => a + b);

    return (10 - (sum % 10)) % 10;
  }

  static String? general_types_BarCode(String value) {
    if (value.isEmpty) {
      return 'Website URL is required';
    }

    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Cannot be only "."';
    }

    if (value.trim().length != 10) {
      return 'Enter exactly 10 characters';
    }

    return null;
  }

  static String? code39BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Allow only valid Code39 characters
    // Digits 0–9, letters A–Z, space, and symbols - . $ / + %
    if (!RegExp(r'^[0-9A-Z .\-\$/+%]+$').hasMatch(value.trim().toUpperCase())) {
      return 'Barcode contains invalid characters (allowed: A–Z, 0–9, space, - .  / + %)';
    }

    // Typical length validation (1–43 characters)
    final length = value.trim().length;
    if (length < 1 || length > 43) {
      return 'Barcode must be between 1 and 43 characters';
    }

    return null; // valid
  }

  static String? code93BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Allow printable ASCII characters (space through ~)
    if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(value.trim())) {
      return 'Barcode contains invalid characters (allowed: printable ASCII characters)';
    }

    // Typical length validation (1–80 characters)
    final length = value.trim().length;
    if (length < 1 || length > 80) {
      return 'Barcode must be between 1 and 80 characters';
    }

    return null; // valid
  }

  static String? code128BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Allow printable ASCII characters (space to ~)
    if (!RegExp(r'^[\x20-\x7E]+$').hasMatch(value.trim())) {
      return 'Barcode contains invalid characters (must be standard ASCII)';
    }

    // Practical length validation
    final length = value.trim().length;
    if (length < 1 || length > 80) {
      return 'Barcode must be between 1 and 80 characters';
    }

    return null; // valid
  }

  static String? codabarBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // Allow Codabar characters: digits 0-9, - $ : / . + and start/stop letters A-D
    final upperValue = value.trim().toUpperCase();
    if (!RegExp(r'^[0-9\-\$:/.+ABCD]+$').hasMatch(upperValue)) {
      return 'Barcode contains invalid characters (allowed: 0–9, -  : / . +, A-D)';
    }

    // Typical length validation (4–20 characters)
    final length = upperValue.length;
    if (length < 4 || length > 20) {
      return 'Barcode must be between 4 and 20 characters';
    }

    return null; // valid
  }

  static String? pdf417BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    // PDF417 supports most printable characters; check length (1–1850)
    final length = value.trim().length;
    if (length < 1 || length > 1850) {
      return 'Barcode length must be between 1 and 1850 characters';
    }

    return null; // valid
  }

  static String? isbnBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    final trimmed = value.trim().toUpperCase();

    // ISBN-10: 9 digits + 1 checksum (0-9 or X)
    if (trimmed.length == 10 && !RegExp(r'^\d{9}[\dX]$').hasMatch(trimmed)) {
      return 'Invalid ISBN-10 format';
    }

    // ISBN-13: 13 digits
    if (trimmed.length == 13 && !RegExp(r'^\d{13}$').hasMatch(trimmed)) {
      return 'Invalid ISBN-13 format';
    }

    // Invalid length
    if (trimmed.length != 10 && trimmed.length != 13) {
      return 'ISBN must be 10 or 13 characters';
    }

    return null; // valid
  }

  static String? dataMatrixBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    final length = value.trim().length;
    if (length < 10 || length > 2335) {
      return 'Barcode must be between 10 and 2335 characters';
    }

    return null;
  }

  static String? itfBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'Barcode cannot be only "."';
    }

    final trimmed = value.trim();

    // Must be digits only
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Barcode must contain digits only';
    }

    // Must have even number of digits and length between 4 and 44
    final length = trimmed.length;
    if (length < 4 || length > 44 || length % 2 != 0) {
      return 'Barcode length must be even and between 4 and 44 digits';
    }

    return null; // valid
  }

  static String? itf14BarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    final trimmed = value.trim();

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(trimmed)) {
      return 'Barcode cannot be only "."';
    }

    // Must be digits only
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Barcode must contain digits only';
    }

    // Must be exactly 14 digits
    if (trimmed.length != 14) {
      return 'Barcode must be exactly 14 digits';
    }

    return null; // valid
  }

  static String? msiBarCode(String value) {
    if (value.isEmpty) {
      return 'Barcode is required';
    }

    final trimmed = value.trim();

    // Prevent only dots
    if (RegExp(r'^[.]+$').hasMatch(trimmed)) {
      return 'Barcode cannot be only "."';
    }

    // Must be digits only
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Barcode must contain digits only';
    }

    // Practical length validation (6–14 digits)
    final length = trimmed.length;
    if (length < 6 || length > 14) {
      return 'Barcode length must be between 6 and 14 digits';
    }

    return null; // valid
  }

  static validateWebsiteURLForContact(String value) {
    if (value.isEmpty) {
      return null;
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (!UrlHelper.validateUrl(value)) {
      return 'Invalid Website URL Ex-http://www.example.com';
    }
    return null;
  }

  static validateWiFiName(value) {
    String lang = 'en';
    if (value.isEmpty) {
      return 'WiFi name is required';
    }
    // if (value.trim().isEmpty) {
    //   return 'cannot be blank spaces only';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (!RegExp(r'^[ -~]*$').hasMatch(value)) {
      return 'can only contain printable ASCII characters and spaces';
    }
    if (value.contains(RegExp(r'^[\p{L}\p{M}\p{S}\p{N}]+$'))) {
      return 'cannot contain emojis';
    }
    if (value.length < 3 || value.length > 25) {
      return 'WiFi name must be between 3 and 25 characters long';
    }
    // if (!RegExp(r'^[^. ]+(\.[^. ]+)*$').hasMatch(value)) {//    RegExp regex = RegExp(r'^[^. ]+(\.[^. ]+)*$');
    //   return 'should not contain blank spaces with single dots';
    // }
    return null;
  }

  static validateWiFiPassword(String? value) {
    String lang = 'en';
    if (value == null || value.isEmpty) {
      return 'WiFi password is required';
    }
    if (value.trim().isEmpty) {
      return 'cannot be blank spaces only';
    }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    // if (!RegExp(r'^[ -~]*$').hasMatch(value)) {
    //   return 'WiFi password can only contain printable ASCII characters and spaces';
    // }
    // if (value.contains(RegExp(r'^[\p{L}\p{M}\p{S}\p{N}]+$'))) {
    //   return 'WiFi password cannot contain emojis';
    // }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return 'cannot contain emoji';
    }
    // if (value.length < 5 || value.length > 25) {
    //   return 'WiFi password must be between 6 and 25 characters long';
    // }
    if (value.length < 5) {
      return 'must be more then 4 characters long';
    }
    return null;
  }

  static validateText(dynamic value, int maxLength) {
    String lang = 'en';
    log("=====>value text length:${value.length}");

    if (value.isEmpty) {
      return 'cannot be empty';
    }

    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }

    // ✅ KEEP this one (or improve this to more accurate emoji detection):
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    if (value.length > maxLength) {
      return 'can not be more than $maxLength characters ';
    }

    return null;
  }

  static validateTxt(dynamic value, int maxLength) {
    String lang = 'en';
    log("=====>value text length:${value.length}");

    if (value.isEmpty) {
      return 'cannot be empty';
    }

    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }

    if (_containsEmojiOrCurrency(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    if (value.length > maxLength) {
      return 'can not be more than $maxLength characters';
    }

    return null;
  }

  static bool _containsEmojiOrCurrency(String text) {
    for (final rune in text.runes) {
      // Emoji ranges
      if ((rune >= 0x1F600 && rune <= 0x1F64F) || // Emoticons
          (rune >= 0x1F300 && rune <= 0x1F5FF) || // Symbols & Pictographs
          (rune >= 0x1F680 && rune <= 0x1F6FF) || // Transport
          (rune >= 0x2600 && rune <= 0x26FF) || // Misc symbols
          (rune >= 0x2700 && rune <= 0x27BF) || // Dingbats
          (rune >= 0x2300 && rune <= 0x23FF) || // Technical symbols
          (rune >= 0x1F900 && rune <= 0x1F9FF) || // Supplemental
          (rune >= 0x1F170 && rune <= 0x1F251) || // Enclosed
          rune == 0x1F004 || // Mahjong Tile
          // Currency symbols
          rune == 0x0024 || // $
          rune == 0x00A3 || // £
          rune == 0x00A5 || // ¥
          rune == 0x20AC) // €
      {
        return true;
      }
    }
    return false;
  }

  static validateProduct(value, int maxLength) {
    String lang = 'en';
    log("=====>value text length:${value.length}");
    if (value.isEmpty) {
      return 'cannot be empty';
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.length > maxLength) {
      return 'can not be more than $maxLength characters ';
    } //can store values up to 7089 characters
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    return null;
  }

  static validateName(value) {
    // Check if the name is empty or contains only whitespace
    if (value.isEmpty) {
      return 'cannot be empty';
    }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value)) {
      return 'letters and spaces only ';
    }
    //
    // if (value.isEmpty) {
    //   return 'cannot be empty';
    // }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    // if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
    //   return 'cannot only .';
    // }
    // if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
    //   return 'cannot contain emoji';
    // }
    // // Check if the name contains emojis
    // if (_containsEmoji(value)) {
    //   return 'cannot contain emojis';
    // }
    // // if (!RegExp(r'^[^. ]+(\.[^. ]+)*$').hasMatch(value)) {//    RegExp regex = RegExp(r'^[^. ]+(\.[^. ]+)*$');
    // //   return 'blank spaces with single dots are not Excepted';
    // // }
    // if (value.length < 3 || value.length > 25) {
    //   return 'mini 3 and Max 25 characters long';
    // }

    return null;
  }

  static bool _containsEmoji(String text) {
    for (int i = 0; i < text.length; i++) {
      int codeUnit = text.codeUnitAt(i);
      if ((codeUnit >= 0x1F600 && codeUnit <= 0x1F64F) || // Emoticons
          (codeUnit >= 0x1F300 &&
              codeUnit <= 0x1F5FF) || // Miscellaneous Symbols and Pictographs
          (codeUnit >= 0x1F680 &&
              codeUnit <= 0x1F6FF) || // Transport and Map Symbols
          (codeUnit >= 0x2600 && codeUnit <= 0x26FF) || // Miscellaneous Symbols
          (codeUnit >= 0x2700 && codeUnit <= 0x27BF) || // Dingbats
          (codeUnit >= 0x2300 &&
              codeUnit <= 0x23FF) || // Miscellaneous Technical
          (codeUnit >= 0x1F900 &&
              codeUnit <= 0x1F9FF) || // Supplemental Symbols and Pictographs
          (codeUnit >= 0x1F170 && codeUnit <= 0x1F251) || // Enclosed Characters
          (codeUnit == 0x1F004)) {
        // Mahjong Tile
        return true;
      }
    }
    return false;
  }

  static validateCompanyName(value) {
    String lang = 'en';
    // Check if the company name is empty or contains only whitespace
    if (value.isEmpty) {
      return 'cannot be empty';
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    // Check if the name contains emojis
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    if (value.length < 3) {
      return 'more than 2 characters long';
    }

    // if (!RegExp(r'^[^. ]+(\.[^. ]+)*$').hasMatch(value)) {//    RegExp regex = RegExp(r'^[^. ]+(\.[^. ]+)*$');
    //   return 'blank spaces with single dots are not Excepted';
    // }

    // Check if the company name exceeds maximum length
    // if (value!.length > 50) {
    //   return 'Company name is too long (maximum 50 characters)';
    // }

    return null;
  }

  static validateJobName(value) {
    String lang = 'en';
    // Check if the job name is empty or contains only whitespace
    if (value.isEmpty) {
      return 'cannot be empty';
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    // Check if the name contains emojis
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    // if (!RegExp(r'^[^. ]+(\.[^. ]+)*$').hasMatch(value)) {//    RegExp regex = RegExp(r'^[^. ]+(\.[^. ]+)*$');
    //   return 'Blank spaces with single dots are not Excepted';
    // }

    if (value.length < 3 || value.length > 25) {
      return 'Min-3 and Max-25 characters long';
    }

    return null;
  }

  static validatePhoneNumber(value) {
    RegExp numberRegex = RegExp(
      r'^(\+?\d{1,3})?[-.\s]?(\(?\d{1,4}?\)?[-.\s]?)*\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}$',
    );

    if (value.isEmpty) {
      return 'Phone number is required';
    } else if (!numberRegex.hasMatch(value)) {
      return 'Phone number must contain only numbers';
    } else if (RegExp(r'^0+$').hasMatch(value)) {
      return 'Phone number cannot be composed only of zeros';
    } else if (value.length < 5 || value.length > 15) {
      return 'Phone number length min-5 and max-15';
    }
    return null;
  }

  static validateEmail(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    // Regular expression for email validation
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static validateAddress(value) {
    String lang = 'en';
    // Check if the address is empty or contains only whitespace
    if (value.isEmpty) {
      return null;
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    // Check if the name contains emojis
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }

    if (value.length < 3) {
      return 'More than 2 characters ';
    }
    return null;
  }

  static validateCityName(value) {
    String lang = 'en';
    if (value.isEmpty) {
      // return 'cannot be empty';
      return null;
    }
    if (value.trim() != value) {
      return 'cannot start or end with whitespace';
    }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    // Check if the name contains emojis
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    if (value.length < 2) {
      return 'More than 2 characters ';
    }

    return null;
  }

  static validateCountry(value) {
    String lang = 'en';
    if (value.isEmpty) {
      // return 'cannot be empty';
      return null;
    }
    // if (value.trim() != value) {
    //   return 'cannot start or end with whitespace';
    // }
    if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
      return 'cannot only .';
    }
    if (value.contains(RegExp(r'[^\x00-\x7F]'))) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    // Check if the name contains emojis
    if (_containsEmoji(value)) {
      return lang == 'en' ||
              lang == 'en_uk' ||
              lang == 'en_canada' ||
              lang == 'en_australia'
          ? 'cannot contain emojis'
          : null;
    }
    if (value.length < 2) {
      return 'More than 2 characters ';
    }

    return null;
  }
  // static bool _containsNonAlphabeticCharacters(String? text) {
  //   if (text == null) return false;
  //   // Regular expression to match non-alphabetic characters
  //   RegExp regex = RegExp(r'[^\p{L}\s]');
  //   return regex.hasMatch(text);
  // }

  static validateLatitude(value) {
    // Regular expression to validate latitude
    // RegExp latRegExp =
    // RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$');
    //
    // // Check if latitude matches the regex
    // if (!latRegExp.hasMatch(value)) {
    //   return "Invalid latitude format";
    // }
    try {
      if (value == null || value.isEmpty) {
        return 'Latitude is required';
      }
      // if (value.trim().isEmpty) {
      //   return 'cannot be blank spaces only';
      // }
      if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
        return 'cannot only .';
      }
      // Convert latitude to double
      double latitude = double.parse(value);
      // Validate latitude range
      if (latitude < -90 || latitude > 90) {
        return "Latitude must be between -90 and 90";
      }
      // No errors, return null
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static validateLongitude(value) {
    try {
      // Regular expression to validate longitude
      //   RegExp longRegExp =
      // /  RegExp(r'^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$');
      //
      //   // Check if longitude matches the regex
      //   if (!longRegExp.hasMatch(value)) {
      //     return "Invalid longitude format";
      //   }
      if (value == null || value.isEmpty) {
        return 'Longitude is required';
      }
      // if (value.trim().isEmpty) {
      //   return 'cannot be blank spaces only';
      // }
      if (RegExp(r'^[.]+$').hasMatch(value.trim())) {
        return 'cannot only .';
      }

      // Convert longitude to double
      double longitude = double.parse(value);

      // Validate longitude range
      if (longitude < -180 || longitude > 180) {
        return "Longitude must be between -180 and 180";
      }

      // No errors, return null
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static validateMessageInput(value) {
    // Define your regular expression for message validation
    RegExp regex = RegExp(r'^[a-zA-Z0-9\s.,!?()-]{1,200}$');
    // Check if the value matches the regex pattern
    if (!regex.hasMatch(value)) {
      // Return an error message if the value doesn't match the pattern
      return 'Please enter a valid message (1-200 characters, only letters, numbers, spaces, and punctuation allowed)';
    }
    return null;
  }

  static validateFacebookUrl(value) {
    // Regular expression to match a Facebook URL
    // RegExp facebookUrlRegExp = RegExp(
    //   r'^https?:\/\/(www\.)?facebook\.com\/(?:\w+\/)*(\d+|[a-zA-Z0-9.-_]+)$',
    // );

    if (value.isEmpty) {
      return 'Please enter a Facebook URL';
    } else if (!value.contains("facebook.com")) {
      return 'Please enter a valid Facebook URL';
    } else if (!UrlHelper.validateUrl(value)) {
      return 'Please enter a valid Facebook URL';
    }

    return null; // Return null if validation succeeds
  }

  static String? validateMessengerUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a Messenger URL';
    }

    final lower = trimmed.toLowerCase();
    final isMessengerHost = lower.contains('messenger.com') ||
        lower.contains('m.me/') ||
        lower.startsWith('m.me') ||
        lower.contains('facebook.com/messages');

    if (!isMessengerHost) {
      return 'Please enter a valid Messenger URL';
    }
    if (!UrlHelper.validateUrl(trimmed)) {
      return 'Please enter a valid Messenger URL';
    }

    return null;
  }
  // static validateInput(value) {
  //   // Regular expressions for Number, User name, and Email validation
  //   RegExp numberRegExp = RegExp(r'^[0-9]+$');
  //   RegExp userNameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
  //   RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  //
  //   // Check if input matches any of the patterns
  //   if (numberRegExp.hasMatch(value)) {
  //     return null; // No error, input is a number
  //   } else if (userNameRegExp.hasMatch(value)) {
  //     return null; // No error, input is a valid username
  //   } else if (emailRegExp.hasMatch(value)) {
  //     return null; // No error, input is a valid email
  //   } else {
  //     return 'Invalid input'; // Error message for invalid input
  //   }
  // }

  // static validateInstagramPassword(value) {
  //   // Regular expression to match Instagram password requirements
  //   RegExp regExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  //   if (value.isEmpty) {
  //     return 'Password is required';
  //   } else if (!regExp.hasMatch(value)) {
  //     return 'Password must contain at least 8 characters, including at least one uppercase letter, one lowercase letter, one number, and one special character';
  //   }
  //   return null;
  // }

  static validateViberURL(String value) {
    // Regular expression to match Viber URL format
    // RegExp regExp = RegExp(r'^viber:\/\/(add|chat|forward|pa|stickerstore|group)\??(\w*=\w*(&?)?)*$');

    if (value.isEmpty) {
      return 'Viber URL is required';
    } else if (!value.contains("viber.com")) {
      return 'Invalid Viber URL';
    } else if (!UrlHelper.validateUrl(value)) {
      return 'Invalid Viber URL';
    }

    return null;
  }

  static validateTwitterURL(String value) {
    if (value.isEmpty) {
      return 'X URL is required';
    } else if (value.contains("twitter.com") || value.contains("x.com")) {
      if (!UrlHelper.validateUrl(value)) {
        return 'Invalid X URL';
      } else {
        return null;
      }
    } else {
      return 'Invalid X URL';
    }
  }

  static validateLinkedInURL(String value) {
    if (value.isEmpty) {
      return 'LinkedIn URL is required';
    } else if (!value.contains("linkedin.com")) {
      return 'Invalid LinkedIn URL';
    } else if (!UrlHelper.validateUrl(value)) {
      return 'Invalid LinkedIn URL';
    }
    return null;
  }

  static validateInstagramURL(String value) {
    //https://www.instagram.com/explore/locations/212999109/mumbai-maharashtra/

    if (value.isEmpty) {
      return 'Instagram URL is required';
    } else if (!value.contains("instagram.com")) {
      return 'Invalid Instagram URL';
    } else if (!UrlHelper.validateUrl(value)) {
      return 'Invalid Instagram URL';
    }

    return null;
  }
}