import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scanned_details_screen.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_payload.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_logo_picker_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_tempalte_qrcode_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/overlay_scroll_lock_toast.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

/// Scan Card Details → Edit: edit contact on the **selected template**
/// (live preview + move/resize logo, QR, company, tagline).
///
/// First OCR pass still uses [VisitingCardScannedContactScreen] (scan photos).
class VisitingCardScanTemplateEditScreen extends StatefulWidget {
  const VisitingCardScanTemplateEditScreen({
    super.key,
    required this.template,
    this.isHorizontal = true,
    this.popOnDone = false,
  });

  final VisitingCardTemplateItem template;
  final bool isHorizontal;

  /// When `true`, Next just pops back (called from ScannedDetailsScreen
  /// which already has Save/Update). When `false`, Next opens
  /// ScannedDetailsScreen with Update/Save buttons.
  final bool popOnDone;

  @override
  State<VisitingCardScanTemplateEditScreen> createState() =>
      _VisitingCardScanTemplateEditScreenState();
}

class _VisitingCardScanTemplateEditScreenState
    extends State<VisitingCardScanTemplateEditScreen> {
  late final VisitingCardScanViewModel _scanVm;
  late final VisitingCardEditContactViewModel _editVm;

  @override
  void initState() {
    super.initState();
    _scanVm = context.read<VisitingCardScanViewModel>();
    _editVm = VisitingCardEditContactViewModel.fromTemplate(
      widget.template,
      isHorizontal: widget.isHorizontal,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFromScan();
    });
  }

  @override
  void dispose() {
    _editVm.dispose();
    super.dispose();
  }

  void _syncFromScan() {
    // Only apply saved transforms if the template matches; otherwise use
    // the new template's default positions.
    final sameTemplate =
        _scanVm.selectedTemplateId == widget.template.id;
    _editVm.applyContactLists(
      names: _scanVm.names,
      designations: _scanVm.designations,
      companies: _scanVm.companies,
      taglines: _scanVm.taglines,
      phones: _scanVm.phones,
      emails: _scanVm.emails,
      websites: _scanVm.websites,
      addresses: _scanVm.addresses,
      qrAssetPath: _scanVm.qrAssetPath,
      logoAssetPath: _scanVm.logoAssetPath,
      hasChosenQr: _scanVm.hasChosenQr,
      hasChosenLogo: _scanVm.hasChosenLogo,
      fieldTransforms: sameTemplate ? _scanVm.fieldTransforms : null,
    );
  }

  void _syncToScan() {
    _replace(_scanVm.names, _editVm.names);
    _replace(_scanVm.designations, _editVm.designations);
    _replace(_scanVm.companies, _editVm.companies);
    _replace(_scanVm.taglines, _editVm.taglines);
    _replace(_scanVm.phones, _editVm.phones, fallbackType: 'Cell');
    _replace(_scanVm.emails, _editVm.emails, fallbackType: 'Company');
    _replace(_scanVm.websites, _editVm.websites, fallbackType: 'Company');
    _replace(_scanVm.addresses, _editVm.addresses);
    _scanVm.qrAssetPath = _editVm.qrAssetPath;
    _scanVm.logoAssetPath = _editVm.logoAssetPath;
    _scanVm.hasChosenQr = _editVm.hasChosenQr;
    _scanVm.hasChosenLogo = _editVm.hasChosenLogo;
    _scanVm.fieldTransforms = _editVm.fieldTransformsSnapshot;
    _scanVm.selectedTemplateId = _editVm.templateId;
    _scanVm.notifyContactChanged();
  }

  void _replace(
    List<ContactFieldEntry> target,
    List<ContactFieldEntry> source, {
    String fallbackType = '',
  }) {
    target
      ..clear()
      ..addAll(
        source.map((e) => ContactFieldEntry(value: e.value, type: e.type)),
      );
    if (target.isEmpty) {
      target.add(ContactFieldEntry(type: fallbackType));
    }
  }

  Future<void> _clearFocus() async {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _onChooseQr() async {
    if (!_editVm.canEditQr) return;
    await _clearFocus();
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardTempalteQrcodeScreen(
          qrData: VisitingCardQrPayload.fromEditContact(_editVm),
        ),
      ),
    );
    if (!mounted) return;
    await _clearFocus();
    if (path == null || path.isEmpty) return;
    _editVm.applyQrImage(path);
    if (!mounted) return;
    ui.AppToast.success(context, 'QR Code uploaded successfully');
  }

  Future<void> _onChooseLogo() async {
    if (!_editVm.canEditLogo) return;
    await _clearFocus();
    final file = await VisitingCardLogoPickerScreen.open(context);
    if (!mounted) return;
    await _clearFocus();
    if (file == null) return;
    final path = await _editVm.persistLogoFile(file);
    if (!mounted) return;
    _editVm.applyLogoImage(path);
    ui.AppToast.success(context, 'Logo uploaded successfully');
  }

  Future<void> _onDone() async {
    FocusScope.of(context).unfocus();
    _editVm.clearOverlaySelection();

    final error = _editVm.validateRequiredContactFields();
    if (error != null) {
      ui.AppToast.show(
        context,
        message: error,
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    if (_editVm.isFront) {
      _editVm.showBack();
      return;
    }
    _syncToScan();

    if (widget.popOnDone) {
      // Called from ScannedDetailsScreen — just pop back, it already
      // has Save/Update.
      Navigator.pop(context, true);
      return;
    }

    // Called from ContactDetailsScreen (saved card edit) — open details
    // screen with Update / Back to Home.
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _scanVm,
          child: const VisitingCardScannedDetailsScreen(),
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _editVm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Edit Contact Info',
              style: ui.AppTextStyles.mainText().copyWith(fontSize: 18.sp),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: OverlayScrollLockToast(
            locked: _editVm.selectedOverlay != null,
            isOverlayGestureActive: () => _editVm.overlayGestureActive,
            child: ListView(
              physics: _editVm.selectedOverlay != null
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
              Container(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: VisitingCardLivePreview(
                  vm: _editVm,
                  enableFieldTransform: true,
                  onShowFront: _editVm.showFront,
                  onShowBack: _editVm.showBack,
                ),
              ),
              SizedBox(height: 14.h),
              VisitingSelectActionCard(
                label: 'QR Code',
                buttonLabel: 'Choose QR Code',
                enabled: _editVm.canEditQr,
                onTap: _onChooseQr,
              ),
              VisitingSelectActionCard(
                label: 'Image Selected',
                buttonLabel: 'Choose logo',
                enabled: _editVm.canEditLogo,
                onTap: _onChooseLogo,
              ),
              VisitingSimpleFieldCard(
                title: 'Name',
                entries: _editVm.names,
                showAddIcon: false,
                maxLength: _editVm.maxDisplayNameLength,
                hasError:
                    _editVm.isFieldInvalid(ContactValidationField.name),
                onChanged: (i, v) =>
                    _editVm.updateSimpleField(_editVm.names, i, v),
                onClear: (i) => _editVm.clearField(_editVm.names, i),
              ),
              VisitingSimpleFieldCard(
                title: 'Designation',
                entries: _editVm.designations,
                showAddIcon: false,
                hasError: _editVm
                    .isFieldInvalid(ContactValidationField.designation),
                onChanged: (i, v) =>
                    _editVm.updateSimpleField(_editVm.designations, i, v),
                onClear: (i) => _editVm.clearField(_editVm.designations, i),
              ),
              VisitingSimpleFieldCard(
                title: 'Company',
                entries: _editVm.companies,
                showAddIcon: false,
                hasError:
                    _editVm.isFieldInvalid(ContactValidationField.company),
                onChanged: (i, v) =>
                    _editVm.updateSimpleField(_editVm.companies, i, v),
                onClear: (i) => _editVm.clearField(_editVm.companies, i),
              ),
              VisitingSimpleFieldCard(
                title: 'Tagline',
                entries: _editVm.taglines,
                showAddIcon: false,
                onChanged: (i, v) =>
                    _editVm.updateSimpleField(_editVm.taglines, i, v),
                onClear: (i) => _editVm.clearField(_editVm.taglines, i),
              ),
              VisitingTypedFieldCard(
                title: 'Tell',
                entries: _editVm.phones,
                typeOptions: VisitingCardEditContactViewModel.telTypes,
                hasError:
                    _editVm.isFieldInvalid(ContactValidationField.phone),
                onValueChanged: (i, v) =>
                    _editVm.updateTypedField(_editVm.phones, i, value: v),
                onTypeChanged: (i, t) =>
                    _editVm.updateTypedField(_editVm.phones, i, type: t),
                onClear: (i) => _editVm.removeField(_editVm.phones, i),
                onAdd: () =>
                    _editVm.addField(_editVm.phones, defaultType: 'Work'),
              ),
              VisitingTypedFieldCard(
                title: 'Email',
                entries: _editVm.emails,
                typeOptions:
                    VisitingCardEditContactViewModel.emailWebsiteTypes,
                hasError:
                    _editVm.isFieldInvalid(ContactValidationField.email),
                onValueChanged: (i, v) =>
                    _editVm.updateTypedField(_editVm.emails, i, value: v),
                onTypeChanged: (i, t) =>
                    _editVm.updateTypedField(_editVm.emails, i, type: t),
                onClear: (i) => _editVm.removeField(_editVm.emails, i),
                onAdd: () =>
                    _editVm.addField(_editVm.emails, defaultType: 'Company'),
              ),
              VisitingTypedFieldCard(
                title: 'Website',
                entries: _editVm.websites,
                typeOptions:
                    VisitingCardEditContactViewModel.emailWebsiteTypes,
                onValueChanged: (i, v) =>
                    _editVm.updateTypedField(_editVm.websites, i, value: v),
                onTypeChanged: (i, t) =>
                    _editVm.updateTypedField(_editVm.websites, i, type: t),
                onClear: (i) => _editVm.removeField(_editVm.websites, i),
                onAdd: () => _editVm.addField(
                  _editVm.websites,
                  defaultType: 'Company',
                ),
              ),
              VisitingSimpleFieldCard(
                title: 'Address',
                entries: _editVm.addresses,
                hasError:
                    _editVm.isFieldInvalid(ContactValidationField.address),
                onChanged: (i, v) =>
                    _editVm.updateSimpleField(_editVm.addresses, i, v),
                onClear: (i) => _editVm.removeField(_editVm.addresses, i),
                onAdd: () =>
                    _editVm.addField(_editVm.addresses, defaultType: ''),
              ),
              SizedBox(height: 8.h),
              VisitingGradientButton(
                label: 'Next',
                onTap: _onDone,
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
