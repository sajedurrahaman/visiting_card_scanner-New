import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';

enum RecentCardMenuAction { rename, download, share, delete }

class RecentCardMenuViewModel extends ChangeNotifier {
  Future<void> handleMenuAction(
    BuildContext context, {
    required RecentCardItem item,
    required RecentCardMenuAction action,
  }) async {
    switch (action) {
      case RecentCardMenuAction.rename:
        await rename(context, item);
      case RecentCardMenuAction.download:
        await download(context, item);
      case RecentCardMenuAction.share:
        await share(context, item);
      case RecentCardMenuAction.delete:
        await delete(context, item);
    }
  }

  Future<void> rename(BuildContext context, RecentCardItem item) async {
    final newName = await ui.AppDialogs.showRenameDialog(
      context,
      initialValue: item.name,
    );

    if (!context.mounted) return;
    if (newName == null || newName.isEmpty || newName == item.name) return;

    await context.read<HomeViewModel>().renameRecentCard(item.id, newName);
    if (!context.mounted) return;
    await context.read<FolderViewModel>().loadFromStorage();
    if (!context.mounted) return;
    ui.AppToast.success(context, 'Renamed to $newName');
  }

  Future<void> download(BuildContext context, RecentCardItem item) async {
    final path = item.path ?? item.thumbnailPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      ui.AppToast.success(context, 'File not found');
      return;
    }

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImage(path, album: 'Visiting Card');
      if (!context.mounted) return;
      ui.AppToast.success(context, 'Saved to gallery');
    } catch (_) {
      if (!context.mounted) return;
      ui.AppToast.success(context, 'Failed to save to gallery');
    }
  }

  Future<void> share(BuildContext context, RecentCardItem item) async {
    final path = item.path ?? item.thumbnailPath;
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      ui.AppToast.success(context, 'File not found');
      return;
    }

    try {
      // QR and barcode scans are stored as .txt files.  On iOS, sharing that
      // file as an attachment can fail because no compatible activity is
      // available. Share the scanned value itself instead.
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox == null
          ? null
          : renderBox.localToGlobal(Offset.zero) & renderBox.size;

      if (item.isTextFile) {
        final text = (await File(path).readAsString()).trim();
        if (text.isEmpty) {
          if (context.mounted) ui.AppToast.success(context, 'Nothing to share');
          return;
        }
        await Share.share(
          text,
          subject: item.name,
          sharePositionOrigin: origin,
        );
      } else {
        await Share.shareXFiles(
          [XFile(path)],
          text: item.name,
          sharePositionOrigin: origin,
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ui.AppToast.success(context, 'Share failed');
    }
  }

  Future<void> delete(BuildContext context, RecentCardItem item) async {
    final shouldDelete = await ui.AppDialogs.showDeleteDialog(
      context,
      message: 'Are you sure you want to delete "${item.name}"?',
      confirmText: 'Ok',
    );

    if (!context.mounted) return;
    if (shouldDelete != true) return;

    await context.read<HomeViewModel>().deleteRecentCard(item.id);
    if (!context.mounted) return;
    await context.read<FolderViewModel>().loadFromStorage();
    if (!context.mounted) return;
    ui.AppToast.success(context, '${item.name} deleted');
  }
}
