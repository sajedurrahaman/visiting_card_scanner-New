import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/scan/domain/scanned_image_model.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_camera_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_crop_screen.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_scanned_contact_screen.dart';
import 'package:visiting_card/features/scan/presentation/view_model/visiting_card_scan_viewmodel.dart';

class VisitingCardScanPreviewScreen extends StatelessWidget {
  const VisitingCardScanPreviewScreen({super.key});

  Future<void> _addContact(BuildContext context) async {
    final vm = context.read<VisitingCardScanViewModel>();
    final ok = await vm.runOcr();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not extract text from the card')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardScannedContactScreen(),
        ),
      ),
    );
  }

  Future<void> _cropAt(BuildContext context, int index) async {
    final vm = context.read<VisitingCardScanViewModel>();
    if (index < 0 || index >= vm.images.length) return;

    final cropped = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardCropScreen(
          imageBytes: vm.images[index].bytes,
        ),
      ),
    );
    if (cropped == null || !context.mounted) return;

    vm.updateImageBytes(index, cropped);
    await vm.persistPreviewFiles();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  Future<void> _retakeAt(BuildContext context, int index) async {
    final vm = context.read<VisitingCardScanViewModel>();
    final retakeBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VisitingCardCameraScreen(
            isRetakeMode: true,
            selectedImageIndex: index,
          ),
        ),
      ),
    );
    if (retakeBytes == null || !context.mounted) return;

    vm.replaceImage(
      index,
      ScannedImageModel(
        bytes: retakeBytes,
        name: 'visitingcard_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
    await vm.persistPreviewFiles();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true) {
      if (context.mounted) {
        context.read<VisitingCardScanViewModel>().clearImages();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardScanViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard(context) && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECECEC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Visiting Card',
            style: ui.AppTextStyles.mainText().copyWith(fontSize: 16.sp),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, size: 22.sp),
            onPressed: () async {
              if (await _confirmDiscard(context) && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: vm.isOcrLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      itemCount: vm.images.length,
                      itemBuilder: (context, index) {
                        final image = vm.images[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            top: vm.images.length > 1 ? 8.h : 0,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.memory(
                                  image.bytes,
                                  key: ValueKey(
                                    '${image.name}_${image.bytes.length}_'
                                    '${image.bytes.isEmpty ? 0 : image.bytes.hashCode}',
                                  ),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  gaplessPlayback: true,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: _PreviewActionButton(
                                  iconAsset: ui.AppAssets.cropIcon,
                                  fallbackIcon: Icons.crop,
                                  onTap: () => _cropAt(context, index),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: _PreviewActionButton(
                                  iconAsset: ui.AppAssets.retakeIcon,
                                  fallbackIcon: Icons.flip_camera_ios_outlined,
                                  onTap: () => _retakeAt(context, index),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      5,
                      8,
                      5,
                      8 + MediaQuery.paddingOf(context).bottom,
                    ),
                    width: double.infinity,
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => _addContact(context),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            ui.AppAssets.visitingCardAddPageIcon,
                            width: 28.w,
                            height: 28.w,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add Contact',
                            style: TextStyle(
                              color: Color(0xFF05B560),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.onTap,
  });

  final String iconAsset;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: SvgPicture.asset(
          iconAsset,
          width: 20,
          height: 20,
          placeholderBuilder: (_) => Icon(fallbackIcon, size: 20),
        ),
      ),
    );
  }
}
