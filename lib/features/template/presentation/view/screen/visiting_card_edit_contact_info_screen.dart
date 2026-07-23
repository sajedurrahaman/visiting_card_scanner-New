import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_details_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardEditContactInfoScreen extends StatelessWidget {
  const VisitingCardEditContactInfoScreen({super.key});

  void _onNext(BuildContext context, VisitingCardEditContactViewModel vm) {
    FocusScope.of(context).unfocus();
    if (vm.isFront) {
      vm.showBack();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardDetailsScreen(),
        ),
      ),
    );
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
      body: ListView(
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
              onShowFront: vm.showFront,
              onShowBack: vm.showBack,
            ),
          ),
          SizedBox(height: 14.h),
          VisitingSelectActionCard(
            label: 'QR Code',
            buttonLabel: 'Choose QR Code',
            enabled: vm.canEditQr,
            onTap: vm.chooseQrCode,
          ),
          VisitingSelectActionCard(
            label: 'Image Selected',
            buttonLabel: 'Choose logo',
            enabled: vm.canEditLogo,
            onTap: vm.chooseLogo,
          ),
          VisitingSimpleFieldCard(
            title: 'Name',
            entries: vm.names,
            showAddIcon: false,
            onChanged: (i, v) => vm.updateSimpleField(vm.names, i, v),
            onClear: (i) => vm.clearField(vm.names, i),
          ),
          VisitingSimpleFieldCard(
            title: 'Designation',
            entries: vm.designations,
            showAddIcon: false,
            onChanged: (i, v) => vm.updateSimpleField(vm.designations, i, v),
            onClear: (i) => vm.clearField(vm.designations, i),
          ),
          VisitingSimpleFieldCard(
            title: 'Company',
            entries: vm.companies,
            showAddIcon: false,
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
    );
  }
}
