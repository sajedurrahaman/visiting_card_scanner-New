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

import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';

import 'package:visiting_card/features/scan/domain/saved_contact_info.dart';
import 'package:visiting_card/features/scan/domain/saved_contact_info_backup.dart';
import 'package:visiting_card/features/scan/domain/visiting_card_folder_paths.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scan_template_edit_screen.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_edit_contact_info_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';
import 'package:visiting_card/features/home/domain/model/saved_file_model.dart';

enum VisitingCardInitialAction { share }

/// Card Details opened from Recent / Folder thumbnail.
/// Same layout as [VisitingCardScannedDetailsScreen] without Change Template
/// and without Save / Back to Home.
class VisitingCardContactDetailsScreen extends StatefulWidget {
  const VisitingCardContactDetailsScreen({
    super.key,
    required this.item,
    this.initialAction,
  });

  final RecentCardItem item;
  final VisitingCardInitialAction? initialAction;

  @override
  State<VisitingCardContactDetailsScreen> createState() =>
      _VisitingCardContactDetailsScreenState();
}

class _VisitingCardContactDetailsScreenState
    extends State<VisitingCardContactDetailsScreen> {
  static const _templates =
      VisitingCardTemplateViewModel.horizontalTemplates;

  final GlobalKey _templateCaptureKey = GlobalKey();
  late VisitingCardEditContactViewModel _previewVm;
  late final PageController _scanImagePageController;

  SavedContactInfo? _contact;
  List<File> _images = const [];
  List<Uint8List> _imageBytes = const [];
  bool _loading = true;
  bool _isDownloadingTemplate = false;
  bool _isDownloadingScan = false;
  int _imagePageIndex = 0;
  int _imageEpoch = 0;
  bool _handledInitialAction = false;

  bool get _isFromTemplate => _contact?.isFromTemplate == true;

  @override
  void initState() {
    super.initState();
    _scanImagePageController = PageController();
    final first = _templates.first;
    _previewVm = VisitingCardEditContactViewModel.fromTemplate(
      first,
      isHorizontal: true,
    );
    _load();
  }

  VisitingCardTemplateItem _templateForId(String? id) {
    if (id == null || id.isEmpty) return _templates.first;
    for (final item in VisitingCardTemplateViewModel.horizontalTemplates) {
      if (item.id == id) return item;
    }
    for (final item in VisitingCardTemplateViewModel.verticalTemplates) {
      if (item.id == id) return item;
    }
    return _templates.first;
  }

  bool _isHorizontalTemplate(String? id) {
    if (id == null || id.isEmpty) return true;
    return VisitingCardTemplateViewModel.horizontalTemplates
        .any((item) => item.id == id);
  }

  void _initPreviewFromContact(SavedContactInfo? contact) {
    final template = _templateForId(contact?.templateId);
    _previewVm.dispose();
    _previewVm = VisitingCardEditContactViewModel.fromTemplate(
      template,
      isHorizontal: _isHorizontalTemplate(contact?.templateId),
    );
  }

  @override
  void dispose() {
    _scanImagePageController.dispose();
    _previewVm.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storedPath = widget.item.path;
    final folderPath =
        await VisitingCardFolderPaths.resolveContactFolder(storedPath);
    final images = <File>[];
    SavedContactInfo? contact;

    if (folderPath != null && folderPath.isNotEmpty) {
      final dir = Directory(folderPath);
      if (dir.existsSync()) {
        contact = await SavedContactInfo.readFromFolder(folderPath);

        // Folder readable but contact.json missing/corrupt → prefs backup.
        if (contact == null || !contact.hasAnyFieldData) {
          final backup = await SavedContactInfoBackup.load(widget.item.id);
          if (backup != null && backup.hasAnyFieldData) {
            contact = backup;
          }
        }

        // Persist healed contact.json + prefs whenever we recovered fields.
        if (contact != null && contact.hasAnyFieldData) {
          try {
            await SavedContactInfo.writeToFolder(folderPath, contact);
          } catch (e, st) {
            debugPrint('Failed to rewrite contact.json: $e\n$st');
          }
          await SavedContactInfoBackup.save(widget.item.id, contact);
        }

        images.addAll(
          VisitingCardFolderPaths.resolveSideImages(
            folderPath: folderPath,
            contact: contact,
            thumbnailPath: widget.item.thumbnailPath,
          ),
        );

        // Heal Isar absolute path if Documents container UUID changed.
        if (storedPath != null &&
            storedPath.isNotEmpty &&
            storedPath != folderPath) {
          await _healStoredPaths(
            folderPath: folderPath,
            thumbPath: images.isNotEmpty ? images.first.path : null,
          );
        }
      } else {
        final file = File(folderPath);
        if (file.existsSync()) images.add(file);
      }
    }

    // Still no contact fields — try backup even if folder missing.
    if ((contact == null || !contact.hasAnyFieldData)) {
      final backup = await SavedContactInfoBackup.load(widget.item.id);
      if (backup != null && backup.hasAnyFieldData) {
        contact = backup;
      }
    }

    if (images.isEmpty) {
      final thumb = VisitingCardFolderPaths.resolveThumbnail(
        thumbnailPath: widget.item.thumbnailPath,
        folderOrFilePath: folderPath,
      );
      if (thumb != null) images.add(thumb);
    }

    // Bust Flutter FileImage cache — same path after Update otherwise
    // keeps showing the pre-edit card.
    final bytesList = <Uint8List>[];
    for (final file in images) {
      try {
        await FileImage(file).evict();
      } catch (_) {}
      if (await file.exists()) {
        bytesList.add(await file.readAsBytes());
      }
    }

    if (!mounted) return;
    _initPreviewFromContact(contact);
    setState(() {
      _contact = contact;
      _images = images;
      _imageBytes = bytesList;
      _imageEpoch++;
      _imagePageIndex = 0;
      _loading = false;
    });
    if (_scanImagePageController.hasClients) {
      _scanImagePageController.jumpToPage(0);
    }
    _syncPreviewFromContact();
    _runInitialActionIfNeeded();
  }

  Future<void> _healStoredPaths({
    required String folderPath,
    String? thumbPath,
  }) async {
    try {
      final files = AppStorageService().getAllFiles();
      SavedFileModel? target;
      for (final file in files) {
        if (file.id == widget.item.id) {
          target = file;
          break;
        }
      }
      if (target == null) return;
      final healed = target.copyWith(
        path: folderPath,
        pathImage: thumbPath ?? target.pathImage,
      );
      await AppStorageService().updateFile(healed);
    } catch (e, st) {
      debugPrint('Failed to heal stored visiting-card paths: $e\n$st');
    }
  }

  void _runInitialActionIfNeeded() {
    if (_handledInitialAction || !mounted || _loading) return;
    final action = widget.initialAction;
    if (action == null) return;
    _handledInitialAction = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case VisitingCardInitialAction.share:
          _onShareContact();
      }
    });
  }

  void _syncPreviewFromContact() {
    final contact = _contact;
    if (contact == null) {
      _previewVm.applyContactLists(
        names: [ContactFieldEntry(value: widget.item.name)],
        designations: [ContactFieldEntry()],
        companies: [ContactFieldEntry()],
        phones: [ContactFieldEntry(type: 'Cell')],
        emails: [ContactFieldEntry(type: 'Company')],
        websites: [ContactFieldEntry(type: 'Company')],
        addresses: [ContactFieldEntry()],
      );
      return;
    }

    _previewVm.applyContactLists(
      names: [ContactFieldEntry(value: contact.name)],
      designations: [ContactFieldEntry(value: contact.designation)],
      companies: [ContactFieldEntry(value: contact.company)],
      taglines: [ContactFieldEntry(value: contact.tagline)],
      phones: contact.phones.isEmpty
          ? [ContactFieldEntry(type: 'Cell')]
          : contact.phones
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      emails: contact.emails.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.emails
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      websites: contact.websites.isEmpty
          ? [ContactFieldEntry(type: 'Company')]
          : contact.websites
              .map((e) => ContactFieldEntry(value: e.value, type: e.type))
              .toList(),
      addresses: contact.addresses.isEmpty
          ? [ContactFieldEntry()]
          : contact.addresses
              .map((e) => ContactFieldEntry(value: e))
              .toList(),
      qrAssetPath: contact.qrImagePath.isNotEmpty ? contact.qrImagePath : null,
      logoAssetPath:
          contact.logoImagePath.isNotEmpty ? contact.logoImagePath : null,
      hasChosenQr: contact.hasChosenQr,
      hasChosenLogo: contact.hasChosenLogo,
      fieldTransforms: contact.fieldTransforms,
    );
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

  Future<void> _onDownloadScanImages() async {
    if (_isDownloadingScan || _isDownloadingTemplate) return;
    if (_images.isEmpty) return;

    setState(() => _isDownloadingScan = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      for (final file in _images) {
        if (await file.exists()) {
          await Gal.putImage(file.path, album: 'Visiting Card');
        }
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

  Future<void> _onDownloadTemplate() async {
    if (_isDownloadingTemplate || _isDownloadingScan) return;
    setState(() => _isDownloadingTemplate = true);

    _syncPreviewFromContact();
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

  Future<void> _onShareScanImages() async {
    if (_images.isEmpty) return;

    try {
      final files = <XFile>[];
      for (final file in _images) {
        if (await file.exists()) {
          files.add(XFile(file.path));
        }
      }
      if (files.isEmpty) return;
      await Share.shareXFiles(files, text: 'Visiting Card');
    } catch (_) {
      if (!mounted) return;
      ui.AppToast.show(context, message: 'Failed to share scanned card');
    }
  }

  Future<void> _onShareTemplate() async {
    if (_isDownloadingTemplate || _isDownloadingScan) return;
    setState(() => _isDownloadingTemplate = true);

    _syncPreviewFromContact();
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

  Future<void> _onShareContact() async {
    _syncPreviewFromContact();
    final contact = _contact ??
        SavedContactInfo(
          name: widget.item.name,
          imagePaths: _images.map((e) => e.path).toList(),
        );

    await VisitingCardShareHelper.showShareViaDialog(
      context,
      contact: contact,
      fallbackName: widget.item.name,
      onShareOldCard: _isFromTemplate ? null : _onShareScanImages,
      onShareNewCard:
          _isFromTemplate ? _onShareScanImages : _onShareTemplate,
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

  Future<void> _openEdit() async {
    final contact = _contact;
    if (contact == null && _images.isEmpty) {
      ui.AppToast.show(context, message: 'No contact data to edit');
      return;
    }

    final editContact = contact ??
        SavedContactInfo(
          name: widget.item.name,
          imagePaths: _images.map((e) => e.path).toList(),
        );

    // Template-generated cards → template edit flow (live preview).
    if (editContact.isFromTemplate) {
      await _openTemplateEdit(editContact);
      return;
    }

    // Scan cards → template edit screen (move logo/QR/company/tagline).
    // Next saves + shows Update toast. Back discards.
    final bytesList = <Uint8List>[];
    for (final file in _images) {
      if (await file.exists()) {
        bytesList.add(await file.readAsBytes());
      }
    }

    final vm = VisitingCardScanViewModel();
    await vm.loadFromSavedContact(
      contact: editContact,
      imageBytesList: bytesList,
      savedFileId: widget.item.id,
      contactFolderPath: widget.item.path,
      folderId: widget.item.folderId,
      dateTime: widget.item.dateTime,
    );
    if (!mounted) return;

    final template = _templateForId(editContact.templateId);
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VisitingCardScanTemplateEditScreen(
            template: template,
            isHorizontal: _isHorizontalTemplate(editContact.templateId),
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      _applyScanVmToPreview(vm);
    }
    await _load();
  }

  void _applyScanVmToPreview(VisitingCardScanViewModel scan) {
    _previewVm.applyContactLists(
      names: scan.names,
      designations: scan.designations,
      companies: scan.companies,
      taglines: scan.taglines,
      phones: scan.phones,
      emails: scan.emails,
      websites: scan.websites,
      addresses: scan.addresses,
      qrAssetPath: scan.qrAssetPath,
      logoAssetPath: scan.logoAssetPath,
      hasChosenQr: scan.hasChosenQr,
      hasChosenLogo: scan.hasChosenLogo,
      fieldTransforms: scan.fieldTransforms,
    );
  }

  Future<void> _openTemplateEdit(SavedContactInfo contact) async {
    final template = _templateForId(contact.templateId);
    final vm = VisitingCardEditContactViewModel.fromTemplate(
      template,
      isHorizontal: _isHorizontalTemplate(contact.templateId),
    );
    vm.applyContactFromSaved(
      contact,
      savedFileId: widget.item.id,
      contactFolderPath: widget.item.path,
      folderId: widget.item.folderId,
      dateTime: widget.item.dateTime,
    );
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardEditContactInfoScreen(),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Widget _buildLivePreviewCard() {
    return AnimatedBuilder(
      animation: _previewVm,
      builder: (context, _) {
        return Stack(
          children: [
            RepaintBoundary(
              key: _templateCaptureKey,
              child: VisitingCardLivePreview(
                key: ValueKey(
                  'preview-$_imageEpoch-'
                  '${_previewVm.qrAssetPath}-'
                  '${_previewVm.logoAssetPath}',
                ),
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
                onTap: _isDownloadingTemplate || _isDownloadingScan
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    final firstPhone = contact?.phones
            .where((e) => e.value.trim().isNotEmpty)
            .map((e) => e.value.trim())
            .firstOrNull;
    final firstAddress = contact?.addresses
            .where((e) => e.trim().isNotEmpty)
            .map((e) => e.trim())
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
                // Template cards: live preview so Update → back shows new QR/logo
                // immediately (avoids FileImage cache of card_front.jpg).
                if (_isFromTemplate)
                  _buildLivePreviewCard()
                else ...[
                  if (_imageBytes.isNotEmpty)
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
                                key: ValueKey('scan-images-$_imageEpoch'),
                                controller: _scanImagePageController,
                                itemCount: _imageBytes.length,
                                onPageChanged: (i) =>
                                    setState(() => _imagePageIndex = i),
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemBuilder: (_, index) {
                                  return Image.memory(
                                    _imageBytes[index],
                                    key: ValueKey(
                                      'scan-$_imageEpoch-$index-${_imageBytes[index].length}',
                                    ),
                                    fit: BoxFit.contain,
                                    gaplessPlayback: false,
                                  );
                                },
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
                              onTap: _isDownloadingScan ||
                                      _isDownloadingTemplate
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
                                    color:
                                        ui.Colors.parentIconSelectTextColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12.h),
                  _buildLivePreviewCard(),
                ],
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
                        onTap: _openEdit,
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
                if (contact != null)
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
                        ...contact.phones
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactRow(
                                icon: ui.AppAssets.visitingTemplatePhoneIcon,
                                value: e.value,
                                subtitle: e.type.isEmpty ? 'Tel' : e.type,
                                onTap: () => _onCall(e.value),
                              ),
                            ),
                        ...contact.emails
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactRow(
                                icon: ui.AppAssets.visitingTemplateMailIcon,
                                value: e.value,
                                subtitle: e.type.isEmpty ? 'Email' : e.type,
                                onTap: () => _onOpenEmail(e.value),
                              ),
                            ),
                        ...contact.websites
                            .where((e) => e.value.trim().isNotEmpty)
                            .map(
                              (e) => _ContactRow(
                                icon:
                                    ui.AppAssets.visitingTemplateWebsiteIcon,
                                value: e.value,
                                subtitle:
                                    e.type.isEmpty ? 'Company' : e.type,
                                onTap: () => _onOpenWebsite(e.value),
                              ),
                            ),
                        ...contact.addresses
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (e) => _ContactRow(
                                icon:
                                    ui.AppAssets.visitingTemplateLocationIcon,
                                value: e,
                                subtitle: 'Address',
                                onTap: () => _onOpenMap(e),
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
