import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_payload.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_edit_text_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_icon_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_logo_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_profile_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_shape_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_font_style_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_template_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_rename_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_tempalte_qrcode_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Figma landscape card editor: canvas + right tool rail.
///
/// Avoids ScreenUtil (.w/.h/.sp) — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeEditScreen extends StatefulWidget {
  const VisitingCardLandscapeEditScreen({
    super.key,
    this.persistToRecent = true,
  });

  /// When false (scan create flow), Save only applies name + pops — parent
  /// screen owns the final folder/recent save.
  final bool persistToRecent;

  static Future<bool?> open(
    BuildContext context, {
    required VisitingCardEditContactViewModel vm,
    bool persistToRecent = true,
  }) {
    return Navigator.push<bool>(
      context,
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => ChangeNotifierProvider.value(
          value: vm,
          child: VisitingCardLandscapeEditScreen(
            persistToRecent: persistToRecent,
          ),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<VisitingCardLandscapeEditScreen> createState() =>
      _VisitingCardLandscapeEditScreenState();
}

class _VisitingCardLandscapeEditScreenState
    extends State<VisitingCardLandscapeEditScreen> {
  static const _bg = Color(0xFF003303);
  static const _itemFill = Color(0xFF0A3D0A);
  static const _itemBorder = Color(0xFF2E6B2E);

  final GlobalKey _cardCaptureKey = GlobalKey();
  bool _isDownloading = false;
  bool _busy = false;
  bool _booting = true;
  bool _previewing = false;
  bool _leaving = false;
  bool _allowPop = false;
  String _panel = '';
  String _panelSelection = '';

  void _syncPanel(VisitingCardEditContactViewModel vm) {
    final selection =
        vm.selectedDuplicateId ?? vm.selectedOverlay?.name ?? '';
    if (selection == _panelSelection) return;
    _panelSelection = selection;
    _panel = '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (!mounted) return;
      context.read<VisitingCardEditContactViewModel>().clearOverlaySelection();
      context.read<VisitingCardEditContactViewModel>().beginUndoHistory();
      await _finishBoot();
    });
  }

  Future<void> _waitUntil({required bool landscape}) async {
    final deadline = DateTime.now().add(const Duration(milliseconds: 1600));
    while (DateTime.now().isBefore(deadline)) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      final ready = landscape
          ? size.width > size.height + 24
          : size.height > size.width + 24;
      if (ready) return;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> _finishBoot() async {
    await _waitUntil(landscape: true);
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    setState(() => _booting = false);
  }

  /// Cover the editor, rotate back to portrait, then reveal the previous page.
  Future<void> _leaveToPortrait({Object? result, bool toRoot = false}) async {
    if (_leaving) return;
    _leaving = true;
    if (mounted) setState(() => _booting = true);
    await WidgetsBinding.instance.endOfFrame;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _waitUntil(landscape: false);
    if (!mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (toRoot) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<Uint8List?> _captureSide(
    VisitingCardEditContactViewModel vm,
    int side,
  ) async {
    vm.jumpSideForCapture = true;
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

  Future<void> _onExit() async {
    if (_busy) return;
    await _leaveToPortrait();
  }

  Future<void> _onSave() async {
    if (_busy) return;
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (vm.isSaving) return;

    final initial = vm.names.isNotEmpty ? vm.names.first.value.trim() : '';
    final newName = await VisitingCardLandscapeRenameScreen.open(
      context,
      initialValue: initial.isEmpty ? 'Visiting Card' : initial,
      hintText: 'Visiting Card',
    );
    if (newName == null || !mounted) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      ui.AppToast.show(context, message: 'Name cannot be empty');
      return;
    }

    if (vm.names.isNotEmpty) {
      vm.updateSimpleField(vm.names, 0, trimmed);
    }

    if (!widget.persistToRecent) {
      ui.AppToast.success(context, 'Name updated');
      await _leaveToPortrait(result: true);
      return;
    }

    setState(() => _busy = true);
    final home = context.read<HomeViewModel>();
    final folder = context.read<FolderViewModel>();
    final previous = vm.sideIndex;
    final isUpdate = vm.isUpdatingExisting;
    final phoneContact = vm.buildSavedContact();

    vm.jumpSideForCapture = true;
    final ok = await vm.saveCard(
      homeViewModel: home,
      folderViewModel: folder,
      captureSide: (side) => _captureSide(vm, side),
    );
    vm.jumpSideForCapture = false;
    if (!mounted) return;
    vm.setSide(previous);
    setState(() => _busy = false);

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
      await _leaveToPortrait(result: true);
      return;
    }

    await VisitingCardShareHelper.saveContactToPhone(context, phoneContact);
    if (!mounted) return;
    context.read<ParentViewModel>().changeIndex(0);
    await _leaveToPortrait(toRoot: true);
  }

  Future<void> _onDownload() async {
    if (_isDownloading || _busy) return;
    setState(() => _isDownloading = true);

    final vm = context.read<VisitingCardEditContactViewModel>();
    final previous = vm.sideIndex;
    vm.jumpSideForCapture = true;

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      final frontBytes = await _captureSide(vm, 0);
      final backBytes = await _captureSide(vm, 1);
      if (!mounted) return;
      vm.jumpSideForCapture = false;
      vm.setSide(previous);

      if (frontBytes == null || backBytes == null) {
        ui.AppToast.show(context, message: 'Failed to download visiting card');
        return;
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final frontFile = File(
        '${Directory.systemTemp.path}/vc_land_front_$stamp.png',
      );
      final backFile = File(
        '${Directory.systemTemp.path}/vc_land_back_$stamp.png',
      );
      await frontFile.writeAsBytes(frontBytes, flush: true);
      await backFile.writeAsBytes(backBytes, flush: true);
      await Gal.putImage(frontFile.path, album: 'Visiting Card');
      await Gal.putImage(backFile.path, album: 'Visiting Card');

      if (!mounted) return;
      ui.AppToast.success(context, 'Downloaded to gallery');
    } catch (_) {
      if (!mounted) return;
      vm.jumpSideForCapture = false;
      vm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to download visiting card');
    } finally {
      vm.jumpSideForCapture = false;
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _onPickLogo() {
    return VisitingCardLandscapeLogoScreen.open(context);
  }

  /// Opens QR Template (portrait ScreenUtil screen), then places / replaces QR
  /// like Logos: selected QR → replace; unselected → add new QR on the card.
  Future<void> _onPickQr() async {
    if (_busy || _booting) return;
    final vm = context.read<VisitingCardEditContactViewModel>();
    final alreadyPortrait =
        MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width;

    setState(() => _booting = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!alreadyPortrait) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _waitUntil(landscape: false);
      if (!mounted) return;
    }

    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardTempalteQrcodeScreen(
          qrData: VisitingCardQrPayload.fromEditContact(vm),
        ),
      ),
    );

    if (!mounted) return;
    if (!alreadyPortrait) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await _waitUntil(landscape: true);
      if (!mounted) return;
    }
    setState(() => _booting = false);

    if (path == null || path.isEmpty) return;
    var resolved = path;
    if (!path.startsWith('assets/')) {
      resolved = await vm.persistQrFile(File(path));
      if (!mounted) return;
    }
    vm.placeQr(resolved);
  }

  Future<void> _onPickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    final vm = context.read<VisitingCardEditContactViewModel>();
    final path = await vm.persistLogoFile(File(picked.path));
    if (!mounted) return;
    vm.addCustomImage(path);
  }

  void _onPreview() {
    final vm = context.read<VisitingCardEditContactViewModel>();
    vm.clearOverlaySelection();
    vm.setSide(0);
    setState(() {
      _panel = '';
      _previewing = true;
    });
  }

  void _closePreview() {
    setState(() => _previewing = false);
  }

  Future<void> _onAddIcon() {
    return VisitingCardLandscapeIconScreen.open(context);
  }

  Future<void> _onAddShape() {
    return VisitingCardLandscapeShapeScreen.open(context);
  }

  Future<void> _onProfile() {
    return VisitingCardLandscapeProfileScreen.open(context);
  }

  Future<void> _onAddText() async {
    final next = await VisitingCardLandscapeEditTextScreen.open(
      context,
      initialValue: '',
    );
    if (next == null || next.isEmpty || !mounted) return;
    context.read<VisitingCardEditContactViewModel>().addCustomText(next);
  }

  Future<void> _onEditText() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (!vm.hasSelection || vm.selectedIsImage) {
      if (vm.selectedIsImage) {
        ui.AppToast.show(context, message: 'This field has no text');
      }
      return;
    }
    final field = vm.selectedOverlay ?? VisitingCardOverlayField.name;
    final next = await VisitingCardLandscapeEditTextScreen.open(
      context,
      initialValue: vm.selectedDuplicateId == null
          ? vm.overlayText(field)
          : vm.currentOverlays[VisitingCardEditContactViewModel.duplicateKey(
                vm.selectedDuplicateId!,
              )]
                  ?.duplicateText ??
              '',
    );
    if (next == null || !mounted) return;
    vm.setOverlayText(field, next);
  }

  void _togglePanel(String name) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (!vm.hasSelection) return;
    const textOnly = {'Color', 'Spacing', 'Stroke', 'Shadow'};
    final shapeColor = name == 'Color' && vm.selectedIsShape;
    if (textOnly.contains(name) && vm.selectedIsImage && !shapeColor) {
      ui.AppToast.show(context, message: 'Applies to text');
      return;
    }
    setState(() => _panel = _panel == name ? '' : name);
  }

  void _onColor() => _togglePanel('Color');

  void _onSize() => _togglePanel('Size');

  Future<void> _onFontStyle() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (!vm.hasSelection || vm.selectedIsImage) {
      if (vm.selectedIsImage) {
        ui.AppToast.show(context, message: 'Applies to text');
      }
      return;
    }
    await VisitingCardLandscapeFontStyleScreen.open(context);
  }

  void _onDelete() {
    context.read<VisitingCardEditContactViewModel>().deleteSelectedOverlay();
    setState(() => _panel = '');
  }

  void _onDuplicate() {
    context.read<VisitingCardEditContactViewModel>().duplicateSelectedOverlay();
  }

  void _onLock() {
    context.read<VisitingCardEditContactViewModel>().toggleSelectedOverlayLock();
  }

  bool get _isAdjustPanel =>
      _panel == 'Rotate' ||
      _panel == 'Opacity' ||
      _panel == 'Stroke' ||
      _panel == 'Spacing' ||
      _panel == 'Shadow';

  Future<void> _pickEffectColor(String tool) async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    final current = vm.activeTransform;
    if (current == null) return;
    final initial = tool == 'Stroke'
        ? (current.strokeColor ?? const Color(0xFF000000))
        : (current.shadowColor ?? const Color(0xFF000000));
    final chosen = await _chooseColor(initial);
    if (chosen == null || !mounted) return;
    if (tool == 'Stroke') {
      vm.setSelectedStrokeColor(chosen);
    } else {
      vm.setSelectedShadowColor(chosen);
    }
  }

  Future<void> _pickCustomColor() async {
    final vm = context.read<VisitingCardEditContactViewModel>();
    final current = vm.activeTransform;
    if (current == null) return;
    final chosen = await _chooseColor(
      current.textColor ?? const Color(0xFF1A1A1A),
    );
    if (chosen == null || !mounted) return;
    vm.setSelectedOverlayColor(chosen);
  }

  Future<Color?> _chooseColor(Color initial) {
    var picked = initial;
    return showDialog<Color>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) {
        final viewHeight = MediaQuery.sizeOf(dialogContext).height;
        final ring = (viewHeight * 0.62).clamp(160.0, 240.0);
        return Dialog(
          backgroundColor: const Color(0xFF003303),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LandscapeHueRing(
                      color: picked,
                      size: ring,
                      onChanged: (color) {
                        setDialogState(() => picked = color);
                      },
                    ),
                    const SizedBox(width: 18),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: picked,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x66FFFFFF)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ColorPickerButton(
                          label: 'Apply',
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF3DCB6A),
                              Color(0xFF0B5D2A),
                            ],
                          ),
                          onTap: () => Navigator.pop(dialogContext, picked),
                        ),
                        const SizedBox(height: 10),
                        _ColorPickerButton(
                          label: 'Cancel',
                          color: const Color(0xFFE53935),
                          onTap: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    _syncPanel(vm);
    final size = MediaQuery.sizeOf(context);
    final shortest = math.min(size.width, size.height);

    final railWidth = (size.width * 0.24).clamp(148.0, 188.0);
    final pad = (shortest * 0.04).clamp(12.0, 20.0);

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _leaving) return;
        _onExit();
      },
      child: Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final ratio = vm.isHorizontal ? 1.75 : 0.63;
                        final scale = _previewing ? 0.82 : 0.68;
                        final topGap = _previewing ? 0.0 : pad;
                        // Pager plus the gap under the card. Kept out of the
                        // card budget so the column cannot overflow.
                        const belowCard = 56.0;
                        final room = math.max(
                          40.0,
                          constraints.maxHeight - topGap - belowCard,
                        );
                        var cardW = constraints.maxWidth * scale;
                        var cardH = cardW / ratio;
                        final maxH = math.min(
                          constraints.maxHeight * (_previewing ? 0.82 : 0.70),
                          room,
                        );
                        if (cardH > maxH) {
                          cardH = maxH;
                          cardW = cardH * ratio;
                        }
                        // Landscape card fonts scale from card width inside
                        // LivePreview — do not apply ScreenUtil / textScaler.
                        return Column(
                          children: [
                            if (_previewing) const Spacer(),
                            if (!_previewing) SizedBox(height: pad),
                            Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: cardW,
                                height: cardH,
                                child: Opacity(
                                  opacity: _booting ? 0 : 1,
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      textScaler: TextScaler.noScaling,
                                    ),
                                    child: RepaintBoundary(
                                      key: _cardCaptureKey,
                                      child: VisitingCardLivePreview(
                                        vm: vm,
                                        showPager: false,
                                        enableFieldTransform: !_previewing,
                                        selectionBorderOnlyWhenSelected: true,
                                        pageGap: 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Opacity(
                              opacity: _booting ? 0 : 1,
                              child: _LandscapeSidePager(
                                currentPage: vm.sideIndex + 1,
                                canGoPrevious: vm.sideIndex == 1,
                                canGoNext: vm.sideIndex == 0,
                                onPrevious: vm.showFront,
                                onNext: vm.showBack,
                              ),
                            ),
                            const Spacer(),
                            if (!_previewing &&
                                _panel == 'Color' &&
                                vm.hasSelection &&
                                (!vm.selectedIsImage || vm.selectedIsShape))
                              _TextColorBar(
                                selected: vm.activeTransform?.textColor,
                                onClose: () => setState(() => _panel = ''),
                                onPick: vm.setSelectedOverlayColor,
                                onCustom: _pickCustomColor,
                              )
                            else if (!_previewing &&
                                _panel == 'Size' &&
                                vm.hasSelection)
                              _TextSizeBar(
                                fraction: vm.selectedOverlaySizeFraction(),
                                onClose: () => setState(() => _panel = ''),
                                onChanged: vm.setSelectedOverlaySizeFraction,
                              )
                            else if (!_previewing &&
                                _isAdjustPanel &&
                                vm.hasSelection &&
                                !(vm.selectedIsImage &&
                                    (_panel == 'Spacing' ||
                                        _panel == 'Stroke' ||
                                        _panel == 'Shadow')))
                              _AdjustBar(
                                label: _panel,
                                fraction: vm.selectedAdjustFraction(_panel),
                                showColorPicker: _panel == 'Stroke' ||
                                    _panel == 'Shadow',
                                onClose: () => setState(() => _panel = ''),
                                onChanged: (value) =>
                                    vm.setSelectedAdjustFraction(_panel, value),
                                onPickColor: _panel == 'Stroke' ||
                                        _panel == 'Shadow'
                                    ? () => _pickEffectColor(_panel)
                                    : null,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (!_previewing) SizedBox(width: pad * 0.75),
                  if (!_previewing)
                    SizedBox(
                    width: railWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopTools(
                          onUndo: vm.undo,
                          onRedo: vm.redo,
                          onExit: _onExit,
                          canUndo: vm.canUndo,
                          canRedo: vm.canRedo,
                        ),
                        SizedBox(height: pad * 0.5),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF015719),
                                  Color(0xFF003F14),
                                  Color(0xFF003516),
                                ],
                              ),
                            ),
                            child: !vm.hasSelection
                                ? ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/save_option_icon.svg',
                                        label: 'Save',
                                        onTap: _onSave,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/download_option_icon.svg',
                                        label: 'Download',
                                        onTap: _onDownload,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/text_option_icon.svg',
                                        label: 'Text',
                                        onTap: _onAddText,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/icon_option_icon.svg',
                                        label: 'Icon',
                                        onTap: _onAddIcon,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/shape_option-icon.svg',
                                        label: 'Shape',
                                        onTap: _onAddShape,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/logo_option_icon.svg',
                                        label: 'Logos',
                                        onTap: _onPickLogo,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/qrcode_option_icon.svg',
                                        label: 'QR Code',
                                        onTap: _onPickQr,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/image_option_icon.svg',
                                        label: 'Images',
                                        onTap: _onPickImage,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/template_option_icon.svg',
                                        label: 'Template',
                                        onTap: () =>
                                            VisitingCardLandscapeTemplateScreen
                                                .open(context),
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/preview_option_icon.svg',
                                        label: 'Preview',
                                        onTap: _onPreview,
                                      ),
                                      _RailItem(
                                        asset:
                                            'assets/visiting_card_option_icon/profile_option_icon.svg',
                                        label: 'Profile',
                                        onTap: _onProfile,
                                      ),
                                    ],
                                  )
                                : _SelectedFieldRail(
                                    showTextTools: !vm.selectedIsImage,
                                    showColor:
                                        !vm.selectedIsImage || vm.selectedIsShape,
                                    onReplaceLogo: vm.selectedIsLogo
                                        ? _onPickLogo
                                        : null,
                                    onReplaceQr:
                                        vm.selectedIsQr ? _onPickQr : null,
                                    onEditText: _onEditText,
                                    onColor: _onColor,
                                    colorActive: _panel == 'Color',
                                    onSize: _onSize,
                                    sizeActive: _panel == 'Size',
                                    onFontStyle: _onFontStyle,
                                    onDelete: _onDelete,
                                    onDuplicate: _onDuplicate,
                                    onSendBack: vm.sendSelectedOverlayBack,
                                    onSendFront: vm.sendSelectedOverlayFront,
                                    onLock: _onLock,
                                    locked: vm.selectedIsLocked,
                                    onPanel: _togglePanel,
                                    activePanel: _panel,
                                    onClose: () {
                                      setState(() => _panel = '');
                                      vm.clearOverlaySelection();
                                    },
                                    onNudge: vm.nudgeSelectedOverlay,
                                    onFlip: (horizontal) => vm.flipSelectedOverlay(
                                      horizontal: horizontal,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_previewing && !_booting)
              Positioned(
                top: 16,
                right: pad + 18,
                child: Material(
                  color: const Color(0xFFFFFFFF),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _closePreview,
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF000000),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            if (_booting)
              const Positioned.fill(
                child: ColoredBox(color: _bg),
              ),
            if (!_booting && (_busy || _isDownloading || vm.isSaving))
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x59000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ui.Colors.parentIconSelectTextColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LandscapeSidePager extends StatelessWidget {
  const _LandscapeSidePager({
    required this.currentPage,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PagerArrow(
          icon: Icons.chevron_left_rounded,
          enabled: canGoPrevious,
          onTap: onPrevious,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            '$currentPage/2',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        _PagerArrow(
          icon: Icons.chevron_right_rounded,
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PagerArrow extends StatelessWidget {
  const _PagerArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? const Color(0xFF1A1A1A) : Colors.black26,
          ),
        ),
      ),
    );
  }
}

class _TopTools extends StatelessWidget {
  const _TopTools({
    required this.onUndo,
    required this.onRedo,
    required this.onExit,
    this.canUndo = true,
    this.canRedo = true,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onExit;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ToolIcon(
          icon: Icons.undo_rounded,
          onTap: canUndo ? onUndo : null,
          enabled: canUndo,
        ),
        const SizedBox(width: 10),
        _ToolIcon(
          icon: Icons.redo_rounded,
          onTap: canRedo ? onRedo : null,
          enabled: canRedo,
        ),
        const SizedBox(width: 10),
        _ToolIcon(icon: Icons.logout_rounded, onTap: onExit),
      ],
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 22,
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: _VisitingCardLandscapeEditScreenState._itemFill,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _VisitingCardLandscapeEditScreenState._itemBorder,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(asset, width: 17, height: 17),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _selectIconDir = 'assets/visiting_card_select_text_icon';

/// Right rail shown while a card field is selected (Figma text tools).
class _SelectedFieldRail extends StatelessWidget {
  const _SelectedFieldRail({
    required this.showTextTools,
    required this.showColor,
    required this.onReplaceLogo,
    required this.onReplaceQr,
    required this.onEditText,
    required this.onColor,
    required this.colorActive,
    required this.onSize,
    required this.sizeActive,
    required this.onFontStyle,
    required this.onDelete,
    required this.onDuplicate,
    required this.onSendBack,
    required this.onSendFront,
    required this.onLock,
    required this.locked,
    required this.onPanel,
    required this.activePanel,
    required this.onClose,
    required this.onNudge,
    required this.onFlip,
  });

  final bool showTextTools;
  final bool showColor;
  final VoidCallback? onReplaceLogo;
  final VoidCallback? onReplaceQr;
  final VoidCallback onEditText;
  final VoidCallback onColor;
  final bool colorActive;
  final VoidCallback onSize;
  final bool sizeActive;
  final VoidCallback onFontStyle;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onSendBack;
  final VoidCallback onSendFront;
  final VoidCallback onLock;
  final bool locked;
  final void Function(String name) onPanel;
  final String activePanel;
  final VoidCallback onClose;
  final void Function(double dxFraction, double dyFraction) onNudge;
  final void Function(bool horizontal) onFlip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (onReplaceLogo != null)
          _SelectRailItem(
            asset: 'assets/visiting_card_option_icon/logo_option_icon.svg',
            label: 'Replace logo',
            onTap: onReplaceLogo!,
          ),
        if (onReplaceQr != null)
          _SelectRailItem(
            asset: 'assets/visiting_card_option_icon/qrcode_option_icon.svg',
            label: 'Replace QRCode',
            onTap: onReplaceQr!,
          ),
        if (showTextTools)
          _SelectRailItem(
            asset: '$_selectIconDir/edit_text_icon.svg',
            label: 'Edit Text',
            onTap: onEditText,
          ),
        if (showColor)
          _SelectRailItem(
            asset: '$_selectIconDir/color_icon.svg',
            label: 'Color',
            highlighted: colorActive,
            onTap: onColor,
          ),
        _SelectRailItem(
          asset: '$_selectIconDir/font_size_icon.svg',
          label: 'Size',
          highlighted: sizeActive,
          onTap: onSize,
        ),
        if (showTextTools)
          _SelectRailItem(
            asset: '$_selectIconDir/font_style_icon.svg',
            label: 'Font style',
            onTap: onFontStyle,
          ),
        _SelectRailItem(
          asset: '$_selectIconDir/rotate_icon.svg',
          label: 'Rotate',
          highlighted: activePanel == 'Rotate',
          onTap: () => onPanel('Rotate'),
        ),
        _SelectRailItem(
          asset: '$_selectIconDir/opacity_icon.svg',
          label: 'Opacity',
          highlighted: activePanel == 'Opacity',
          onTap: () => onPanel('Opacity'),
        ),
        _MoveAndFlipCard(onNudge: onNudge, onFlip: onFlip),
        if (showTextTools)
          _SelectRailItem(
            asset: '$_selectIconDir/stoke_icon.svg',
            label: 'Stroke',
            highlighted: activePanel == 'Stroke',
            onTap: () => onPanel('Stroke'),
          ),
        if (showTextTools)
          _SelectRailItem(
            asset: '$_selectIconDir/spacing_icon.svg',
            label: 'Spacing',
            highlighted: activePanel == 'Spacing',
            onTap: () => onPanel('Spacing'),
          ),
        if (showTextTools)
          _SelectRailItem(
            asset: '$_selectIconDir/shadow_icon.svg',
            label: 'Shadow',
            highlighted: activePanel == 'Shadow',
            onTap: () => onPanel('Shadow'),
          ),
        _SelectRailItem(
          asset: '$_selectIconDir/delete_icon.svg',
          label: 'Delete',
          onTap: onDelete,
        ),
        _SelectRailItem(
          asset: '$_selectIconDir/send_back_icon.svg',
          label: 'Send Back',
          onTap: onSendBack,
        ),
        _SelectRailItem(
          asset: '$_selectIconDir/send_front_icon.svg',
          label: 'Bring Front',
          onTap: onSendFront,
        ),
        _SelectRailItem(
          asset: '$_selectIconDir/duplicate_icon.svg',
          label: 'Duplicate',
          onTap: onDuplicate,
        ),
        _SelectRailItem(
          asset: '$_selectIconDir/close_icon.svg',
          label: 'Close',
          onTap: onClose,
        ),
        _SelectRailItem(
          asset: locked
              ? '$_selectIconDir/unlock_icon.svg'
              : '$_selectIconDir/lock_icon.svg',
          label: locked ? 'Unlock' : 'Lock',
          onTap: onLock,
        ),
      ],
    );
  }
}

class _SelectRailItem extends StatelessWidget {
  const _SelectRailItem({
    required this.asset,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
        child: Material(
        color: highlighted
            ? const Color(0x00000000)
            : _VisitingCardLandscapeEditScreenState._itemFill,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: highlighted
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF00973D),
                        Color(0xFF008825),
                      ],
                    )
                  : null,
              border: highlighted
                  ? null
                  : Border.all(
                      color: _VisitingCardLandscapeEditScreenState._itemBorder,
                    ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(asset, width: 16, height: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveAndFlipCard extends StatelessWidget {
  const _MoveAndFlipCard({
    required this.onNudge,
    required this.onFlip,
  });

  final void Function(double dxFraction, double dyFraction) onNudge;
  final void Function(bool horizontal) onFlip;

  static const _step = 0.008;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        decoration: BoxDecoration(
          color: _VisitingCardLandscapeEditScreenState._itemFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _VisitingCardLandscapeEditScreenState._itemBorder,
          ),
        ),
        child: Column(
          children: [
            _NudgeArrow(
              Icons.keyboard_arrow_up_rounded,
              onTap: () => onNudge(0, -_step),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NudgeArrow(
                  Icons.keyboard_arrow_left_rounded,
                  onTap: () => onNudge(-_step, 0),
                ),
                const SizedBox(width: 36),
                _NudgeArrow(
                  Icons.keyboard_arrow_right_rounded,
                  onTap: () => onNudge(_step, 0),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _NudgeArrow(
              Icons.keyboard_arrow_down_rounded,
              onTap: () => onNudge(0, _step),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AxisChip(
                    asset: '$_selectIconDir/horizontal_icon.svg',
                    label: 'Horizontal',
                    onTap: () => onFlip(true),
                  ),
                ),
                Expanded(
                  child: _AxisChip(
                    asset: '$_selectIconDir/vertical_icon.svg',
                    label: 'Vertical',
                    onTap: () => onFlip(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NudgeArrow extends StatelessWidget {
  const _NudgeArrow(this.icon, {required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _AxisChip extends StatelessWidget {
  const _AxisChip({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(asset, width: 16, height: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _textSwatches = <Color>[
  Color(0xFF000000),
  Color(0xFFFFFFFF),
  Color(0xFFBCBCBC),
  Color(0xFFFF222B),
  Color(0xFF5EFF3B),
  Color(0xFF115BED),
  Color(0xFF009EEF),
  Color(0xFF00B3CD),
  Color(0xFF00AF24),
  Color(0xFFFFBA30),
  Color(0xFFFFE94B),
];

class _TextColorBar extends StatelessWidget {
  const _TextColorBar({
    required this.selected,
    required this.onClose,
    required this.onPick,
    required this.onCustom,
  });

  final Color? selected;
  final VoidCallback onClose;
  final ValueChanged<Color> onPick;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[
      _ColorDot(
        fill: Colors.white,
        onTap: onClose,
        child: const Icon(Icons.close, size: 16, color: Color(0xFF1A1A1A)),
      ),
      _ColorDot(
        fill: const Color(0x00000000),
        onTap: onCustom,
        child: const Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFFF3B30),
                    Color(0xFFFFE14A),
                    Color(0xFF34C759),
                    Color(0xFF00C2FF),
                    Color(0xFF2F80ED),
                    Color(0xFF9C27B0),
                    Color(0xFFFF3B30),
                  ],
                ),
              ),
              child: SizedBox.expand(),
            ),
            Icon(Icons.colorize, size: 15, color: Colors.white),
          ],
        ),
      ),
      for (final color in _textSwatches)
        _ColorDot(
          fill: color,
          selected: selected?.toARGB32() == color.toARGB32(),
          onTap: () => onPick(color),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00330C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dots,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TextSizeBar extends StatelessWidget {
  const _TextSizeBar({
    required this.fraction,
    required this.onClose,
    required this.onChanged,
  });

  final double fraction;
  final VoidCallback onClose;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (fraction.clamp(0.0, 1.0) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF00330C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Size',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.white,
                  thumbColor: const Color(0xFF11B342),
                  overlayColor: const Color(0x3311B342),
                  trackHeight: 6,
                  trackShape: const _SizeSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: fraction.clamp(0.0, 1.0),
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(
                '$percent%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustBar extends StatelessWidget {
  const _AdjustBar({
    required this.label,
    required this.fraction,
    required this.onClose,
    required this.onChanged,
    this.showColorPicker = false,
    this.onPickColor,
  });

  final String label;
  final double fraction;
  final VoidCallback onClose;
  final ValueChanged<double> onChanged;
  final bool showColorPicker;
  final VoidCallback? onPickColor;

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);
    final isRotate = label == 'Rotate';
    final valueLabel = isRotate
        ? '${(clamped * 360).round()}°'
        : '${(clamped * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF00330C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (showColorPicker) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onPickColor,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFFFF3B30),
                        Color(0xFFFFE14A),
                        Color(0xFF34C759),
                        Color(0xFF00C2FF),
                        Color(0xFF2F80ED),
                        Color(0xFF9C27B0),
                        Color(0xFFFF3B30),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.colorize,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.white,
                  thumbColor: const Color(0xFF11B342),
                  overlayColor: const Color(0x3311B342),
                  trackHeight: 6,
                  trackShape: const _SizeSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: clamped,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: isRotate ? 48 : 42,
              child: Text(
                valueLabel,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _SizeSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final radius = Radius.circular(trackRect.height / 2);
    final canvas = context.canvas;
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      Paint()..color = sliderTheme.inactiveTrackColor ?? const Color(0xFFFFFFFF),
    );

    final ltr = textDirection == TextDirection.ltr;
    final active = Rect.fromLTRB(
      ltr ? trackRect.left : thumbCenter.dx,
      trackRect.top,
      ltr ? thumbCenter.dx : trackRect.right,
      trackRect.bottom,
    );
    if (active.width <= 0) return;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(active, radius));
    canvas.drawRect(
      trackRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF11B342), Color(0xFF016C31)],
        ).createShader(trackRect),
    );
    canvas.restore();
  }
}

class _LandscapeHueRing extends StatefulWidget {
  const _LandscapeHueRing({
    required this.color,
    required this.onChanged,
    required this.size,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final double size;

  @override
  State<_LandscapeHueRing> createState() => _LandscapeHueRingState();
}

class _LandscapeHueRingState extends State<_LandscapeHueRing> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.color);
  }

  void _update(HSVColor next) {
    setState(() => _hsv = next);
    widget.onChanged(next.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.size / 1.7;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ColorPickerHueRing(
              _hsv,
              _update,
              displayThumbColor: true,
              strokeWidth: 22,
            ),
          ),
          SizedBox(
            width: inner,
            height: inner,
            child: ColorPickerArea(_hsv, _update, PaletteType.hsv),
          ),
        ],
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  const _ColorPickerButton({
    required this.label,
    required this.onTap,
    this.color,
    this.gradient,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 108,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.fill,
    required this.onTap,
    this.selected = false,
    this.child,
  });

  final Color fill;
  final VoidCallback onTap;
  final bool selected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF008839) : const Color(0x00000000),
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}
