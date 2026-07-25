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
import 'package:visiting_card/features/scan/domain/scanned_image_model.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_edit_field_cards.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

/// Card Details after scanner Edit Contact Info → Next (Figma layout).
class VisitingCardScannedDetailsScreen extends StatefulWidget {
  const VisitingCardScannedDetailsScreen({super.key});

  @override
  State<VisitingCardScannedDetailsScreen> createState() =>
      _VisitingCardScannedDetailsScreenState();
}

class _VisitingCardScannedDetailsScreenState
    extends State<VisitingCardScannedDetailsScreen> {
  static const _templates =
      VisitingCardTemplateViewModel.horizontalTemplates;

  final GlobalKey _templateCaptureKey = GlobalKey();
  late VisitingCardEditContactViewModel _previewVm;
  late String _selectedTemplateId;
  late final ScrollController _templateScrollController;
  late final PageController _scanImagePageController;
  bool _isDownloadingTemplate = false;
  bool _isDownloadingScan = false;

  @override
  void initState() {
    super.initState();
    _templateScrollController = ScrollController();
    _scanImagePageController = PageController();
    final first = _templates.first;
    _selectedTemplateId = first.id;
    _previewVm = VisitingCardEditContactViewModel.fromTemplate(
      first,
      isHorizontal: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncPreviewFromScan();
    });
  }

  @override
  void dispose() {
    _templateScrollController.dispose();
    _scanImagePageController.dispose();
    _previewVm.dispose();
    super.dispose();
  }

  void _syncPreviewFromScan() {
    final scan = context.read<VisitingCardScanViewModel>();
    _previewVm.applyContactLists(
      names: scan.names,
      designations: scan.designations,
      companies: scan.companies,
      phones: scan.phones,
      emails: scan.emails,
      websites: scan.websites,
      addresses: scan.addresses,
    );
  }

  void _selectTemplate(VisitingCardTemplateItem item) {
    if (item.id == _selectedTemplateId) return;
    final next = VisitingCardEditContactViewModel.fromTemplate(
      item,
      isHorizontal: true,
    );
    final scan = context.read<VisitingCardScanViewModel>();
    next.applyContactLists(
      names: scan.names,
      designations: scan.designations,
      companies: scan.companies,
      phones: scan.phones,
      emails: scan.emails,
      websites: scan.websites,
      addresses: scan.addresses,
    );
    setState(() {
      _previewVm.dispose();
      _previewVm = next;
      _selectedTemplateId = item.id;
    });
  }

  Future<void> _onViewAll() async {
    final selected = await showModalBottomSheet<VisitingCardTemplateItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                  child: Text(
                    'Change Template',
                    style: ui.AppTextStyles.mainText().copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.75,
                    ),
                    itemCount: _templates.length,
                    itemBuilder: (_, i) {
                      final item = _templates[i];
                      final selected = item.id == _selectedTemplateId;
                      return GestureDetector(
                        onTap: () => Navigator.pop(ctx, item),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.center,
                              child: Image.asset(
                                item.frontAsset,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (selected)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: _SelectedCheck(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null && mounted) {
      _selectTemplate(selected);
    }
  }

  Future<Uint8List?> _captureTemplateSide(int side) async {
    _previewVm.setSide(side);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    try {
      return await captureVisitingCardPngBytes(
        _templateCaptureKey,
        isHorizontal: _previewVm.isHorizontal,
      );
    } catch (_) {
      return null;
    }
  }

  /// Scanner image download → gallery only (scanned photos, not template).
  Future<void> _onDownloadScanImages() async {
    if (_isDownloadingScan || _isDownloadingTemplate) return;
    final images = context.read<VisitingCardScanViewModel>().images;
    if (images.isEmpty) return;

    setState(() => _isDownloadingScan = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      final stamp = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final path = image.filePath;
        if (path != null && File(path).existsSync()) {
          await Gal.putImage(path, album: 'Visiting Card');
          continue;
        }
        final tmp = File(
          '${Directory.systemTemp.path}/vc_scan_${stamp}_$i.jpg',
        );
        await tmp.writeAsBytes(image.bytes, flush: true);
        await Gal.putImage(tmp.path, album: 'Visiting Card');
      }

      if (!mounted) return;
      ui.AppToast.success(context, 'Downloaded to gallery');
    } catch (_) {
      if (!mounted) return;
      ui.AppToast.show(context, message: 'Failed to download scanned card');
    } finally {
      if (mounted) setState(() => _isDownloadingScan = false);
    }
  }

  /// Template download → gallery only (rendered template front/back).
  Future<void> _onDownloadTemplate() async {
    if (_isDownloadingTemplate || _isDownloadingScan) return;
    setState(() => _isDownloadingTemplate = true);

    _syncPreviewFromScan();
    final previous = _previewVm.sideIndex;

    try {
      final frontBytes = await _captureTemplateSide(0);
      final backBytes = await _captureTemplateSide(1);
      if (!mounted) return;
      _previewVm.setSide(previous);

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
      _previewVm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to download visiting card');
    } finally {
      if (mounted) {
        setState(() => _isDownloadingTemplate = false);
      }
    }
  }

  Future<void> _onSave() async {
    final vm = context.read<VisitingCardScanViewModel>();
    if (vm.isSaving) return;

    final home = context.read<HomeViewModel>();
    final folder = context.read<FolderViewModel>();
    final isUpdate = vm.isUpdatingExisting;
    final phoneContact = vm.buildSavedContact();

    final ok = await vm.saveScannedCard(
      homeViewModel: home,
      folderViewModel: folder,
    );
    if (!mounted) return;

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
    } else {
      await VisitingCardShareHelper.saveContactToPhone(context, phoneContact);
      if (!mounted) return;
      context.read<ParentViewModel>().changeIndex(0);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Share Via dialog — action row Share only.
  Future<void> _onShareContact() async {
    _syncPreviewFromScan();
    await VisitingCardShareHelper.showShareViaDialog(
      context,
      contact: _previewVm.buildSavedContact(),
      fallbackName: 'Visiting Card',
    );
  }

  /// Scanner corner share → front/back scanned images (no dialog).
  Future<void> _onShareScanImages() async {
    final images = context.read<VisitingCardScanViewModel>().images;
    if (images.isEmpty) return;

    try {
      final files = <XFile>[];
      final stamp = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final path = image.filePath;
        if (path != null && File(path).existsSync()) {
          files.add(XFile(path));
          continue;
        }
        final tmp = File(
          '${Directory.systemTemp.path}/vc_share_scan_${stamp}_$i.jpg',
        );
        await tmp.writeAsBytes(image.bytes, flush: true);
        files.add(XFile(tmp.path));
      }
      if (files.isEmpty) return;
      await Share.shareXFiles(files, text: 'Visiting Card');
    } catch (_) {
      if (!mounted) return;
      ui.AppToast.show(context, message: 'Failed to share scanned card');
    }
  }

  /// Template corner share → front/back template images (no dialog).
  Future<void> _onShareTemplate() async {
    if (_isDownloadingTemplate || _isDownloadingScan) return;
    setState(() => _isDownloadingTemplate = true);

    _syncPreviewFromScan();
    final previous = _previewVm.sideIndex;

    try {
      final frontBytes = await _captureTemplateSide(0);
      final backBytes = await _captureTemplateSide(1);
      if (!mounted) return;
      _previewVm.setSide(previous);

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
      _previewVm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to share visiting card');
    } finally {
      if (mounted) setState(() => _isDownloadingTemplate = false);
    }
  }

  Future<void> _onCall(String number) async {
    final cleaned = number.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

  void _scrollTemplates(double delta) {
    if (!_templateScrollController.hasClients) return;
    final target = (_templateScrollController.offset + delta).clamp(
      0.0,
      _templateScrollController.position.maxScrollExtent,
    );
    _templateScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardScanViewModel>();
    final images = vm.images;
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              children: [
                /// Scanned image — swipe front/back (no 1/2 label)
                if (images.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12.w),
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
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.75,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: PageView.builder(
                              controller: _scanImagePageController,
                              itemCount: images.length,
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              itemBuilder: (_, index) =>
                                  _ScannedImage(images[index]),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6.h,
                          left: 6.w,
                          child: _CornerActionButton(
                            onTap: _onShareScanImages,
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
                            onTap: _isDownloadingScan || _isDownloadingTemplate
                                ? null
                                : _onDownloadScanImages,
                            child: Icon(
                              Icons.download_outlined,
                              size: 15.sp,
                              color: ui.Colors.parentIconSelectTextColor,
                            ),
                          ),
                        ),
                        if (_isDownloadingScan)
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
                  ),
                SizedBox(height: 12.h),

                /// Template preview — no white chrome; pager overlaid like template screen
                AnimatedBuilder(
                  animation: _previewVm,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        RepaintBoundary(
                          key: _templateCaptureKey,
                          child: VisitingCardLivePreview(
                            vm: _previewVm,
                            showPager: false,
                          ),
                        ),
                        Positioned(
                          top: 6.h,
                          left: 6.w,
                          child: _CornerActionButton(
                            onTap: _isDownloadingTemplate || _isDownloadingScan
                                ? null
                                : _onShareTemplate,
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
                            onTap: _isDownloadingTemplate ||
                                    _isDownloadingScan
                                ? null
                                : _onDownloadTemplate,
                            child: Icon(
                              Icons.download_outlined,
                              size: 15.sp,
                              color: ui.Colors.parentIconSelectTextColor,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 2.h,
                          child: VisitingCardSidePager(
                            currentPage: _previewVm.sideIndex + 1,
                            canGoPrevious: _previewVm.sideIndex == 1,
                            canGoNext: _previewVm.sideIndex == 0,
                            onPrevious: _previewVm.showFront,
                            onNext: _previewVm.showBack,
                          ),
                        ),
                        if (_isDownloadingTemplate)
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
                    );
                  },
                ),
                SizedBox(height: 16.h),

                /// Change Template + horizontal strip (~3 visible)
                Row(
                  children: [
                    Text(
                      'Change Template',
                      style: ui.AppTextStyles.helperText(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _onViewAll,
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: ui.Colors.parentIconSelectTextColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const visibleCount = 3;
                    final gap = 8.w;
                    final arrowW = 26.w;
                    final listW =
                        constraints.maxWidth - (arrowW * 2) - 4.w;
                    final itemW =
                        (listW - gap * (visibleCount - 1)) / visibleCount;
                    final itemH = itemW / 1.75;

                    return SizedBox(
                      height: itemH,
                      child: Row(
                        children: [
                          _StripArrow(
                            asset: ui.AppAssets.activeLeftSideArrow,
                            onTap: () => _scrollTemplates(-(itemW + gap)),
                          ),
                          Expanded(
                            child: ListView.separated(
                              controller: _templateScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: _templates.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(width: gap),
                              itemBuilder: (_, i) {
                                final item = _templates[i];
                                final selected =
                                    item.id == _selectedTemplateId;
                                return GestureDetector(
                                  onTap: () => _selectTemplate(item),
                                  child: SizedBox(
                                    width: itemW,
                                    height: itemH,
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.06),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.asset(
                                            item.frontAsset,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        if (selected)
                                          const Positioned(
                                            top: 4,
                                            right: 4,
                                            child: _SelectedCheck(),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          _StripArrow(
                            asset: ui.AppAssets.activeRightSideArrow,
                            onTap: () => _scrollTemplates(itemW + gap),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 14.h),

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
                        label: 'Address',
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
                        onTap: _onShareContact,
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
                              subtitle: e.type.isEmpty ? 'Tel' : e.type,
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
                              subtitle: e.type.isEmpty ? 'Company' : e.type,
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
    );
  }
}

class _ScannedImage extends StatelessWidget {
  const _ScannedImage(this.image);

  final ScannedImageModel image;

  @override
  Widget build(BuildContext context) {
    final path = image.filePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.contain);
    }
    return Image.memory(image.bytes, fit: BoxFit.contain);
  }
}

class _SelectedCheck extends StatelessWidget {
  const _SelectedCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: ui.Colors.parentIconSelectTextColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 14, color: Colors.white),
    );
  }
}

class _StripArrow extends StatelessWidget {
  const _StripArrow({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: SvgPicture.asset(asset, width: 22.w, height: 22.w),
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
