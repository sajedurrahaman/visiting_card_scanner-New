import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Builds QR payload from visiting-card contact fields
/// (same shape used when sharing / scanning card data).
class VisitingCardQrPayload {
  VisitingCardQrPayload._();

  static String fromEditContact(VisitingCardEditContactViewModel vm) {
    final buffer = StringBuffer();

    void addLine(String label, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      buffer.writeln('$label: $trimmed.');
    }

    addLine('Name', vm.displayName);
    addLine('Designation', vm.displayDesignation);
    addLine('Company', vm.displayCompany);
    if (vm.displayTagline.isNotEmpty) {
      addLine('Tagline', vm.displayTagline);
    }

    final phones = vm.phones
        .map((e) => e.value.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    addLine('Phone', phones);

    final emails = vm.emails
        .map((e) => e.value.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    addLine('Email', emails);

    final websites = vm.websites
        .map((e) => e.value.trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    addLine('Website', websites);

    addLine('Address', vm.displayAddress);

    final text = buffer.toString().trim();
    return text.isEmpty ? 'Visiting Card' : text;
  }
}
