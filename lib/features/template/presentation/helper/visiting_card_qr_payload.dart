import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Builds QR payload from visiting-card contact fields
/// (same shape used when sharing / scanning card data).
class VisitingCardQrPayload {
  VisitingCardQrPayload._();

  static String fromEditContact(VisitingCardEditContactViewModel vm) {
    return _build(
      name: vm.displayName,
      designation: vm.displayDesignation,
      company: vm.displayCompany,
      tagline: vm.displayTagline,
      phones: vm.phones.map((e) => e.value).toList(),
      emails: vm.emails.map((e) => e.value).toList(),
      websites: vm.websites.map((e) => e.value).toList(),
      address: vm.displayAddress,
    );
  }

  static String fromScanContact(VisitingCardScanViewModel vm) {
    return _build(
      name: vm.names.isNotEmpty ? vm.names.first.value : '',
      designation:
          vm.designations.isNotEmpty ? vm.designations.first.value : '',
      company: vm.companies.isNotEmpty ? vm.companies.first.value : '',
      tagline: vm.taglines.isNotEmpty ? vm.taglines.first.value : '',
      phones: vm.phones.map((e) => e.value).toList(),
      emails: vm.emails.map((e) => e.value).toList(),
      websites: vm.websites.map((e) => e.value).toList(),
      address: vm.addresses.isNotEmpty ? vm.addresses.first.value : '',
    );
  }

  static String _build({
    required String name,
    required String designation,
    required String company,
    String tagline = '',
    required List<String> phones,
    required List<String> emails,
    required List<String> websites,
    required String address,
  }) {
    final buffer = StringBuffer();

    void addLine(String label, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      buffer.writeln('$label: $trimmed.');
    }

    addLine('Name', name);
    addLine('Designation', designation);
    addLine('Company', company);
    if (tagline.trim().isNotEmpty) {
      addLine('Tagline', tagline);
    }

    addLine(
      'Phone',
      phones.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', '),
    );
    addLine(
      'Email',
      emails.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', '),
    );
    addLine(
      'Website',
      websites.map((e) => e.trim()).where((e) => e.isNotEmpty).join(', '),
    );
    addLine('Address', address);

    final text = buffer.toString().trim();
    return text.isEmpty ? 'Visiting Card' : text;
  }
}
