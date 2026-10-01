import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/presentation/view/screen/saved_image_preview_screen.dart';
import 'package:visiting_card/features/home/presentation/view_model/recent_card_menu_view_model.dart';
import 'package:visiting_card/features/scan/domain/visiting_card_folder_paths.dart';
import 'package:visiting_card/features/scan/presentation/helper/qr_barcode_scan_storage.dart';
import 'package:visiting_card/features/scan/presentation/view/screen/visiting_card_contact_details_screen.dart';

class RecentCardTile extends StatelessWidget {
  const RecentCardTile({
    super.key,
    required this.item,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.selectionTrailing,
    this.onTap,
  });

  final RecentCardItem item;
  final bool isSelectionMode;
  final bool isSelected;
  final Widget? selectionTrailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final menuViewModel = context.read<RecentCardMenuViewModel>();
    final isScanQrOrBarcode = QrBarcodeScanStorage.isScanTextItem(item);
    final menuItems = <PopupMenuEntry<RecentCardMenuAction>>[
      _buildMenuItem(
        value: RecentCardMenuAction.rename,
        icon: Icons.edit_outlined,
        label: 'Rename',
      ),
      if (!isScanQrOrBarcode)
        _buildMenuItem(
          value: RecentCardMenuAction.download,
          icon: Icons.download_outlined,
          label: 'Download',
        ),
      _buildMenuItem(
          value: RecentCardMenuAction.share,
          icon: Icons.share_outlined,
          label: 'Share',
        ),
      _buildMenuItem(
        value: RecentCardMenuAction.delete,
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
    ];

    return GestureDetector(
      onTap: onTap ??
          (isSelectionMode
              ? null
              : () async {
                  if (item.fileType == 'visiting_card') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VisitingCardContactDetailsScreen(item: item),
                      ),
                    );
                    return;
                  }

                  if (QrBarcodeScanStorage.isScanTextItem(item)) {
                    await QrBarcodeScanStorage.openSavedScan(context, item);
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedImagePreviewScreen(item: item),
                    ),
                  );
                }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelectionMode && isSelected
              ? ui.Colors.cardBgColor
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _RecentThumbnail(item: item),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ui.AppTextStyles.helperText(
                      color: const Color(0xFF1A1A1A),
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          item.dateTime,
                          style: ui.AppTextStyles.iconUnderText(
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelectionMode)
              selectionTrailing ?? const SizedBox.shrink()
            else
              PopupMenuButton<RecentCardMenuAction>(
                padding: EdgeInsets.zero,
                color: Colors.white,
                elevation: 8,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                onSelected: (action) =>
                    _handleMenuAction(context, menuViewModel, action),
                itemBuilder: (context) => menuItems,
                child: Icon(
                  Icons.more_vert,
                  size: 22.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<RecentCardMenuAction> _buildMenuItem({
    required RecentCardMenuAction value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem<RecentCardMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: const Color(0xFF1A1A1A)),
          SizedBox(width: 10.w),
          Text(
            label,
            style: ui.AppTextStyles.helperText(
              color: const Color(0xFF1A1A1A),
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    RecentCardMenuViewModel menuViewModel,
    RecentCardMenuAction action,
  ) async {
    if (item.fileType == 'visiting_card') {
      switch (action) {
        case RecentCardMenuAction.rename:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitingCardContactDetailsScreen(
                item: item,
                initialAction: VisitingCardInitialAction.edit,
              ),
            ),
          );
          return;
        case RecentCardMenuAction.download:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitingCardContactDetailsScreen(item: item),
            ),
          );
          return;
        case RecentCardMenuAction.share:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitingCardContactDetailsScreen(
                item: item,
                initialAction: VisitingCardInitialAction.share,
              ),
            ),
          );
          return;
        case RecentCardMenuAction.delete:
          break;
      }
    }

    await menuViewModel.handleMenuAction(
      context,
      item: item,
      action: action,
    );
  }
}

class _RecentThumbnail extends StatelessWidget {
  const _RecentThumbnail({required this.item});

  final RecentCardItem item;

  /// Fixed list slot; the image keeps its original aspect ratio inside it.
  static double get _width => 80.w;
  static double get _qrBarcodeWidth => 70.w;
  static double get _height => 46.h;

  bool get _isQrOrBarcode =>
      item.fileType == 'qr' || item.fileType == 'barcode';

