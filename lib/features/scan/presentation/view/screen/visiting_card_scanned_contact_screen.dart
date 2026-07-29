import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scanned_details_screen.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_payload.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_logo_picker_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_tempalte_qrcode_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// First-pass scan OCR edit — shows **scanned photos** (1/2, 2/2).
/// Template live-preview edit is [VisitingCardScanTemplateEditScreen]
/// (opened from Card Details after a template is selected).
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

  Future<void> _clearFocus() async {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _onChooseQr() async {
    final vm = context.read<VisitingCardScanViewModel>();
    await _clearFocus();
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardTempalteQrcodeScreen(
          qrData: VisitingCardQrPayload.fromScanContact(vm),
        ),
      ),
    );
    if (!mounted) return;
    await _clearFocus();
    if (path == null || path.isEmpty) return;
    vm.applyQrImage(path);
    if (!mounted) return;
    ui.AppToast.success(context, 'QR Code uploaded successfully');
    await _clearFocus();
  }

  Future<void> _onChooseLogo() async {
    final vm = context.read<VisitingCardScanViewModel>();
    await _clearFocus();
    final file = await VisitingCardLogoPickerScreen.open(context);
    if (!mounted) return;
    await _clearFocus();
    if (file == null) return;
    final path = await vm.persistLogoFile(file);
    if (!mounted) return;
    vm.applyLogoImage(path);
    ui.AppToast.success(context, 'Logo uploaded successfully');
    await _clearFocus();
  }

  Future<void> _onNext() async {
    FocusScope.of(context).unfocus();
    final vm = context.read<VisitingCardScanViewModel>();
    final images = vm.images;

    // 1/2 → go to 2/2 first; only then open Card Details.
    if (images.length > 1 && _currentIndex < images.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardScannedDetailsScreen(),
        ),
      ),
    );
    // Update flow: details pop(true) → leave edit and return to saved card.
    if (saved == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardScanViewModel>();
    final images = vm.images;
    final isFirst = _currentIndex == 0;
    final isLast = images.isEmpty || _currentIndex >= images.length - 1;
    // QR / logo only on back side (2/2), same as template edit flow.
    final canEditMedia = _currentIndex == 1;

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
                      '${images.isEmpty ? 0 : _currentIndex + 1}/${images.length}',
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
                VisitingSelectActionCard(
                  label: 'QR Code',
                  buttonLabel: 'Choose QR Code',
                  enabled: canEditMedia,
                  onTap: _onChooseQr,
                ),
                VisitingSelectActionCard(
                  label: 'Image Selected',
                  buttonLabel: 'Choose logo',
                  enabled: canEditMedia,
                  onTap: _onChooseLogo,
                ),
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
                VisitingSimpleFieldCard(
                  title: 'Tagline',
                  entries: vm.taglines,
                  showAddIcon: false,
                  onChanged: (i, v) =>
                      vm.updateSimpleField(vm.taglines, i, v),
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
                  label: 'Next',
                  onTap: _onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
