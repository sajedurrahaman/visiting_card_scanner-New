import 'dart:developer';

import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// OCR contact parsing — ported from PDF Scanner
/// (`BusinessCardHelper.getContactDataFromText`). Do not change the logic.
class OcrContactParser {
  OcrContactParser._();

  // Name: Capitalized words, typically in the format "First Last"
  static RegExp nameRegEx = RegExp(r'\b[A-Z][a-zA-Z]+\s[A-Z][a-zA-Z]+\b');

  // Job Title: Usually lowercase or mixed case, words like "Manager", "Engineer", "Designer", etc.
  static RegExp jobTitleRegEx =
      RegExp(r'\b[A-Z][a-z]+\s[A-Z][a-z]+\b|\b[A-Z][a-z]+\b');

  // Phone Number: Supports various formats (e.g., +1 123-456-7890, (123) 456-7890)
  static RegExp phoneRegEx = RegExp(
      r'\+?\d{1,3}[-.\s]?\(?\d{1,4}?\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}');

  // Email: Standard email pattern
  static RegExp emailRegEx =
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b');

  // URL: Supports various URL formats
  static RegExp urlRegEx = RegExp(
      r'((https?|ftp):\/\/)?([A-Za-z0-9.-]+)\.[a-z]{2,}(\.[a-z]{2,})?(/[-A-Za-z0-9@:%_\+.~#?&//=]*)?');

  // Address: Common address formats
  static RegExp addressRegEx =
      RegExp(r'\d{1,4}\s[A-Za-z0-9\s,-]+,\s[A-Za-z\s]+,\s[A-Z]{2}\s\d{5}');

  // Company Name: Typically uppercase or title case, often at the beginning
  static RegExp companyNameRegEx = RegExp(r'\b[A-Z][A-Z\s&]+\b');

