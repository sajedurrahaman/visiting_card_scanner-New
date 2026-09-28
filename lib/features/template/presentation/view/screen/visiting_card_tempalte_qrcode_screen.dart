import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_image_helper.dart';
import 'package:visiting_card/features/template/presentation/view/screen/qrcode_customize_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_qr_option_dialog.dart';

class _VisitingQrTemplateItem {
  const _VisitingQrTemplateItem({
    required this.asset,
    required this.stackTemplateIndex,
    this.isLocalUpload = false,
  });

  final String asset;
  final int stackTemplateIndex;
  final bool isLocalUpload;
}

/// QR Template picker for visiting-card embed flow.
/// Returns a local image path via [Navigator.pop], or null if cancelled.
class VisitingCardTempalteQrcodeScreen extends StatefulWidget {
  const VisitingCardTempalteQrcodeScreen({
    super.key,
    required this.qrData,
  });

  final String qrData;

  @override
  State<VisitingCardTempalteQrcodeScreen> createState() =>
      _VisitingCardTempalteQrcodeScreenState();
}

class _VisitingCardTempalteQrcodeScreenState
    extends State<VisitingCardTempalteQrcodeScreen> {
  static const _items = [
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode1,
      stackTemplateIndex: 0,
      isLocalUpload: true,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode2,
      stackTemplateIndex: 0,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode3,
      stackTemplateIndex: 2,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode4,
      stackTemplateIndex: 5,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode5,
      stackTemplateIndex: 4,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode6,
      stackTemplateIndex: 10,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode7,
      stackTemplateIndex: 14,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode8,
      stackTemplateIndex: 6,
    ),
    _VisitingQrTemplateItem(
      asset: ui.AppAssets.templateVisitingCardQrCode9,
      stackTemplateIndex: 15,
    ),
  ];

  int? _selectedIndex;
  bool _busy = false;

  Future<void> _onItemTap(int index) async {
    if (_busy) return;
    setState(() => _selectedIndex = index);

    final item = _items[index];

    // Local file → set directly on visiting card (no Place/Customize dialog).
    if (item.isLocalUpload) {
      setState(() => _busy = true);
      try {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (picked == null || !mounted) return;
        Navigator.pop(context, picked.path);
      } on PlatformException catch (e) {
        if (e.code != 'already_active') rethrow;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    final option = await VisitingCardQrOptionDialog.show(context);
    if (option == null || !mounted) return;

    setState(() => _busy = true);
    try {
      switch (option) {
        case VisitingCardQrOption.place:
          final path = await VisitingCardQrImageHelper.renderToFile(
            qrData: widget.qrData,
            templateIndex: item.stackTemplateIndex,
          );
          if (!mounted) return;
          if (path == null) {
            ui.AppToast.show(
              context,
              message: 'Could not create QR',
              backgroundColor: const Color(0xFFE53935),
            );
            return;
          }
          Navigator.pop(context, path);
        case VisitingCardQrOption.customize:
          final path = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) => QrcodeCustomizeScreen(
                qrData: widget.qrData,
                templateIndex: item.stackTemplateIndex,
                thumbnailAsset: item.asset,
                forVisitingCard: true,
              ),
            ),
          );
          if (!mounted) return;
          if (path != null && path.isNotEmpty) {
            Navigator.pop(context, path);
          }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'QR Template',
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 18.sp),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final selected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onItemTap(index),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      item.asset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