  double get _thumbWidth => _isQrOrBarcode ? _qrBarcodeWidth : _width;

  File? _resolveImageFile() {
    // Scan .txt files are not images — never load them via Image.file.
    if (item.isTextFile) return null;

    // Visiting-card [path] is a contact folder — never pass a Directory to
    // Image.file (common after restart when pathImage is stale/missing).
    if (item.fileType == 'visiting_card') {
      return VisitingCardFolderPaths.resolveThumbnail(
        thumbnailPath: item.thumbnailPath,
        folderOrFilePath: item.path,
      );
    }

    for (final path in [item.thumbnailPath, item.path]) {
      if (path == null || path.isEmpty) continue;
      final lower = path.toLowerCase();
      if (lower.endsWith('.txt') || lower.endsWith('.json')) continue;
      if (Directory(path).existsSync()) continue;
      final file = File(path);
      if (file.existsSync()) return file;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final file = _resolveImageFile();
    final radius = BorderRadius.circular(8.r);

    Widget child;
    if (file != null) {
      if (item.fileType == 'visiting_card') {
        // Center gives the image loose constraints, so its layout follows its
        // aspect ratio. Attach the shadow to that image, not the list slot.
        return SizedBox(
          width: _thumbWidth,
          height: _height,
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: Center(
              child: _floatingBox(
                Image.file(
                  file,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => _placeholder(
                    icon: Icons.broken_image_outlined,
                    background: Colors.grey.shade200,
                  ),
                ),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        );
      }
      child = ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: _thumbWidth,
          height: _height,
          child: Padding(
            // Keep card corners clear of the rounded thumbnail clip.
            padding: _isQrOrBarcode ? EdgeInsets.zero : EdgeInsets.all(3.r),
            child: Image.file(
              file,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _placeholder(
                  icon: Icons.broken_image_outlined,
                  background: Colors.grey.shade200,
                );
              },
            ),
          ),
        ),
      );
    } else if (item.isTextFile) {
      child = _assetThumb(
        asset: item.fileType == 'barcode'
            ? ui.AppAssets.barcodeThumbIcon
            : item.fileType == 'qr'
                ? ui.AppAssets.qrCodeThumbIcon
                : ui.AppAssets.txtFileThumbIcon,
        background: item.fileType == 'barcode'
            ? const Color(0xFFE7E0FE)
            : const Color(0xFFDAEDFF),
        iconWidth: item.fileType == 'barcode' ? 36.w : 26.w,
        iconHeight: item.fileType == 'barcode' ? 20.h : 26.w,
      );
    } else if (_isQrOrBarcode) {
      child = _assetThumb(
        asset: item.fileType == 'barcode'
            ? ui.AppAssets.barcodeThumbIcon
            : ui.AppAssets.qrCodeThumbIcon,
        background: item.fileType == 'barcode'
            ? const Color(0xFFE7E0FE)
            : const Color(0xFFDAEDFF),
        iconWidth: item.fileType == 'barcode' ? 36.w : 26.w,
        iconHeight: item.fileType == 'barcode' ? 20.h : 26.w,
      );
    } else {
      child = _placeholder(
        icon: Icons.credit_card,
        background: const Color(0xFFF3F3F3),
      );
    }

    return _isQrOrBarcode ? _elevationBox(child) : _floatingBox(child);
  }

  Widget _elevationBox(Widget child) {
    return Material(
      elevation: 20,
      color: Colors.white,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _floatingBox(Widget child, {BorderRadius? borderRadius}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: item.fileType == 'visiting_card' ? 0.16 : 0.10,
            ),
            blurRadius: item.fileType == 'visiting_card' ? 12 : 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: item.fileType == 'visiting_card' ? 0.07 : 0.04,
            ),
            blurRadius: item.fileType == 'visiting_card' ? 5 : 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _assetThumb({
    required String asset,
    required Color background,
    double? iconWidth,
    double? iconHeight,
  }) {
    return Container(
      width: _thumbWidth,
      height: _height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        asset,
        width: iconWidth ?? 28.w,
        height: iconHeight ?? 28.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _placeholder({
    required IconData icon,
    required Color background,
    Color iconColor = const Color(0xFF9E9E9E),
  }) {
    return Container(
      width: _thumbWidth,
      height: _height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22.sp),
    );
  }
}