  static ScannedContactDraft parse(String text) {
    final nameList = <_ContactInfo>[];
    final designationList = <_ContactInfo>[];
    final telList = <_ContactInfo>[];
    final emailList = <_ContactInfo>[];
    final companyList = <_ContactInfo>[];
    final websiteList = <_ContactInfo>[];
    final addressList = <_ContactInfo>[];

    nameRegEx.allMatches(text);
    jobTitleRegEx.allMatches(text);
    final phoneMatches = phoneRegEx.allMatches(text);
    final emailMatches = emailRegEx.allMatches(text);
    final urlMatches = urlRegEx.allMatches(text);
    addressRegEx.allMatches(text);
    companyNameRegEx.allMatches(text);

    List<String> lines = text.split('\n');

    log('--- Extracted newline String list ---');
    for (final line in lines) {
      log(line);
    }

    log('--- Extracted Data ---');

    log('Designation:');
    final designation = _getDesignation(lines);
    log('designation===>$designation');
    if (designation.isNotEmpty) {
      designationList.clear();
      designationList.add(_ContactInfo(contactData: designation, type: ''));

      log('Names:');
      String? name;
      for (int i = 0; i < lines.length; i++) {
        log('${lines[i]}and$designation');
        if (designation == lines[i]) {
          log('lines[i]=${lines[i]}');
          name = i > 0 ? lines[i - 1] : lines[0];
          log('name>>=$name');
          break;
        } else {
          name = '';
        }
      }
      if (name != null && name.isNotEmpty) {
        log('name.isNotEmpty');
        log('name.isNotEmpty=>$name');
        if (nameRegEx.hasMatch(name)) {
          nameList.clear();
          nameList.add(_ContactInfo(contactData: name, type: ''));
        } else {
          name = '';
        }
      } else if (name == null || name.isEmpty) {
        nameList.clear();
      }
    }

    log('addressMatches:');
    final addressList0 = _extractAddresses(lines, text);
    for (final address in addressList0) {
      addressList.add(_ContactInfo(contactData: address, type: 'Work'));
    }

    log('Phone Numbers:');
    for (final match in phoneMatches) {
      log(match.group(0)!);
      telList.add(_ContactInfo(
        contactData: match.group(0)!,
        type: match.group(0)!.contains('+') ? 'Cell' : 'Tel',
      ));
    }

    log('Emails:');
    for (final match in emailMatches) {
      log(match.group(0)!);
      emailList.add(_ContactInfo(contactData: match.group(0)!, type: 'Company'));
    }

    log('URLs:');
    for (final match in urlMatches) {
      log(match.group(0)!);
      if (match.group(0)!.contains('gmail.com') ||
          match.group(0)!.contains('yahoo.com') ||
          match.group(0)!.contains('outlook.com') ||
          match.group(0)!.contains('hotmail.com') ||
          match.group(0)!.contains('icloud.com') ||
          match.group(0)!.contains('clippingworid.com') ||
          match.group(0)!.contains('aol.com')) {
      } else {
        log('===>check url');
        websiteList.add(
          _ContactInfo(contactData: match.group(0)!, type: 'Company'),
        );
        final company = _getCompanyName(match.group(0)!, lines);
        if (company.isNotEmpty) {
          companyList.clear();
          companyList
              .add(_ContactInfo(type: '', contactData: company.trim()));
        } else {
          companyList.clear();
        }
      }
    }

    /*--------------------------if company is empty----------------------*/
    if (companyList.isEmpty) {
      final randomCompanyList = _getCompanyNameFromRandomText(
        linesOfScannedText: lines,
        nameList: nameList,
        designationList: designationList,
        companyList: companyList,
        telList: telList,
        emailList: emailList,
        websiteList: websiteList,
        addressList: addressList,
      );
      int count = 0;
      for (final randomCompanyName in randomCompanyList) {
        if (count < 3) {
          if (!randomCompanyName.contains(',') ||
              !randomCompanyName.contains('/') ||
              !randomCompanyName.contains('-') ||
              !randomCompanyName.contains('@') ||
              !randomCompanyName.contains(':') ||
              !randomCompanyName.contains('#')) {
            companyList.add(_ContactInfo(
              type: '',
              contactData: randomCompanyName.trim(),
            ));
            count++;
          }
        }
      }
    }

    /*-----check predicted names and config first index as company name-------*/
    if (nameList.isEmpty) {
      log('===>namelist==> $nameList');
      final scannedLinesSet = lines.toSet();
      lines = scannedLinesSet.toList();
      final nameListFromScannedText = _getNameFromRandomText(
        linesOfScannedText: lines,
        nameList: nameList,
        designationList: designationList,
        companyList: companyList,
        telList: telList,
        emailList: emailList,
        websiteList: websiteList,
        addressList: addressList,
      );
      int count = 0;
      for (final randomCompanyName in nameListFromScannedText) {
        if (count < 3) {
          if (!randomCompanyName.contains(',') ||
              !randomCompanyName.contains('/') ||
              !randomCompanyName.contains('-') ||
              !randomCompanyName.contains('@') ||
              !randomCompanyName.contains(':') ||
              !randomCompanyName.contains('#')) {
            nameList.add(_ContactInfo(
              type: '',
              contactData: randomCompanyName,
            ));
            count++;
          }
        }
      }
      if (companyList.isNotEmpty) {
        try {
          if (nameList.contains(companyList[0])) {
            nameList.remove(companyList[0]);
          }
          nameList.insert(0, companyList[0]);
          nameList.removeLast();
        } catch (e) {
          log(e.toString());
        }
      }
    }

    return ScannedContactDraft(
      name: nameList.isNotEmpty ? (nameList.first.contactData ?? '') : '',
      designation: designationList.isNotEmpty
          ? (designationList.first.contactData ?? '')
          : '',
      company:
          companyList.isNotEmpty ? (companyList.first.contactData ?? '') : '',
      phones: telList.isEmpty
          ? ['']
          : telList.map((e) => e.contactData ?? '').toList(),
      emails: emailList.isEmpty
          ? ['']
          : emailList.map((e) => e.contactData ?? '').toList(),
      websites: websiteList.isEmpty
          ? ['']
          : websiteList.map((e) => e.contactData ?? '').toList(),
      addresses: addressList.isEmpty
          ? ['']
          : addressList.map((e) => e.contactData ?? '').toList(),
    );
  }

