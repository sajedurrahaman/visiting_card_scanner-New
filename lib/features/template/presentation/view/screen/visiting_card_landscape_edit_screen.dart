import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';
import 'package:visiting_card/features/scan/presentation/helper/visiting_card_share_helper.dart';
import 'package:visiting_card/features/template/domain/visiting_card_export_utils.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_rename_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_logo_picker_screen.dart';
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
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VisitingCardLandscapeEditScreen(
            persistToRecent: persistToRecent,
          ),
        ),
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VisitingCardEditContactViewModel>().clearOverlaySelection();
      _finishBoot();
    });
  }

  Future<void> _finishBoot() async {
    // Keep loader visible a few seconds while orientation + template settle.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    setState(() => _booting = false);
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
    Navigator.pop(context);
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
      Navigator.pop(context, true);
      return;
    }

    setState(() => _busy = true);
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
      Navigator.pop(context, true);
      return;
    }

    await VisitingCardShareHelper.saveContactToPhone(context, phoneContact);
    if (!mounted) return;
    context.read<ParentViewModel>().changeIndex(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onDownload() async {
    if (_isDownloading || _busy) return;
    setState(() => _isDownloading = true);

    final vm = context.read<VisitingCardEditContactViewModel>();
    final previous = vm.sideIndex;

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      final frontBytes = await _captureSide(vm, 0);
      final backBytes = await _captureSide(vm, 1);
      if (!mounted) return;
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
      vm.setSide(previous);
      ui.AppToast.show(context, message: 'Failed to download visiting card');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _onPickLogo() async {
    final file = await VisitingCardLogoPickerScreen.open(context);
    if (file == null || !mounted) return;
    final vm = context.read<VisitingCardEditContactViewModel>();
    final path = await vm.persistLogoFile(file);
    vm.applyLogoImage(path);
  }

  Future<void> _onPickImage() async {
    final file = await VisitingCardLogoPickerScreen.open(context);
    if (file == null || !mounted) return;
    final vm = context.read<VisitingCardEditContactViewModel>();
    final path = await vm.persistLogoFile(file);
    vm.applyLogoImage(path);
  }

  void _comingSoon(String label) {
    ui.AppToast.show(context, message: '$label coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    final size = MediaQuery.sizeOf(context);
    final shortest = math.min(size.width, size.height);

    final railWidth = (size.width * 0.24).clamp(148.0, 188.0);
    final pad = (shortest * 0.04).clamp(12.0, 20.0);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(pad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final ratio = vm.isHorizontal ? 1.75 : 0.63;
                        const scale = 0.80;
                        var cardW = constraints.maxWidth * scale;
                        var cardH = cardW / ratio;
                        final maxH = constraints.maxHeight * 0.84;
                        if (cardH > maxH) {
                          cardH = maxH;
                          cardW = cardH * ratio;
                        }
                        // Landscape card fonts scale from card width inside
                        // LivePreview — do not apply ScreenUtil / textScaler.
                        return Column(
                          children: [
                            SizedBox(height: pad * 1.00),
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
                                        enableFieldTransform: true,
                                        selectionBorderOnlyWhenSelected: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: pad * 0.75),
                  SizedBox(
                    width: railWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopTools(
                          onUndo: () => _comingSoon('Undo'),
                          onRedo: () => _comingSoon('Redo'),
                          onExit: _onExit,
                          canUndo: false,
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
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _RailItem(
                                  icon: Icons.save_outlined,
                                  label: 'Save',
                                  onTap: _onSave,
                                ),
                                _RailItem(
                                  icon: Icons.download_outlined,
                                  label: 'Download',
                                  onTap: _onDownload,
                                ),
                                _RailItem(
                                  icon: Icons.playlist_add_outlined,
                                  label: 'Text',
                                  onTap: () => _comingSoon('Text'),
                                ),
                                _RailItem(
                                  icon: Icons.widgets_outlined,
                                  label: 'Icon',
                                  onTap: () => _comingSoon('Icon'),
                                ),
                                _RailItem(
                                  icon: Icons.category_outlined,
                                  label: 'Shape',
                                  onTap: () => _comingSoon('Shape'),
                                ),
                                _RailItem(
                                  icon: Icons.hexagon_outlined,
                                  label: 'Logos',
                                  onTap: _onPickLogo,
                                ),
                                _RailItem(
                                  icon: Icons.add_photo_alternate_outlined,
                                  label: 'Images',
                                  onTap: _onPickImage,
                                ),
                                _RailItem(
                                  icon: Icons.dashboard_outlined,
                                  label: 'Template',
                                  onTap: () => _comingSoon('Template'),
                                ),
                                _RailItem(
                                  icon: Icons.visibility_outlined,
                                  label: 'Preview',
                                  onTap: () {
                                    vm.setSide(0);
                                    ui.AppToast.show(
                                      context,
                                      message: 'Showing front preview',
                                    );
                                  },
                                ),
                                _RailItem(
                                  icon: Icons.person_outline,
                                  label: 'Profile',
                                  onTap: () => _comingSoon('Profile'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_booting)
              const Positioned.fill(
                child: ColoredBox(
                  color: _bg,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF05B560),
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Loading card…',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onExit;
  final bool canUndo;

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
        _ToolIcon(icon: Icons.redo_rounded, onTap: onRedo),
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
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
                Icon(icon, color: Colors.white, size: 17),
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
