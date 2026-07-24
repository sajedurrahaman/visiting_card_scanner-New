import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/presentation/helper/qr_barcode_scan_storage.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/qr_barcode_scan_result_screen.dart';

/// Camera scanner for QR / Barcode — PDF Scanner UI, green theme.
class QrBarcodeCameraScanScreen extends StatefulWidget {
  const QrBarcodeCameraScanScreen({
    super.key,
    required this.kind,
  });

  final QrBarcodeScanKind kind;

  @override
  State<QrBarcodeCameraScanScreen> createState() =>
      _QrBarcodeCameraScanScreenState();
}

class _QrBarcodeCameraScanScreenState extends State<QrBarcodeCameraScanScreen>
    with WidgetsBindingObserver {
  static const _themeGreen = Color(0xFF05B560);

  late final MobileScannerController _controller = MobileScannerController(
    formats: widget.kind == QrBarcodeScanKind.qrCode
        ? const [BarcodeFormat.qrCode]
        : const [
            BarcodeFormat.aztec,
            BarcodeFormat.codabar,
            BarcodeFormat.code128,
            BarcodeFormat.code39,
            BarcodeFormat.code93,
            BarcodeFormat.dataMatrix,
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
            BarcodeFormat.itf14,
            BarcodeFormat.pdf417,
            BarcodeFormat.upcA,
            BarcodeFormat.upcE,
          ],
  );

  bool _handled = false;
  bool _resumeOnForeground = false;

  bool get _isQr => widget.kind == QrBarcodeScanKind.qrCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted || _handled) return;
    if (state == AppLifecycleState.resumed && _resumeOnForeground) {
      _resumeOnForeground = false;
      try {
        await _controller.start();
      } catch (_) {}
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _resumeOnForeground = true;
      try {
        await _controller.stop();
      } catch (_) {}
    }
  }

  Future<void> _goToResult(String raw) async {
    if (_handled || !mounted) return;
    final value = raw.trim();
    if (value.isEmpty) return;

    _handled = true;
    try {
      await _controller.stop();
    } catch (_) {}

    if (!mounted) return;
    await QrBarcodeScanStorage.saveScan(
      context: context,
      kind: widget.kind,
      text: value,
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrBarcodeScanResultScreen(
          kind: widget.kind,
          content: value,
        ),
      ),
    );

    // Back from result → resume camera for another scan.
    if (!mounted) return;
    _handled = false;
    try {
      await _controller.start();
    } catch (_) {}
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || !mounted) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    await _goToResult(raw);
  }

  Future<void> _importFromGallery() async {
    if (kIsWeb || _handled) return;

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final capture = await _controller.analyzeImage(image.path);
    if (!mounted) return;

    if (capture == null || capture.barcodes.isEmpty) {
      ui.AppToast.show(
        context,
        message: _isQr
            ? 'No QR Code found in the image!'
            : 'No Barcode found in the image!',
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) {
      ui.AppToast.show(
        context,
        message: _isQr
            ? 'No QR Code detected in the image!'
            : 'No Barcode detected in the image!',
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    if (_isQr && barcode.format != BarcodeFormat.qrCode) {
      ui.AppToast.show(
        context,
        message:
            'Barcode cannot be detected from QR code camera mode. Please use Barcode mode.',
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    if (!_isQr && barcode.format == BarcodeFormat.qrCode) {
      ui.AppToast.show(
        context,
        message:
            'QR code cannot be detected from barcode camera mode. Please use QR Code mode.',
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }

    await _goToResult(raw);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanWindow = _isQr
        ? Rect.fromCenter(
            center: size.center(const Offset(0, -5)),
            width: 300,
            height: 300,
          )
        : Rect.fromCenter(
            center: size.center(const Offset(0, -5)),
            width: size.width * 0.85,
            height: 240,
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            try {
              await _controller.stop();
            } catch (_) {}
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }
              final on = state.torchState == TorchState.on ||
                  state.torchState == TorchState.auto;
              return IconButton(
                onPressed: () => _controller.toggleTorch(),
                icon: SvgPicture.asset(
                  on ? ui.AppAssets.flashOnIcon : ui.AppAssets.flashOffIcon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            scanWindow: scanWindow,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    'Camera error:\n${error.errorCode.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          // PDF Scanner style: corner frame + scanning lottie (green theme)
          Center(
            child: Transform.translate(
              offset: const Offset(0, -70),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    _isQr
                        ? ui.AppAssets.qrCodeScanBorder
                        : ui.AppAssets.barcodeScanFrame,
                    colorFilter: const ColorFilter.mode(
                      _themeGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: ColorFiltered(
                      // Force any remaining pink/gradient pixels to theme green.
                      colorFilter: const ColorFilter.mode(
                        _themeGreen,
                        BlendMode.srcIn,
                      ),
                      child: Lottie.asset(ui.AppAssets.scanLottie),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: size.width,
                  height: 40,
                  child: _ZoomScaleSlider(controller: _controller),
                ),
                Container(
                  width: size.width,
                  height: 150,
                  color: Colors.black,
                  child: Align(
                    alignment: const Alignment(-0.72, 0.15),
                    child: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, state, _) {
                        if (!state.isInitialized || !state.isRunning) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              color: Colors.white,
                              iconSize: 28,
                              onPressed: _importFromGallery,
                              icon: SvgPicture.asset(
                                ui.AppAssets.galleryImportIcon,
                                width: 28,
                                height: 28,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const Text(
                              'Import Image',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

class _ZoomScaleSlider extends StatelessWidget {
  const _ZoomScaleSlider({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.setZoomScale(state.zoomScale - 0.1);
                },
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.5),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: state.zoomScale.clamp(0.0, 1.0),
                    onChanged: controller.setZoomScale,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.setZoomScale(state.zoomScale + 0.1);
                },
                child: const Icon(
                  Icons.add_circle_outline_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