  static String _getCompanyName(String url, List<String> lines) {
    String company = '';
    String domainName = '';
    final companyNameList = <String>[];
    for (final line in lines) {
      log(line);
      company = line;
      final normalizedCompanyName =
          company.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      log('normalizedCompanyName: $normalizedCompanyName');
      final domain = _extractDomain(url);

      final isMatch = domain.contains(normalizedCompanyName);

      log('URL: $url');
      log('Company Name: $company');
      log('Domain: $domain');
      log('Is Match: $isMatch');
      domainName = domain;
      if (isMatch) {
        companyNameList.add(company);
      } else {
        company = '';
      }
    }
    company = '';
    final setWithUniqueValues = companyNameList.toSet();
    final uniqueCompanies = setWithUniqueValues.toList();
    for (final c in uniqueCompanies) {
      company = '$company $c';
    }
    final normalizedCompanyName =
        company.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (domainName != normalizedCompanyName) {
      company = _toCamelCase(domainName);
    }
    return company;
  }

  static String _extractDomain(String input) {
    final RegExp regex = RegExp(r'^(?:www\.)?([^\.]+)\.');
    final match = regex.firstMatch(input);
    if (match != null && match.groupCount > 0) {
      return match.group(1) ?? '';
    } else {
      return '';
    }
  }

  static String _toCamelCase(String input) {
    final words = input.split(RegExp(r'(?<!^)(?=[A-Z])'));
    final camelCaseString = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();
    return camelCaseString;
  }

  static String _getDesignation(List<String> lines) {
    String designation = '';
    for (final line in lines) {
      final RegExp designationRegex = RegExp(
        r'\b(CEO|CFO|CTO|CIO|COO|President|Owner|Vice President|Director|Manager|Supervisor|Coordinator|Consultant|Engineer|Developer|Technician|Specialist|Proprietor|Analyst|Administrator|Executive|Officer|Clerk|Accountant|Teacher|Professor|Nurse|Doctor|Surgeon|Lawyer|Judge|Attorney|Mechanic|Electrician|Designer|Artist|Photographer|Chef|Cook|Cashier|Salesperson|Architect|Scientist|Researcher|Pilot|Captain|Driver|Operator|Trainer|Instructor|Inspector|Auditor)\b',
        caseSensitive: false,
      );

      final Match? match = designationRegex.firstMatch(line);

      if (match != null) {
        log('Designation: ${match.group(0)}');
        designation = line;
        break;
      } else {
        log('Designation not found.');
        designation = '';
      }
    }
    return designation;
  }

  static List<String> _extractAddresses(List<String> lines, String input) {
    final foundAddresses = <String>[];

    for (int i = 0; i < lines.length; i++) {
      log(lines[i]);
      if ((lines[i].contains('#') && lines[i].contains(',')) ||
          (lines[i].contains(':') && lines[i].contains(',')) ||
          (lines[i].contains('-') && lines[i].contains(',')) ||
          (lines[i].contains('/') && lines[i].contains(',')) ||
          lines[i].contains('road') ||
          lines[i].contains('floor') ||
          lines[i].contains('Floor') ||
          lines[i].contains('Bloc') ||
          lines[i].contains('Block') ||
          lines[i].contains('Dhaka-') ||
          lines[i].contains('dhaka-') ||
          (lines[i].contains('Bangladesh') && lines[i].contains(',')) ||
          (lines[i].contains('United States') && lines[i].contains(',')) ||
          lines[i].contains('House') ||
          (lines[i].contains('H') && lines[i].contains(',')) ||
          lines[i].contains('Street') ||
          lines[i].contains('street')) {
        bool isAddress = true;
        final phoneMatches = phoneRegEx.allMatches(lines[i]);
        log('Phone check in address from ${lines[i]}');
        for (final match in phoneMatches) {
          log(match.group(0)!);
          if (match.group(0)!.isNotEmpty) {
            isAddress = false;
          }
        }
        final emailMatches = emailRegEx.allMatches(lines[i]);
        log('Phone check in email from ${lines[i]}');
        for (final match in emailMatches) {
          log(match.group(0)!);
          if (match.group(0)!.isNotEmpty) {
            isAddress = false;
          }
        }
        log('is address $isAddress');
        if (isAddress) {
          foundAddresses.add(lines[i]);
        }
      }
    }

    final finalAddress = <String>[];
    log(finalAddress.length.toString());
    if (foundAddresses.length % 2 == 0 && foundAddresses.length > 1) {
      for (int i = 1; i <= foundAddresses.length; i = i + 2) {
        finalAddress.add(foundAddresses[i - 1] + foundAddresses[i]);
      }
    } else {
      if (foundAddresses.length == 1) {
        finalAddress.add(foundAddresses[0]);
      } else if (foundAddresses.length > 2) {
        finalAddress.add(foundAddresses[0]);
        for (int i = 2; i <= foundAddresses.length; i = i + 2) {
          finalAddress.add(foundAddresses[i - 1] + foundAddresses[i]);
        }
      }
    }
    finalAddress.removeWhere((element) => element == '');

    return finalAddress;
  }

