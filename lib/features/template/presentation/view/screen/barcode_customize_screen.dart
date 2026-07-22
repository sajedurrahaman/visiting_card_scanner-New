import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/template/presentation/view/widget/barcode_template_stack_builder.dart';
import 'package:visiting_card/features/template/presentation/view_model/barcode_customize_viewmodel.dart';

class BarcodeCustomizeScreen extends StatelessWidget {
  const BarcodeCustomizeScreen({
    super.key,
    required this.barcodeData,
    required this.templateIndex,
    this.thumbnailAsset,
  });

  final String barcodeData;
  final int templateIndex;
  final String? thumbnailAsset;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarcodeCustomizeViewModel(
        initialBarcodeData: barcodeData,
        initialTemplateIndex: templateIndex,
        thumbnailAsset: thumbnailAsset,
      ),
      child: const _BarcodeCustomizeBody(),
    );
  }
}

class _BarcodeCustomizeBody extends StatefulWidget {
  const _BarcodeCustomizeBody();

  @override
  State<_BarcodeCustomizeBody> createState() => _BarcodeCustomizeBodyState();
}

class _BarcodeCustomizeBodyState extends State<_BarcodeCustomizeBody> {
  late final TextEditingController _textController;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: context.read<BarcodeCustomizeViewModel>().barcodeData,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final vm = context.read<BarcodeCustomizeViewModel>();
    final ok = await vm.saveToGallery(
      homeViewModel: context.read<HomeViewModel>(),
      folderViewModel: context.read<FolderViewModel>(),
    );
    if (!mounted) return;
    ui.AppToast.success(context, ok ? 'Saved to gallery' : 'Save failed');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarcodeCustomizeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: const Color(0xFF404040),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Barcode',
          style: ui.AppTextStyles.mainText().copyWith(
            fontSize: 18.sp,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: vm.isSaving ? null : _onSave,
            child: Text(
              vm.isSaving ? 'Saving...' : 'Save',
              style: ui.AppTextStyles.helperText(color: _accent).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEEEEEE),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Screenshot(
                controller: vm.screenshotController,
                child: Container(
                  width: 280.w,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: vm.backgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: BarcodeTemplateStackBuilder(
                    templateIndex: vm.templateIndex,
                    barcodeData: vm.barcodeData,
                    foregroundColor: vm.foregroundColor,
                    barcodeHeight: vm.barcodeHeight,
                  ),
                ),
              ),
            ),
          ),
          _EditorPanel(vm: vm, textController: _textController),
        ],
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({required this.vm, required this.textController});

  final BarcodeCustomizeViewModel vm;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final contentHeight = switch (vm.selectedTab) {
      BarcodeCustomizeTab.text => 80.h,
      BarcodeCustomizeTab.template => 160.h,
      _ => 120.h,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 14.h),
            _TabRow(vm: vm),
            SizedBox(height: 14.h),
            SizedBox(
              height: contentHeight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: _TabContent(vm: vm, textController: textController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({required this.vm});

  final BarcodeCustomizeViewModel vm;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (BarcodeCustomizeTab.text, ui.AppAssets.barTemplateRowText, 'Text'),
      (
        BarcodeCustomizeTab.template,
        ui.AppAssets.barTemplateRowTemplate,
        'Template'
      ),
      (BarcodeCustomizeTab.color, ui.AppAssets.barTemplateRowColor, 'Color'),
      (BarcodeCustomizeTab.height, ui.AppAssets.barTemplateRowHeight, 'Height'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final tab in tabs)
            _CircularTab(
              iconPath: tab.$2,
              label: tab.$3,
              selected: vm.selectedTab == tab.$1,
              onTap: () => vm.setTab(tab.$1),
            ),
        ],
      ),
    );
  }
}

class _CircularTab extends StatelessWidget {
  const _CircularTab({
    required this.iconPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _accent : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 44.w,
              height: 44.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: ui.AppTextStyles.iconUnderText(
              color: selected ? _accent : const Color(0xFF404040),
            ).copyWith(
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.vm, required this.textController});

  final BarcodeCustomizeViewModel vm;
  final TextEditingController textController;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    switch (vm.selectedTab) {
      case BarcodeCustomizeTab.text:
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) {
            return TextField(
              controller: textController,
              onChanged: vm.setBarcodeData,
              style: ui.AppTextStyles.helperText(color: const Color(0xFF1A1A1A))
                  .copyWith(fontSize: 13.sp, letterSpacing: 0, height: 1.1),
              decoration: InputDecoration(
                hintText: 'Enter barcode content',
                hintStyle:
                    ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0))
                        .copyWith(fontSize: 13.sp, letterSpacing: 0),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                isDense: true,
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 12.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            BoxConstraints(minWidth: 28.w, minHeight: 28.h),
                        onPressed: () {
                          textController.clear();
                          vm.setBarcodeData('');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: _accent, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: _accent, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: _accent, width: 1.2),
                ),
              ),
            );
          },
        );
      case BarcodeCustomizeTab.template:
        return GridView.builder(
          itemCount: BarcodeCustomizeViewModel.templateOptions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemBuilder: (context, index) {
            final item = BarcodeCustomizeViewModel.templateOptions[index];
            final selected = vm.templateIndex == item.stackTemplateIndex;
            return GestureDetector(
              onTap: () => vm.selectTemplate(item.stackTemplateIndex),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: selected
                        ? ui.Colors.parentIconSelectTextColor
                        : const Color(0xFFE8E8E8),
                    width: 1.5,
                  ),
                ),
                padding: EdgeInsets.all(8.w),
                child: Image.asset(item.thumbnailAsset, fit: BoxFit.contain),
              ),
            );
          },
        );
      case BarcodeCustomizeTab.color:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solid Color', style: ui.AppTextStyles.iconUnderText()),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final color in BarcodeCustomizeViewModel.solidColors)
                  GestureDetector(
                    onTap: () => vm.selectColor(color),
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: vm.foregroundColor == color
                              ? ui.Colors.parentIconSelectTextColor
                              : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      case BarcodeCustomizeTab.height:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Height: ${vm.barcodeHeight.round()}',
              style: ui.AppTextStyles.iconUnderText(),
            ),
            Slider(
              value: vm.barcodeHeight,
              min: 40,
              max: 120,
              activeColor: ui.Colors.parentIconSelectTextColor,
              onChanged: vm.setBarcodeHeight,
            ),
          ],
        );
    }
  }
}
