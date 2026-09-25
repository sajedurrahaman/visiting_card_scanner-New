import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_edit_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_vertical_edit_screen.dart';
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
  bool _isSharingCard = false;
  bool _isDownloading = false;

  Future<Uint8List?> _captureSide(
    VisitingCardEditContactViewModel vm,
    int side,
  ) async {
    vm.setSide(side);
    await waitForVisitingCardCaptureFrame();
    try {
      return await captureVisitingCardPngBytes(
        _cardCaptureKey,
        isHorizontal: vm.isHorizontal,
      );
    } catch (_) {
      return null;
    }
  }

  /// Top-right download → gallery only (not folder / Save).
  Future<void> _onDownload() async {
    if (_isDownloading || _isSharingCard) return;
    setState(() => _isDownloading = true);

    final vm = context.read<VisitingCardEditContactViewModel>();
    final previous = vm.sideIndex;

    try {
      final frontBytes = await _captureSide(vm, 0);
      final backBytes = await _captureSide(vm, 1);
      if (!mounted) return;
      vm.setSide(previous);

      if (frontBytes == null || backBytes == null) {
        ui.AppToast.show(context, message: 'Failed to download visiting card');
        return;
      }

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final frontFile = File(
        '${Directory.systemTemp.path}/vc_template_front_$stamp.png',
      );
      final backFile = File(
        '${Directory.systemTemp.path}/vc_template_back_$stamp.png',
      );
      await frontFile.writeAsBytes(frontBytes, flush: true);
      await backFile.writeAsBytes(backBytes, flush: true);
      await Gal.putImage(frontFile.path, album: 'Visiting Card');
      await Gal.putImage(backFile.path, album: 'Visiting Card');

      if (!mounted) return;
      ui.AppToast.success(context, 'Downloaded to gallery');
    } catch (_) {
      if (!mounted) return;
      vm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to download visiting card');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Scanner-style save → folder + recent (+ phone contacts), then home.
  Future<void> _onSave() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (vm.isSaving) return;

    final home = context.read<HomeViewModel>();
    final folder = context.read<FolderViewModel>();
    final previous = vm.sideIndex;
    final isUpdate = vm.isUpdatingExisting;
    final phoneContact = vm.buildSavedContact();

    final ok = await vm.saveCard(
      homeViewModel: home,
      folderViewModel: folder,
      captureSide: (side) => _captureSide(vm, side),
    );

    if (!mounted) return;
    vm.setSide(previous);

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
      Navigator.pop(context, true);
      return;
    }

    // Same as scanner: also write into phone Contacts.
    await VisitingCardShareHelper.saveContactToPhone(context, phoneContact);
    if (!mounted) return;
    _backToHome();
  }

  /// Template front/back image share (New Card).
  Future<void> _onShareNewCard() async {
    if (_isSharingCard) return;
    setState(() => _isSharingCard = true);

    final vm = context.read<VisitingCardEditContactViewModel>();
    final previous = vm.sideIndex;

    try {
      final frontBytes = await _captureSide(vm, 0);
      final backBytes = await _captureSide(vm, 1);
      if (!mounted) return;
      vm.setSide(previous);

      if (frontBytes == null || backBytes == null) {
        ui.AppToast.show(context, message: 'Failed to share visiting card');
        return;
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final frontFile = File(
        '${Directory.systemTemp.path}/vc_share_template_front_$stamp.png',
      );
      final backFile = File(
        '${Directory.systemTemp.path}/vc_share_template_back_$stamp.png',
      );
      await frontFile.writeAsBytes(frontBytes, flush: true);
      await backFile.writeAsBytes(backBytes, flush: true);
      await Share.shareXFiles(
        [XFile(frontFile.path), XFile(backFile.path)],
        text: 'Visiting Card',
      );
    } catch (_) {
      if (!mounted) return;
      vm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to share visiting card');
    } finally {
      if (mounted) setState(() => _isSharingCard = false);
    }
  }

  /// Scanner visiting-card Share Via dialog.
  Future<void> _onShare() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    await VisitingCardShareHelper.showShareViaDialog(
      context,
      contact: vm.buildSavedContact(),
      fallbackName: 'Visiting Card',
      onShareNewCard: _onShareNewCard,
    );
  }

  Future<void> _onCall(String number) async {
    final cleaned = number.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _onOpenEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _onOpenWebsite(String url) async {
    var value = url.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onOpenMap(String address) async {
    final encoded = Uri.encodeComponent(address.trim());
    if (encoded.isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _backToHome() {
    context.read<ParentViewModel>().changeIndex(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    final firstPhone = vm.phones
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => e.value.trim())
        .firstOrNull;
    final firstAddress = vm.addresses
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => e.value.trim())
        .firstOrNull;

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
      body: Stack(
        children: [
          Column(
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
                      // Capture target only — corner icons stay outside so they
                      // are not baked into saved front/back images.
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          RepaintBoundary(
                            key: _cardCaptureKey,
                            child: VisitingCardLivePreview(
                              vm: vm,
                              showPager: false,
                              singleLineText: true,
                            ),
                          ),
                          Positioned(
                            top: 6.h,
                            left: 6.w,
                            child: _CornerActionButton(
                              onTap: _isSharingCard || _isDownloading
                                  ? null
                                  : _onShareNewCard,
                              child: SvgPicture.asset(
                                ui.AppAssets.visitingTemplateShareIcon,
                                width: 15.w,
                                height: 15.w,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6.h,
                            right: 6.w,
                            child: _CornerActionButton(
                              onTap: _isDownloading ||
                                      _isSharingCard ||
                                      vm.isSaving
                                  ? null
                                  : _onDownload,
                              child: Icon(
                                Icons.download_outlined,
                                size: 15.sp,
                                color: ui.Colors.parentIconSelectTextColor,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6.h,
                            right: 6.w,
                            child: _CornerActionButton(
                              onTap: () {
                                if (vm.isHorizontal) {
                                  VisitingCardLandscapeEditScreen.open(
                                    context,
                                    vm: vm,
                                  );
                                } else {
                                  VisitingCardVerticalEditScreen.open(
                                    context,
                                    vm: vm,
                                  );
                                }
                              },
                              child: SvgPicture.asset(
                                ui.AppAssets.visitingTemplateEditIconOne,
                                width: 15.w,
                                height: 15.w,
                              ),
                            ),
                          ),
                          if (_isDownloading || _isSharingCard)
                            Positioned.fill(
                              child: ColoredBox(
                                color: Colors.black.withValues(alpha: 0.18),
                                child: Center(
                                  child: SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      color:
                                          ui.Colors.parentIconSelectTextColor,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                        asset: ui.AppAssets.visitingTemplatePhoneIcon,
                        label: 'Tel',
                        onTap: firstPhone == null
                            ? null
                            : () => _onCall(firstPhone),
                      ),
                      _ActionItem(
                        asset: ui.AppAssets.visitingTemplateLocationIcon,
                        label: 'Location',
                        onTap: firstAddress == null
                            ? null
                            : () => _onOpenMap(firstAddress),
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
                              onTap: () => _onCall(e.value),
                            ),
                          ),
                      ...vm.emails
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateMailIcon,
                              value: e.value,
                              subtitle: e.type.isEmpty ? 'Email' : e.type,
                              onTap: () => _onOpenEmail(e.value),
                            ),
                          ),
                      ...vm.websites
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateWebsiteIcon,
                              value: e.value,
                              subtitle: e.type.isEmpty ? 'Website' : e.type,
                              onTap: () => _onOpenWebsite(e.value),
                            ),
                          ),
                      ...vm.addresses
                          .where((e) => e.value.trim().isNotEmpty)
                          .map(
                            (e) => _ContactRow(
                              icon: ui.AppAssets.visitingTemplateLocationIcon,
                              value: e.value,
                              subtitle: 'Address',
                              onTap: () => _onOpenMap(e.value),
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
                    label: vm.isSaving
                        ? (vm.isUpdatingExisting ? 'Updating...' : 'Saving...')
                        : (vm.isUpdatingExisting ? 'Update' : 'Save'),
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
          if (vm.isSaving)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ui.Colors.parentIconSelectTextColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerActionButton extends StatelessWidget {
  const _CornerActionButton({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.asset,
    required this.label,
    this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
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
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  final String icon;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: SvgPicture.asset(icon, width: 22.w, height: 22.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: InkWell(
              onTap: onTap,
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
          ),
        ],
      ),
    );
  }
}
