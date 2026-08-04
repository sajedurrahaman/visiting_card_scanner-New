import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_payload.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_details_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_logo_picker_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_tempalte_qrcode_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/overlay_scroll_lock_toast.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardEditContactInfoScreen extends StatelessWidget {
  const VisitingCardEditContactInfoScreen({super.key});

  Future<void> _onNext(
    BuildContext context,
    VisitingCardEditContactViewModel vm,
  ) async {
    FocusScope.of(context).unfocus();
    vm.clearOverlaySelection();

    final error = vm.validateRequiredContactFields();
    if (error != null) {
      ui.AppToast.show(
        context,
        message: error,
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    if (vm.isFront) {
      vm.showBack();
      return;
    }
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardDetailsScreen(),
        ),
      ),
    );
    // Update flow: details pop(true) → leave edit and return to saved card.
    if (updated == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _clearFocus(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _onChooseQr(
    BuildContext context,
    VisitingCardEditContactViewModel vm,
  ) async {
    if (!vm.canEditQr) return;
    await _clearFocus(context);
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardTempalteQrcodeScreen(
          qrData: VisitingCardQrPayload.fromEditContact(vm),
        ),
      ),
    );
    if (!context.mounted) return;
    await _clearFocus(context);
    if (path == null || path.isEmpty) return;
    vm.applyQrImage(path);
    if (!context.mounted) return;
    ui.AppToast.success(context, 'QR Code uploaded successfully');
    await _clearFocus(context);
  }

  Future<void> _onChooseLogo(
    BuildContext context,
    VisitingCardEditContactViewModel vm,
  ) async {
    if (!vm.canEditLogo) return;
    await _clearFocus(context);
    final file = await VisitingCardLogoPickerScreen.open(context);
    if (!context.mounted) return;
    await _clearFocus(context);
    if (file == null) return;
    final path = await vm.persistLogoFile(file);
    if (!context.mounted) return;
    vm.applyLogoImage(path);
    ui.AppToast.success(context, 'Logo uploaded successfully');
    await _clearFocus(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Contact Info',
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: OverlayScrollLockToast(
        locked: vm.selectedOverlay != null,
        isOverlayGestureActive: () => vm.overlayGestureActive,
        child: ListView(
          // One scroll for card + fields. Lock only while an overlay is selected
          // so finger move/resize is not stolen by page scroll.
          physics: vm.selectedOverlay != null
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
              vm: vm,
              enableFieldTransform: true,
              onShowFront: vm.showFront,
              onShowBack: vm.showBack,
            ),
          ),
          SizedBox(height: 14.h),
          VisitingSelectActionCard(
            label: 'QR Code',
            buttonLabel: 'Choose QR Code',
            enabled: vm.canEditQr,
            onTap: () => _onChooseQr(context, vm),
          ),
          VisitingSelectActionCard(
            label: 'Image Selected',
            buttonLabel: 'Choose logo',
            enabled: vm.canEditLogo,
            onTap: () => _onChooseLogo(context, vm),
          ),
          VisitingSimpleFieldCard(
            title: 'Name',
            entries: vm.names,
            showAddIcon: false,
            maxLength: vm.maxDisplayNameLength,
            hasError: vm.isFieldInvalid(ContactValidationField.name),
            onChanged: (i, v) => vm.updateSimpleField(vm.names, i, v),
            onClear: (i) => vm.clearField(vm.names, i),
          ),
          VisitingSimpleFieldCard(
            title: 'Designation',
            entries: vm.designations,
            showAddIcon: false,
            hasError: vm.isFieldInvalid(ContactValidationField.designation),
            onChanged: (i, v) => vm.updateSimpleField(vm.designations, i, v),
            onClear: (i) => vm.clearField(vm.designations, i),
          ),
          VisitingSimpleFieldCard(
            title: 'Company',
            entries: vm.companies,
            showAddIcon: false,
            hasError: vm.isFieldInvalid(ContactValidationField.company),
            onChanged: (i, v) => vm.updateSimpleField(vm.companies, i, v),
            onClear: (i) => vm.clearField(vm.companies, i),
          ),
          VisitingSimpleFieldCard(
            title: 'Tagline',
            entries: vm.taglines,
            showAddIcon: false,
            onChanged: (i, v) => vm.updateSimpleField(vm.taglines, i, v),
            onClear: (i) => vm.clearField(vm.taglines, i),
          ),
          VisitingTypedFieldCard(
            title: 'Tell',
            entries: vm.phones,
            typeOptions: VisitingCardEditContactViewModel.telTypes,
            hasError: vm.isFieldInvalid(ContactValidationField.phone),
            onValueChanged: (i, v) =>
                vm.updateTypedField(vm.phones, i, value: v),
            onTypeChanged: (i, t) =>
                vm.updateTypedField(vm.phones, i, type: t),
            onClear: (i) => vm.removeField(vm.phones, i),
            onAdd: () => vm.addField(vm.phones, defaultType: 'Work'),
          ),
          VisitingTypedFieldCard(
            title: 'Email',
            entries: vm.emails,
            typeOptions: VisitingCardEditContactViewModel.emailWebsiteTypes,
            hasError: vm.isFieldInvalid(ContactValidationField.email),
            onValueChanged: (i, v) =>
                vm.updateTypedField(vm.emails, i, value: v),
            onTypeChanged: (i, t) =>
                vm.updateTypedField(vm.emails, i, type: t),
            onClear: (i) => vm.removeField(vm.emails, i),
            onAdd: () => vm.addField(vm.emails, defaultType: 'Company'),
          ),
          VisitingTypedFieldCard(
            title: 'Website',
            entries: vm.websites,
            typeOptions: VisitingCardEditContactViewModel.emailWebsiteTypes,
            onValueChanged: (i, v) =>
                vm.updateTypedField(vm.websites, i, value: v),
            onTypeChanged: (i, t) =>
                vm.updateTypedField(vm.websites, i, type: t),
            onClear: (i) => vm.removeField(vm.websites, i),
            onAdd: () => vm.addField(vm.websites, defaultType: 'Company'),
          ),
          VisitingSimpleFieldCard(
            title: 'Address',
            entries: vm.addresses,
            hasError: vm.isFieldInvalid(ContactValidationField.address),
            onChanged: (i, v) => vm.updateSimpleField(vm.addresses, i, v),
            onClear: (i) => vm.removeField(vm.addresses, i),
            onAdd: () => vm.addField(vm.addresses, defaultType: ''),
          ),
          SizedBox(height: 8.h),
          VisitingGradientButton(
            label: 'Next',
            onTap: () => _onNext(context, vm),
          ),
        ],
        ),
      ),
    );
  }
}
