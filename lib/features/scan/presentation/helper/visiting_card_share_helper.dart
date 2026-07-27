import 'dart:developer';

import 'package:contacts_service_plus/contacts_service_plus.dart' as csp;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_share_qr_screen.dart';

/// Share Via actions — same options as PDF Scanner Share dialog.
class VisitingCardShareHelper {
  VisitingCardShareHelper._();

  static Future<bool>? _contactsPermissionFuture;

  static String shareFormattedData(SavedContactInfo contact) {
    var formattedData = '';

    if (contact.name.trim().isNotEmpty) {
      formattedData += 'Name: ${contact.name.trim()}.\n';
    }
    if (contact.designation.trim().isNotEmpty) {
      formattedData += 'Designation: ${contact.designation.trim()}.\n';
    }
    if (contact.company.trim().isNotEmpty) {
      formattedData += 'Company: ${contact.company.trim()}.\n';
    }

    final phones = contact.phones
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => e.value.trim())
        .join(', ');
    if (phones.isNotEmpty) {
      formattedData += 'Phone: $phones.\n';
    }

    final emails = contact.emails
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => e.value.trim())
        .join(', ');
    if (emails.isNotEmpty) {
      formattedData += 'Email: $emails.\n';
    }

    final websites = contact.websites
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => e.value.trim())
        .join(', ');
    if (websites.isNotEmpty) {
      formattedData += 'Website: $websites.\n';
    }

    final addresses = contact.addresses
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.replaceAll(RegExp(r'\n|\r\n'), ' ').trim())
        .join(', ');
    if (addresses.isNotEmpty) {
      formattedData += 'Address: $addresses.\n';
    }

    return formattedData.trim();
  }

  static Future<void> showShareViaDialog(
    BuildContext context, {
    required SavedContactInfo contact,
    String fallbackName = '',
    Future<void> Function()? onShareOldCard,
    Future<void> Function()? onShareNewCard,
  }) async {
    final data = contact.name.trim().isEmpty && fallbackName.trim().isNotEmpty
        ? SavedContactInfo(
            name: fallbackName,
            designation: contact.designation,
            company: contact.company,
            tagline: contact.tagline,
            phones: contact.phones,
            emails: contact.emails,
            websites: contact.websites,
            addresses: contact.addresses,
            imagePaths: contact.imagePaths,
            source: contact.source,
            templateId: contact.templateId,
          )
        : contact;

    final itemCount = 5 +
        (onShareOldCard != null ? 1 : 0) +
        (onShareNewCard != null ? 1 : 0);
    final rowCount = (itemCount / 3).ceil();
    final dialogHeight = (rowCount * 88.0).clamp(190.0, 280.0);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Share Via..'),
          content: SizedBox(
            height: dialogHeight,
            width: MediaQuery.sizeOf(dialogContext).width,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              padding: EdgeInsets.zero,
              children: [
                _ShareViaItem(
                  icon: Icons.contact_phone,
                  label: 'Save Contact',
                  onTap: () async {
                    // Close dialog first so snackbar shows on details screen.
                    Navigator.pop(dialogContext);
                    if (!context.mounted) return;
                    await saveContactToPhone(context, data);
                  },
                ),
                _ShareViaItem(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await sendSms(data);
                  },
                ),
                _ShareViaItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await sendEmail(data);
                  },
                ),
                _ShareViaItem(
                  icon: Icons.qr_code_2_outlined,
                  label: 'QR Code',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitingCardShareQrScreen(
                          shareText: shareFormattedData(data),
                        ),
                      ),
                    );
                  },
                ),
                if (onShareOldCard != null)
                  _ShareViaItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Old Card',
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      if (!context.mounted) return;
                      await onShareOldCard();
                    },
                  ),
                if (onShareNewCard != null)
                  _ShareViaItem(
                    icon: Icons.style_outlined,
                    label: 'New Card',
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      if (!context.mounted) return;
                      await onShareNewCard();
                    },
                  ),
                _ShareViaItem(
                  icon: Icons.share,
                  label: 'More Share',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await Share.share(shareFormattedData(data));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Permission: `permission_handler`
  /// Insert: `flutter_contacts` (primary) + `contacts_service_plus` (fallback)
  static Future<void> saveContactToPhone(
    BuildContext context,
    SavedContactInfo contact,
  ) async {
    final permission = await _requestContactsPermission();
    log('contacts permission granted=$permission');

    if (!permission) {
      if (context.mounted) {
        ui.AppToast.show(
          context,
          message: 'Permission Denied. Please enable Contacts permission.',
          backgroundColor: const Color(0xFFE53935),
        );
      }
      return;
    }

    try {
      await _createWithFlutterContacts(contact);
      log('Contact saved via flutter_contacts');
      if (context.mounted) {
        ui.AppToast.success(context, 'Contact Created Successfully!');
      }
      return;
    } catch (e, st) {
      log('flutter_contacts create failed: $e\n$st');
    }

    try {
      await _createWithContactsServicePlus(contact);
      log('Contact saved via contacts_service_plus');
      if (context.mounted) {
        ui.AppToast.success(context, 'Contact Created Successfully!');
      }
    } catch (e, st) {
      log('contacts_service_plus create failed: $e\n$st');
      if (context.mounted) {
        ui.AppToast.show(
          context,
          message: 'Failed to Create Contact: $e',
          backgroundColor: const Color(0xFFE53935),
        );
      }
    }
  }

  static Future<bool> _requestContactsPermission() {
    if (_contactsPermissionFuture == null) {
      final f = _performContactsPermissionRequest();
      _contactsPermissionFuture = f;
      f.whenComplete(() {
        if (identical(_contactsPermissionFuture, f)) {
          _contactsPermissionFuture = null;
        }
      });
    }
    return _contactsPermissionFuture!;
  }

  static Future<bool> _performContactsPermissionRequest() async {
    try {
      // 1) permission_handler (PDF Scanner style)
      var status = await Permission.contacts.status;
      log('Permission.contacts.status=$status');

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isDenied || status.isRestricted) {
        try {
          status = await Permission.contacts.request();
          log('Permission.contacts.request=$status');
          if (status.isGranted || status.isLimited) return true;
        } on PlatformException catch (e) {
          final msg = '${e.message} ${e.details}';
          if (msg.contains('already running')) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            status = await Permission.contacts.request();
            if (status.isGranted || status.isLimited) return true;
          } else {
            rethrow;
          }
        }
      }

      // 2) flutter_contacts permission API (Android/iOS write)
      try {
        final fcStatus = await fc.FlutterContacts.permissions
            .request(fc.PermissionType.readWrite);
        log('FlutterContacts.permissions=$fcStatus');
        if (fcStatus == fc.PermissionStatus.granted ||
            fcStatus == fc.PermissionStatus.limited) {
          return true;
        }
      } catch (e) {
        log('FlutterContacts.permissions error: $e');
      }

      status = await Permission.contacts.status;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return status.isGranted || status.isLimited;
    } on PlatformException catch (e) {
      log('Contacts permission error: $e');
      return false;
    }
  }

  static Future<void> _createWithFlutterContacts(
    SavedContactInfo contact,
  ) async {
    final nameParts = contact.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final first = nameParts.isNotEmpty ? nameParts.first : contact.name.trim();
    final last =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    final phones = contact.phones
        .where((e) => e.value.trim().isNotEmpty)
        .map(
          (e) => fc.Phone(
            number: e.value.trim(),
            label: const fc.Label(fc.PhoneLabel.mobile),
          ),
        )
        .toList();

    final emails = contact.emails
        .where((e) => e.value.trim().isNotEmpty)
        .map(
          (e) => fc.Email(
            address: e.value.trim(),
            label: const fc.Label(fc.EmailLabel.work),
          ),
        )
        .toList();

    final websites = contact.websites
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => fc.Website(url: e.value.trim()))
        .toList();

    final addresses = contact.addresses
        .where((e) => e.trim().isNotEmpty)
        .map((e) => fc.Address(formatted: e.trim()))
        .toList();

    final newContact = fc.Contact(
      name: fc.Name(first: first, last: last),
      organizations: [
        if (contact.company.trim().isNotEmpty ||
            contact.designation.trim().isNotEmpty)
          fc.Organization(
            name: contact.company.trim().isEmpty
                ? null
                : contact.company.trim(),
            jobTitle: contact.designation.trim().isEmpty
                ? null
                : contact.designation.trim(),
          ),
      ],
      phones: phones,
      emails: emails,
      websites: websites,
      addresses: addresses,
    );

    await fc.FlutterContacts.create(newContact);
  }

  static Future<void> _createWithContactsServicePlus(
    SavedContactInfo contact,
  ) async {
    final phones = contact.phones
        .where((tel) => tel.value.trim().isNotEmpty)
        .map(
          (tel) => csp.Item(
            label: 'mobile',
            value: tel.value.trim(),
          ),
        )
        .toList();

    final emails = contact.emails
        .where((email) => email.value.trim().isNotEmpty)
        .map(
          (email) => csp.Item(
            label: 'work',
            value: email.value.trim(),
          ),
        )
        .toList();

    final nameParts = contact.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final given = nameParts.isNotEmpty ? nameParts.first : contact.name.trim();
    final family =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    final newContact = csp.Contact(
      givenName: given,
      familyName: family,
      displayName: contact.name.trim(),
      company: contact.company.trim(),
      jobTitle: contact.designation.trim(),
      phones: phones,
      emails: emails,
      postalAddresses: contact.addresses
          .where((e) => e.trim().isNotEmpty)
          .map((e) => csp.PostalAddress(street: e.trim()))
          .toList(),
    );

    await csp.ContactsService.addContact(newContact);
  }

  static Future<void> sendEmail(SavedContactInfo contact) async {
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'Contact',
        'body': shareFormattedData(contact),
      },
    );
    final launched = await launchUrl(uri);
    if (!launched) {
      throw 'Could not send email';
    }
  }

  static Future<void> sendSms(SavedContactInfo contact) async {
    final uri = Uri(
      scheme: 'sms',
      queryParameters: {
        'body': shareFormattedData(contact),
      },
    );
    final launched = await launchUrl(uri);
    if (!launched) {
      throw 'Could not send SMS';
    }
  }
}

class _ShareViaItem extends StatelessWidget {
  const _ShareViaItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ui.Colors.parentIconSelectTextColor),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
