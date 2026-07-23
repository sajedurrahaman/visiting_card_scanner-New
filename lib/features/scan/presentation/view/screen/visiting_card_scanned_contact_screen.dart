import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardScannedContactScreen extends StatefulWidget {
  const VisitingCardScannedContactScreen({super.key});

  @override
  State<VisitingCardScannedContactScreen> createState() =>
      _VisitingCardScannedContactScreenState();
}

class _VisitingCardScannedContactScreenState
    extends State<VisitingCardScannedContactScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final vm = context.read<VisitingCardScanViewModel>();
    final home = context.read<HomeViewModel>();
    final folder = context.read<FolderViewModel>();
    final isUpdate = vm.isUpdatingExisting;

    // Snapshot before save clears VM fields (PDF Scanner also saves to phone).
    final phoneContact = SavedContactInfo(
      name: vm.names.isNotEmpty ? vm.names.first.value.trim() : '',
      designation:
          vm.designations.isNotEmpty ? vm.designations.first.value.trim() : '',
      company: vm.companies.isNotEmpty ? vm.companies.first.value.trim() : '',
      phones: vm.phones
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      emails: vm.emails
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      websites: vm.websites
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => SavedTypedValue(value: e.value.trim(), type: e.type))
          .toList(),
      addresses: vm.addresses
          .map((e) => e.value.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    final ok = await vm.saveScannedCard(
      homeViewModel: home,
      folderViewModel: folder,
    );
    if (!context.mounted) return;

    if (!ok) {
      ui.AppToast.show(
        context,
        message: isUpdate
            ? 'Failed to update visiting card'
            : 'Failed to save visiting card',
      );
      return;
    }

    if (isUpdate) {
      ui.AppToast.success(context, 'Contact update Successfully');
      Navigator.pop(context);
    } else {
      // Same as PDF Scanner: new Save also writes into phone Contacts.
      // Toast comes from saveContactToPhone (single success/error message).
      await VisitingCardShareHelper.saveContactToPhone(context, phoneContact);
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardScanViewModel>();
    final images = vm.images;
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex >= images.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: Column(
        children: [
          Container(
            height: 210.h,
            color: Colors.white,
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {
                        final path = images[index].filePath;
                        if (path != null && File(path).existsSync()) {
                          return Image.file(File(path), fit: BoxFit.contain);
                        }
                        return Image.memory(
                          images[index].bytes,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: isFirst
                          ? null
                          : () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              ),
                      child: SvgPicture.asset(
                        isFirst
                            ? ui.AppAssets.inactiveLeftSideArrow
                            : ui.AppAssets.activeLeftSideArrow,
                        width: 28.w,
                        height: 28.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '${_currentIndex + 1}/${images.length}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: isLast
                          ? null
                          : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              ),
                      child: SvgPicture.asset(
                        isLast
                            ? ui.AppAssets.inactiveRightSideArrow
                            : ui.AppAssets.activeRightSideArrow,
                        width: 28.w,
                        height: 28.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
                VisitingSimpleFieldCard(
                  title: 'Name',
                  entries: vm.names,
                  showAddIcon: false,
                  onChanged: (i, v) => vm.updateSimpleField(vm.names, i, v),
                  onClear: (_) {},
                ),
                VisitingSimpleFieldCard(
                  title: 'Designation',
                  entries: vm.designations,
                  showAddIcon: false,
                  onChanged: (i, v) =>
                      vm.updateSimpleField(vm.designations, i, v),
                  onClear: (_) {},
                ),
                VisitingSimpleFieldCard(
                  title: 'Company',
                  entries: vm.companies,
                  showAddIcon: false,
                  onChanged: (i, v) =>
                      vm.updateSimpleField(vm.companies, i, v),
                  onClear: (_) {},
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
                  typeOptions:
                      VisitingCardEditContactViewModel.emailWebsiteTypes,
                  onValueChanged: (i, v) =>
                      vm.updateTypedField(vm.emails, i, value: v),
                  onTypeChanged: (i, t) =>
                      vm.updateTypedField(vm.emails, i, type: t),
                  onClear: (i) => vm.removeField(vm.emails, i),
                  onAdd: () =>
                      vm.addField(vm.emails, defaultType: 'Company'),
                ),
                VisitingTypedFieldCard(
                  title: 'Website',
                  entries: vm.websites,
                  typeOptions:
                      VisitingCardEditContactViewModel.emailWebsiteTypes,
                  onValueChanged: (i, v) =>
                      vm.updateTypedField(vm.websites, i, value: v),
                  onTypeChanged: (i, t) =>
                      vm.updateTypedField(vm.websites, i, type: t),
                  onClear: (i) => vm.removeField(vm.websites, i),
                  onAdd: () =>
                      vm.addField(vm.websites, defaultType: 'Company'),
                ),
                VisitingSimpleFieldCard(
                  title: 'Address',
                  entries: vm.addresses,
                  onChanged: (i, v) =>
                      vm.updateSimpleField(vm.addresses, i, v),
                  onClear: (i) => vm.removeField(vm.addresses, i),
                  onAdd: () => vm.addField(vm.addresses, defaultType: ''),
                ),
                SizedBox(height: 8.h),
                VisitingGradientButton(
                  label: vm.isSaving
                      ? (vm.isUpdatingExisting ? 'Updating...' : 'Saving...')
                      : (vm.isUpdatingExisting ? 'Update' : 'Save'),
                  enabled: !vm.isSaving,
                  onTap: () => _save(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