  static List<String> _getCompanyNameFromRandomText({
    List<String>? linesOfScannedText,
    List<_ContactInfo>? nameList,
    List<_ContactInfo>? designationList,
    List<_ContactInfo>? telList,
    List<_ContactInfo>? emailList,
    List<_ContactInfo>? companyList,
    List<_ContactInfo>? websiteList,
    List<_ContactInfo>? addressList,
  }) {
    try {
      final List<String> companyList0 = linesOfScannedText!;
      log('===>Total lines:$linesOfScannedText');
      log('company name from random text');
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('Name');
        for (final name in nameList!) {
          log('$name');
          if (linesOfScannedText.isEmpty) {
            log('$linesOfScannedText is empty');
            break;
          } else {
            log('is not empty');
            log('${linesOfScannedText[index]}==${name.contactData!}');
            log('${linesOfScannedText[index].contains(name.contactData!)}');
            log('${linesOfScannedText[index].contains(name.contactData!)}');
            if (linesOfScannedText[index].contains(name.contactData!)) {
              if (companyList0.contains(linesOfScannedText[index])) {
                companyList0.remove(linesOfScannedText[index]);
                log('remove from name match:$companyList0');
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('designation');
        for (final designation in designationList!) {
          log('$designation');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index]
                .contains(designation.contactData!)) {
              if (companyList0.contains(linesOfScannedText[index])) {
                companyList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('tel');
        for (final tel in telList!) {
          log('$tel');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(tel.contactData!)) {
              if (companyList0.contains(linesOfScannedText[index])) {
                companyList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('email');
        for (final email in emailList!) {
          log('$email');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(email.contactData!)) {
              if (companyList0.contains(linesOfScannedText[index])) {
                companyList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('url');
        for (final url in websiteList!) {
          log('$url');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(url.contactData!)) {
              if (companyList0.contains(linesOfScannedText[index])) {
                companyList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      log('address');
      for (final addressData in addressList!) {
        log('$addressData');
        log('list');
        for (int index = 0; index < companyList0.length; index++) {
          log(companyList0[index]);
          if (companyList0.isEmpty) {
            break;
          } else {
            if (addressData.contactData!.contains(companyList0[index])) {
              companyList0.removeAt(index);
            }
          }
        }
      }
      log('===>Total lines:$linesOfScannedText');
      log('===>Company Lines:$companyList0');
      return companyList0;
    } catch (e) {
      log('===>Company empty error:$e');
      return [];
    }
  }

  static List<String> _getNameFromRandomText({
    List<String>? linesOfScannedText,
    List<_ContactInfo>? nameList,
    List<_ContactInfo>? designationList,
    List<_ContactInfo>? telList,
    List<_ContactInfo>? emailList,
    List<_ContactInfo>? companyList,
    List<_ContactInfo>? websiteList,
    List<_ContactInfo>? addressList,
  }) {
    try {
      final List<String> nameList0 = linesOfScannedText!;
      log('===>Total lines:$linesOfScannedText');
      log('company name from random text');
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('Company');
        for (final company in companyList!) {
          log('$company');
          if (linesOfScannedText.isEmpty) {
            log('$linesOfScannedText is empty');
            break;
          } else {
            log('is not empty');
            log('${linesOfScannedText[index]}==${company.contactData!}');
            log('${linesOfScannedText[index].contains(company.contactData!)}');
            log('${linesOfScannedText[index].contains(company.contactData!)}');
            if (linesOfScannedText[index].contains(company.contactData!)) {
              if (nameList0.contains(linesOfScannedText[index])) {
                nameList0.remove(linesOfScannedText[index]);
                log('remove from company match:$nameList0');
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('designation');
        for (final designation in designationList!) {
          log('$designation');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index]
                .contains(designation.contactData!)) {
              if (nameList0.contains(linesOfScannedText[index])) {
                nameList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('tel');
        for (final tel in telList!) {
          log('$tel');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(tel.contactData!)) {
              if (nameList0.contains(linesOfScannedText[index])) {
                nameList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('email');
        for (final email in emailList!) {
          log('$email');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(email.contactData!)) {
              if (nameList0.contains(linesOfScannedText[index])) {
                nameList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      for (int index = 0; index < linesOfScannedText.length; index++) {
        log(linesOfScannedText[index]);
        log('url');
        for (final url in websiteList!) {
          log('$url');
          if (linesOfScannedText.isEmpty) {
            break;
          } else {
            if (linesOfScannedText[index].contains(url.contactData!)) {
              if (nameList0.contains(linesOfScannedText[index])) {
                nameList0.remove(linesOfScannedText[index]);
              }
            }
          }
        }
      }
      log('address');
      for (final addressData in addressList!) {
        log('$addressData');
        log('list');
        for (int index = 0; index < nameList0.length; index++) {
          log(nameList0[index]);
          if (nameList0.isEmpty) {
            break;
          } else {
            if (addressData.contactData!.contains(nameList0[index])) {
              nameList0.removeAt(index);
            }
          }
        }
      }
      log('===>Total lines:$linesOfScannedText');
      log('===>name Lines:$nameList0');
      return nameList0;
    } catch (e) {
      log('===>Company empty error:$e');
      return [];
    }
  }
}

class _ContactInfo {
  _ContactInfo({this.contactData, this.type});

  String? contactData;
  String? type;

  @override
  String toString() => 'ContactInfo($contactData, $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ContactInfo &&
          runtimeType == other.runtimeType &&
          contactData == other.contactData &&
          type == other.type;

  @override
  int get hashCode => Object.hash(contactData, type);
}

class ScannedContactDraft {
  ScannedContactDraft({
    this.name = '',
    this.designation = '',
    this.company = '',
    List<String>? phones,
    List<String>? emails,
    List<String>? websites,
    List<String>? addresses,
  })  : phones = phones ?? [''],
        emails = emails ?? [''],
        websites = websites ?? [''],
        addresses = addresses ?? [''];

  String name;
  String designation;
  String company;
  List<String> phones;
  List<String> emails;
  List<String> websites;
  List<String> addresses;

  List<ContactFieldEntry> nameEntries() =>
      [ContactFieldEntry(value: name)];
  List<ContactFieldEntry> designationEntries() =>
      [ContactFieldEntry(value: designation)];
  List<ContactFieldEntry> companyEntries() =>
      [ContactFieldEntry(value: company)];
  List<ContactFieldEntry> phoneEntries() => phones
      .map(
        (v) => ContactFieldEntry(
          value: v,
          type: v.contains('+') ? 'Cell' : 'Tel',
        ),
      )
      .toList();
  List<ContactFieldEntry> emailEntries() => emails
      .map((v) => ContactFieldEntry(value: v, type: 'Company'))
      .toList();
  List<ContactFieldEntry> websiteEntries() => websites
      .map((v) => ContactFieldEntry(value: v, type: 'Company'))
      .toList();
  List<ContactFieldEntry> addressEntries() =>
      addresses.map((v) => ContactFieldEntry(value: v)).toList();
}
