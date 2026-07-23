import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

class VisitingCardDetailsScreen extends StatefulWidget {
  const VisitingCardDetailsScreen({super.key});

  @override
  State<VisitingCardDetailsScreen> createState() =>
      _VisitingCardDetailsScreenState();
}

class _VisitingCardDetailsScreenState extends State<VisitingCardDetailsScreen> {
  final GlobalKey _cardCaptureKey = GlobalKey();

  Future<Uint8List?> _captureSide(
    VisitingCardEditContactViewModel vm,
    int side,
  ) async {
    vm.setSide(side);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    try {
      return await captureVisitingCardPngBytes(
        _cardCaptureKey,
        isHorizontal: vm.isHorizontal,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSave() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    final home = context.read<HomeViewModel>();
    final folder = context.read<FolderViewModel>();
    final previous = vm.sideIndex;

    final ok = await vm.saveCard(
      homeViewModel: home,
      folderViewModel: folder,
      captureSide: (side) => _captureSide(vm, side),
    );

    if (!mounted) return;
    vm.setSide(previous);
    ui.AppToast.success(context, ok ? 'Saved to gallery' : 'Save failed');
  }

  Future<void> _onShare() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    final previous = vm.sideIndex;

    final frontBytes = await _captureSide(vm, 0);
    final backBytes = await _captureSide(vm, 1);
    vm.setSide(previous);
    if (frontBytes == null || backBytes == null) return;

    final dir = await Directory.systemTemp.createTemp('share_card');
    final frontFile = File('${dir.path}/visiting_card_front.png');
    final backFile = File('${dir.path}/visiting_card_back.png');
    await frontFile.writeAsBytes(frontBytes, flush: true);
    await backFile.writeAsBytes(backBytes, flush: true);
    await Share.shareXFiles(
      [XFile(frontFile.path), XFile(backFile.path)],
      text: 'Visiting Card',
    );
  }

  void _backToHome() {
    context.read<ParentViewModel>().changeIndex(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          'Card Details',
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
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
                  child: Column(
                    children: [
                      // High-quality capture target (no pager).
                      RepaintBoundary(
                        key: _cardCaptureKey,
                        child: VisitingCardLivePreview(
                          vm: vm,
                          showPager: false,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      VisitingCardLivePreview(
                        vm: vm,
                        pagerOnly: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionItem(
                        asset: ui.AppAssets.visitingTemplateIcon,
                        label: 'Template',
                        onTap: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                      _ActionItem(
                        asset: ui.AppAssets.visitingTemplateEditIcon,
                        label: 'Edit',
                        onTap: () => Navigator.pop(context),
                      ),
                      _ActionItem(
                        asset: ui.AppAssets.visitingTemplateShareIcon,
                        label: 'Share',
                        onTap: _onShare,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: ui.AppTextStyles.helperText(
                          color: const Color(0xFF1A1A1A),
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 72.w,
                        height: 2.h,
                        color: ui.Colors.parentIconSelectTextColor,
                      ),
                      SizedBox(height: 12.h),
                      ...vm.phones
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplatePhoneIcon,
                              value: e.value,
                              subtitle: e.type.isEmpty ? 'Phone' : e.type,
                            ),
                          ),
                      ...vm.emails
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateMailIcon,
                              value: e.value,
                              subtitle: e.type.isEmpty ? 'Email' : e.type,
                            ),
                          ),
                      ...vm.websites
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateWebsiteIcon,
                              value: e.value,
                              subtitle: e.type.isEmpty ? 'Website' : e.type,
                            ),
                          ),
                      ...vm.addresses
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateLocationIcon,
                              value: e.value,
                              subtitle: 'Address',
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: Column(
                children: [
                  VisitingGradientButton(
                    label: vm.isSaving ? 'Saving...' : 'Save',
                    enabled: !vm.isSaving,
                    onTap: _onSave,
                  ),
                  SizedBox(height: 10.h),
                  VisitingOutlinedButton(
                    label: 'Back to Home',
                    onTap: _backToHome,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SvgPicture.asset(asset, width: 28.w, height: 28.w),
          SizedBox(height: 6.h),
          Text(
            label,
            style: ui.AppTextStyles.iconUnderText(
              color: const Color(0xFF1A1A1A),
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.subtitle,
  });

  final String icon;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(icon, width: 22.w, height: 22.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: ui.AppTextStyles.helperText(
                    color: const Color(0xFF1A1A1A),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: ui.AppTextStyles.iconUnderText(
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
