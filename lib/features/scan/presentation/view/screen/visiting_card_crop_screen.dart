import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:visiting_card/app/helper/ui_helper.dart' as app_ui;

const _cropActiveColor = Color(0xFF05B560);

class VisitingCardCropScreen extends StatefulWidget {
  const VisitingCardCropScreen({
    super.key,
    required this.imageBytes,
  });

  final Uint8List imageBytes;

  @override
  State<VisitingCardCropScreen> createState() => _VisitingCardCropScreenState();
}

class _VisitingCardCropScreenState extends State<VisitingCardCropScreen> {
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool _loading = false;
  String _selectedAction = '';
  double? _cropAspectRatio;
  int _rotateAngle = 0;

  Future<void> _done() async {
    final state = _editorKey.currentState;
    final rect = state?.getCropRect();
    if (state == null || rect == null) {
      Navigator.pop(context, widget.imageBytes);
      return;
    }

    setState(() => _loading = true);
    try {
      final cropped = await _cropImage(
        imageBytes: state.rawImageData,
        rect: rect,
        rotateAngle: _rotateAngle,
      );
      if (!mounted) return;
      Navigator.pop(context, cropped ?? widget.imageBytes);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Uint8List?> _cropImage({
    required Uint8List imageBytes,
    required Rect rect,
    required int rotateAngle,
  }) async {
    try {
      final cmd = img.Command()..decodeImage(imageBytes);

      final normAngle = ((rotateAngle % 360) + 360) % 360;
      if (normAngle != 0) {
        cmd.copyRotate(angle: normAngle);
      }

      final left = rect.left.round();
      final top = rect.top.round();
      final width = rect.width.round().clamp(1, 100000);
      final height = rect.height.round().clamp(1, 100000);

      cmd.copyCrop(x: left, y: top, width: width, height: height);
      cmd.encodeJpg(quality: 95);

      return await cmd.getBytesThread();
    } catch (e) {
      debugPrint('Crop failed: $e');
      return null;
    }
  }

  void _handleAction(String key) {
    final state = _editorKey.currentState;
    if (state == null) return;

    setState(() => _selectedAction = key);

    switch (key) {
      case 'no crop':
        state.reset();
        state.updateCropAspectRatio(null);
        _cropAspectRatio = null;
        _rotateAngle = 0;
        break;
      case 'auto crop':
        // Landscape visiting-card ratio (~2:1), same idea as PDF Scanner.
        setState(() => _cropAspectRatio = 2);
        state.updateCropAspectRatio(2);
        break;
      case 'Rotate L':
        _rotateAngle = (_rotateAngle - 90) % 360;
        state.rotate(degree: -90, rotateCropRect: true);
        break;
      case 'Rotate R':
        _rotateAngle = (_rotateAngle + 90) % 360;
        state.rotate(degree: 90, rotateCropRect: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Crop',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F1F1F),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _done,
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _cropActiveColor,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _cropActiveColor),
            )
          : ExtendedImage.memory(
              widget.imageBytes,
              cacheRawData: true,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: _editorKey,
              initEditorConfigHandler: (_) {
                return EditorConfig(
                  cropAspectRatio: _cropAspectRatio,
                  hitTestSize: 24,
                  maxScale: 8,
                  cropRectPadding: const EdgeInsets.all(20),
                  initCropRectType: InitCropRectType.imageRect,
                  cornerColor: _cropActiveColor,
                  lineColor: _cropActiveColor,
                  editorMaskColorHandler: (context, pointerDown) {
                    return Colors.black.withValues(
                      alpha: pointerDown ? 0.4 : 0.55,
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: Container(
        height: 72 + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CropActionButton(
              actionKey: 'no crop',
              selectedAction: _selectedAction,
              label: 'No Crop',
              iconPath: app_ui.AppAssets.noCropIcon,
              onTap: _handleAction,
            ),
            _CropActionButton(
              actionKey: 'auto crop',
              selectedAction: _selectedAction,
              label: 'Auto Crop',
              iconPath: app_ui.AppAssets.autoCropIcon,
              onTap: _handleAction,
            ),
            _CropActionButton(
              actionKey: 'Rotate L',
              selectedAction: _selectedAction,
              label: 'Rotate L',
              iconPath: app_ui.AppAssets.rotateLeftIcon,
              onTap: _handleAction,
            ),
            _CropActionButton(
              actionKey: 'Rotate R',
              selectedAction: _selectedAction,
              label: 'Rotate R',
              iconPath: app_ui.AppAssets.rotateRightIcon,
              onTap: _handleAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropActionButton extends StatelessWidget {
  const _CropActionButton({
    required this.actionKey,
    required this.selectedAction,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String actionKey;
  final String selectedAction;
  final String label;
  final String iconPath;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedAction == actionKey;
    final color = selected ? _cropActiveColor : Colors.black;

    return InkWell(
      onTap: () => onTap(actionKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
