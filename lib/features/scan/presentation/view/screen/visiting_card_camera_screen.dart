import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/domain/scanned_image_model.dart';
import 'package:visiting_card/features/scan/presentation/helper/parent_scan_navigator.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scan_preview_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/widget/parent_scan_mode_strip.dart';
import 'package:visiting_card/features/scan/presentation/view/widget/visiting_card_scan_box_overlay.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';

class VisitingCardCameraScreen extends StatefulWidget {
  const VisitingCardCameraScreen({
    super.key,
    this.isRetakeMode = false,
    this.selectedImageIndex,
    this.showScanModeStrip = false,
    this.scanMode = ParentScanMode.visitingCard,
  });

  final bool isRetakeMode;
  final int? selectedImageIndex;

  /// Parent center FAB flow: show Visiting Card / QR / Barcode mode strip.
  final bool showScanModeStrip;
  final ParentScanMode scanMode;

  @override
  State<VisitingCardCameraScreen> createState() =>
      _VisitingCardCameraScreenState();
}

class _VisitingCardCameraScreenState extends State<VisitingCardCameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isCapturing = false;
  bool _torchOn = false;
  bool _isAutoCamera = false;
  Size _screenSize = Size.zero;
  double _scale = 1.0;
  static const _minScale = 0.7;
  static const _maxScale = 1.4;
  /// Matches PDF Scanner black controls bar (strip + import/capture fit inside).
  static const _bottomBarHeight = 150.0;
  double _startingScale = 1.0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isReady = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _ensureTorchOff() async {
    try {
      await _controller?.setFlashMode(FlashMode.off);
      _torchOn = false;
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Rect _scanBoxRect(Size screenSize) {
    final effectiveHeight = screenSize.height - _bottomBarHeight;
    final boxWidth = screenSize.width * 0.88;
    final boxHeight = boxWidth / 1.8;
    final left = (screenSize.width - boxWidth) / 2;
    final top = (effectiveHeight - boxHeight) / 2;
    return Rect.fromLTWH(left, top, boxWidth, boxHeight);
  }

  Future<Uint8List> _cropToScanBox(Uint8List bytes) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null || _screenSize == Size.zero) return bytes;

      final scanBox = _scanBoxRect(_screenSize);
      final imageWidth = decoded.width.toDouble();
      final imageHeight = decoded.height.toDouble();
      final screenWidth = _screenSize.width;
      final screenHeight = _screenSize.height;

      final cameraAspect = imageWidth / imageHeight;
      final screenAspect = screenWidth / screenHeight;

      late double previewWidth;
      late double previewHeight;
      late double previewLeft;
      late double previewTop;

      if (cameraAspect > screenAspect) {
        previewWidth = screenWidth;
        previewHeight = screenWidth / cameraAspect;
        previewLeft = 0;
        previewTop = (screenHeight - previewHeight) / 2;
      } else {
        previewHeight = screenHeight;
        previewWidth = screenHeight * cameraAspect;
        previewTop = 0;
        previewLeft = (screenWidth - previewWidth) / 2;
      }

      final scaledPreviewWidth = previewWidth / _scale;
      final scaledPreviewHeight = previewHeight / _scale;
      final scaledPreviewLeft =
          previewLeft + (previewWidth - scaledPreviewWidth) / 2;
      final scaledPreviewTop =
          previewTop + (previewHeight - scaledPreviewHeight) / 2;

      final relativeLeft =
          (scanBox.left - scaledPreviewLeft) / scaledPreviewWidth;
      final relativeTop =
          (scanBox.top - scaledPreviewTop) / scaledPreviewHeight;
      final relativeWidth = scanBox.width / scaledPreviewWidth;
      final relativeHeight = scanBox.height / scaledPreviewHeight;

      final cropLeft =
          (relativeLeft * imageWidth).toInt().clamp(0, decoded.width - 1);
      final cropTop =
          (relativeTop * imageHeight).toInt().clamp(0, decoded.height - 1);
      final cropWidth = (relativeWidth * imageWidth)
          .toInt()
          .clamp(1, decoded.width - cropLeft);
      final cropHeight = (relativeHeight * imageHeight)
          .toInt()
          .clamp(1, decoded.height - cropTop);

      final cropped = img.copyCrop(
        decoded,
        x: cropLeft,
        y: cropTop,
        width: cropWidth,
        height: cropHeight,
      );
      return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    final vm = context.read<VisitingCardScanViewModel>();
    if (controller == null || !_isReady || _isCapturing) return;

    if (!widget.isRetakeMode && !vm.canCaptureMore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.isBothSides
                ? 'You can only capture 2 pictures for visiting cards.'
                : 'You can only capture 1 picture for visiting card.',
          ),
        ),
      );
      return;
    }

    setState(() => _isCapturing = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      if (!_torchOn) {
        await controller.setFlashMode(FlashMode.off);
      }
      final picture = await controller.takePicture();
      var bytes = await picture.readAsBytes();
      bytes = await _cropToScanBox(bytes);
      final name =
          'visitingcard_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (widget.isRetakeMode) {
        final index = widget.selectedImageIndex ?? 0;
        vm.replaceImage(
          index,
          ScannedImageModel(bytes: bytes, name: name),
        );
        await vm.persistPreviewFiles();
        if (mounted) Navigator.of(context).pop();
        if (mounted) Navigator.of(context).pop<Uint8List>(bytes);
        return;
      }

      vm.addImage(ScannedImageModel(bytes: bytes, name: name));
      if (mounted) Navigator.of(context).pop();
      // Stay on camera until user taps Done (PDF Scanner behaviour).
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _startAutoCapture() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isAutoCamera || _isCapturing) return;
      final vm = context.read<VisitingCardScanViewModel>();
      if (!widget.isRetakeMode && !vm.canCaptureMore) {
        _stopAutoCapture();
        return;
      }
      _takePicture();
    });
  }

  void _stopAutoCapture() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _toggleAutoManual() {
    setState(() => _isAutoCamera = !_isAutoCamera);
    if (_isAutoCamera) {
      _startAutoCapture();
    } else {
      _stopAutoCapture();
    }
  }

  Future<void> _pickFromGallery() async {
    final vm = context.read<VisitingCardScanViewModel>();
    if (!vm.canCaptureMore) return;

    final remaining = vm.maxShots - vm.images.length;
    final picked = await ImagePicker().pickMultiImage(
      imageQuality: 90,
      limit: remaining,
    );
    if (picked.isEmpty || !mounted) return;

    for (final file in picked) {
      if (!vm.canCaptureMore) break;
      final bytes = await file.readAsBytes();
      final cropped = await _cropToScanBox(bytes);
      vm.addImage(
        ScannedImageModel(
          bytes: cropped,
          name: 'visitingcard_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
    }

    // Stay on camera until user taps Done.
    if (mounted) setState(() {});
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !_isReady) return;
    try {
      _torchOn = !_torchOn;
      await controller.setFlashMode(_torchOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _openPreview() async {
    await _ensureTorchOff();
    if (mounted) setState(() {});
    _stopAutoCapture();
    final vm = context.read<VisitingCardScanViewModel>();
    if (vm.images.isEmpty) return;
    await vm.persistPreviewFiles();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardScanPreviewScreen(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final vm = context.read<VisitingCardScanViewModel>();
    if (widget.isRetakeMode || vm.images.isEmpty) {
      await _ensureTorchOff();
      return true;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Visiting Card?'),
        content: const Text(
          'If you leave now, your progress will be lost. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) {
      await _ensureTorchOff();
      _stopAutoCapture();
      vm.clearImages();
      return true;
    }
    return false;
  }

  Widget _buildCameraPreview() {
    final c = _controller!;
    final previewSize = c.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    // previewSize is landscape (w>h); CameraPreview is portrait-oriented.
    final previewAspect = previewSize.height / previewSize.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenAspect = constraints.maxWidth / constraints.maxHeight;
        var scale = previewAspect / screenAspect;
        if (scale < 1) scale = 1 / scale;
        scale *= _scale;

        return GestureDetector(
          onScaleStart: (_) => _startingScale = _scale,
          onScaleUpdate: (details) {
            setState(() {
              _scale =
                  (_startingScale * details.scale).clamp(_minScale, _maxScale);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: previewAspect,
                      child: CameraPreview(c),
                    ),
                  ),
                ),
              ),
              VisitingCardScanBoxOverlay(
                onScreenSizeUpdated: (size) => _screenSize = size,
                getScanningBoxRect: _scanBoxRect,
                capturedImageCount: context
                    .watch<VisitingCardScanViewModel>()
                    .images
                    .length,
                isBothSides:
                    context.watch<VisitingCardScanViewModel>().isBothSides,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardScanViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onWillPop() && mounted) {
          Navigator.of(this.context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop() && mounted) {
                Navigator.of(this.context).pop();
              }
            },
            icon: const Icon(Icons.close, size: 26, color: Colors.white),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _toggleAutoManual,
                child: Text(
                  _isAutoCamera ? 'Auto' : 'Manual',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD8D9DB),
                  ),
                ),
              ),
              SvgPicture.asset(
                ui.AppAssets.autoCameraIcon,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFD8D9DB),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _toggleTorch,
              icon: SvgPicture.asset(
                _torchOn
                    ? ui.AppAssets.flashOnIcon
                    : ui.AppAssets.flashOffIcon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        body: !_isReady || _controller == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildCameraPreview()),
                    if (!widget.isRetakeMode)
                      Positioned(
                        bottom: _bottomBarHeight + 30,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SideChip(
                              label: 'One Side',
                              selected: !vm.isBothSides,
                              onTap: () => vm.setBothSides(false),
                            ),
                            const SizedBox(width: 20),
                            _SideChip(
                              label: 'Both Side',
                              selected: vm.isBothSides,
                              onTap: () => vm.setBothSides(true),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: _bottomBarHeight,
                        color: Colors.black,
                        child: Column(
                          children: [
                            // PDF Scanner parity: top 50px is either mode strip
                            // OR Done (strip/triangle hide after first capture).
                            SizedBox(
                              height: 50,
                              child: (widget.showScanModeStrip &&
                                      vm.images.isEmpty &&
                                      !widget.isRetakeMode)
                                  ? ParentScanModeStrip(
                                      selected: widget.scanMode,
                                      onChanged: (mode) =>
                                          ParentScanNavigator.switchMode(
                                        context,
                                        mode,
                                      ),
                                    )
                                  : (vm.images.isNotEmpty &&
                                          !widget.isRetakeMode)
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: TextButton(
                                            onPressed: _openPreview,
                                            child: const Text(
                                              'Done',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: widget.showScanModeStrip ? 8 : 16,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: _pickFromGallery,
                                            icon: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  ui.AppAssets
                                                      .galleryImportIcon,
                                                  width: 28,
                                                  height: 28,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                const Text(
                                                  'Import Image',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _takePicture,
                                            child: Container(
                                              width: widget.showScanModeStrip
                                                  ? 58
                                                  : 68,
                                              height: widget.showScanModeStrip
                                                  ? 58
                                                  : 68,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 4,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: widget.showScanModeStrip
                                                    ? 46
                                                    : 54,
                                                height: widget.showScanModeStrip
                                                    ? 46
                                                    : 54,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                          /// Captured preview — bottom right
                                          SizedBox(
                                            width: 72,
                                            height: 56,
                                            child: vm.images.isNotEmpty &&
                                                    !widget.isRetakeMode
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: _openPreview,
                                                          child: Container(
                                                            width: 46,
                                                            height: 46,
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.red,
                                                                width: 2,
                                                              ),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    MemoryImage(
                                                                  vm
                                                                      .images
                                                                      .last
                                                                      .bytes,
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          top: -10,
                                                          right: -5,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(6),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Text(
                                                              '${vm.images.length}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.transparent,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
