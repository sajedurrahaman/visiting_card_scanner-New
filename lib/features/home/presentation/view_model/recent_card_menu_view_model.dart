import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/domain/model/recent_card_item.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';

enum RecentCardMenuAction { rename, download, share, delete }

class RecentCardMenuViewModel extends ChangeNotifier {
  void handleMenuAction(
    BuildContext context, {
    required RecentCardItem item,
    required RecentCardMenuAction action,
  }) {
    switch (action) {
      case RecentCardMenuAction.rename:
        rename(context, item);
      case RecentCardMenuAction.download:
        download(context, item);
      case RecentCardMenuAction.share:
        share(context, item);
      case RecentCardMenuAction.delete:
        delete(context, item);
    }
  }

  Future<void> rename(BuildContext context, RecentCardItem item) async {
    final controller = TextEditingController(text: item.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (newName == null || newName.isEmpty || newName == item.name) return;

    context.read<HomeViewModel>().renameRecentCard(item.id, newName);
    ui.AppToast.success(context, 'Renamed to $newName');
  }

  void download(BuildContext context, RecentCardItem item) {
    // TODO: Integrate file download when storage layer is ready.
    ui.AppToast.success(context, 'Downloading ${item.name}...');
  }

  void share(BuildContext context, RecentCardItem item) {
    // TODO: Integrate share sheet when file path is available.
    ui.AppToast.success(context, 'Sharing ${item.name}...');
  }

  Future<void> delete(BuildContext context, RecentCardItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (shouldDelete != true) return;

    context.read<HomeViewModel>().deleteRecentCard(item.id);
    ui.AppToast.success(context, '${item.name} deleted');
  }
}
