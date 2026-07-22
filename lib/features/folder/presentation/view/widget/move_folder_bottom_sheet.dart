import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';

class MoveFolderBottomSheet extends StatefulWidget {
  const MoveFolderBottomSheet({
    super.key,
    required this.sourceFolderId,
  });

  final String sourceFolderId;

  static Future<bool> show(
    BuildContext context, {
    required String sourceFolderId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (_) => MoveFolderBottomSheet(sourceFolderId: sourceFolderId),
    ).then((value) => value ?? false);
  }

  @override
  State<MoveFolderBottomSheet> createState() => _MoveFolderBottomSheetState();
}

class _MoveFolderBottomSheetState extends State<MoveFolderBottomSheet> {
  late String _browseFolderId;

  @override
  void initState() {
    super.initState();
    _browseFolderId = FolderViewModel.moveRootsBrowseId;
  }

  bool get _isAtRoots => _browseFolderId == FolderViewModel.moveRootsBrowseId;

  bool get _canMoveHere =>
      !_isAtRoots && _browseFolderId != widget.sourceFolderId;

  List<_MoveFolderEntry> _entriesForBrowse(FolderViewModel viewModel) {
    if (_isAtRoots) {
      return viewModel.folders
          .map(
            (folder) => _MoveFolderEntry(
              id: folder.id,
              name: folder.label,
            ),
          )
          .toList();
    }

    return viewModel
        .subFoldersFor(_browseFolderId)
        .map(
          (folder) => _MoveFolderEntry(
            id: folder.id,
            name: folder.name,
          ),
        )
        .toList();
  }

  void _openFolder(String folderId) {
    setState(() => _browseFolderId = folderId);
  }

  void _goBack(FolderViewModel viewModel) {
    if (_isAtRoots) {
      return;
    }

    final parentId = viewModel.parentIdFor(_browseFolderId);
    setState(
      () => _browseFolderId = parentId ?? FolderViewModel.moveRootsBrowseId,
    );
  }

  Future<void> _moveHere(FolderViewModel viewModel) async {
    final moved = await viewModel.moveSelectedItemsTo(
      sourceFolderId: widget.sourceFolderId,
      destinationFolderId: _browseFolderId,
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context, moved);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FolderViewModel>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final entries = _entriesForBrowse(viewModel);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          if (!_isAtRoots)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _goBack(viewModel),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      viewModel.folderNameFor(_browseFolderId),
                      style: ui.AppTextStyles.helperText(
                        color: const Color(0xFF1A1A1A),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: _canMoveHere ? () => _moveHere(viewModel) : null,
                    child: Text(
                      'Move here',
                      style: ui.AppTextStyles.helperText(
                        color: _canMoveHere
                            ? const Color(0xFF05B560)
                            : const Color(0xFFB0B0B0),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Flexible(
            child: entries.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      'No folders found',
                      style: ui.AppTextStyles.helperText(),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFF074D2B).withValues(alpha: 0.08),
                    ),
                    itemBuilder: (context, index) {
                      final folder = entries[index];
                      return _MoveFolderTile(
                        name: folder.name,
                        onTap: () => _openFolder(folder.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MoveFolderEntry {
  const _MoveFolderEntry({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class _MoveFolderTile extends StatelessWidget {
  const _MoveFolderTile({
    required this.name,
    required this.onTap,
  });

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            SvgPicture.asset(
              ui.AppAssets.folderIcon,
              width: 28.w,
              height: 24.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: ui.AppTextStyles.helperText(
                  color: const Color(0xFF1A1A1A),
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}
