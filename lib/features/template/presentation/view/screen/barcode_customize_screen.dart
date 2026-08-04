import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/multiple_color_picker.dart';
import 'package:visiting_card/app/helper/qr_color_helper.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';
import 'package:visiting_card/features/template/presentation/view/widget/barcode_template_stack_builder.dart';
import 'package:visiting_card/features/template/presentation/view_model/barcode_customize_viewmodel.dart';

class BarcodeCustomizeScreen extends StatelessWidget {
  const BarcodeCustomizeScreen({
    super.key,
    required this.barcodeData,
    required this.templateIndex,
    required this.typeLabel,
    this.thumbnailAsset,
  });

  final String barcodeData;
  final int templateIndex;
  final String typeLabel;
  final String? thumbnailAsset;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BarcodeCustomizeViewModel(
        initialBarcodeData: barcodeData,
        initialTemplateIndex: templateIndex,
        typeLabel: typeLabel,
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
  late final TextEditingController _headingController;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  void initState() {
    super.initState();
    final vm = context.read<BarcodeCustomizeViewModel>();
    _headingController = TextEditingController(text: vm.headingText);
  }

  @override
  void dispose() {
    _headingController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final vm = context.read<BarcodeCustomizeViewModel>();
    final ok = await vm.saveToGallery(
      homeViewModel: context.read<HomeViewModel>(),
      folderViewModel: context.read<FolderViewModel>(),
    );
    if (!mounted) return;
    if (!ok) {
      ui.AppToast.show(
        context,
        message: 'Save failed',
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }
    ui.AppToast.success(context, 'Saved to gallery');
    context.read<ParentViewModel>().changeIndex(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarcodeCustomizeViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: const Color(0xFF404040)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Barcode',
          style: ui.AppTextStyles.mainText().copyWith(fontSize: 18.sp, letterSpacing: 0),
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
          child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _PreviewCard(vm: vm)),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: _EditorPanel(
              vm: vm,
              headingController: _headingController,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.vm});

  final BarcodeCustomizeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Screenshot(
              controller: vm.screenshotController,
              child: Container(
                // PDF Scanner parity: width 346, no white card chrome.
                width: 346,
                height: vm.templateIndex > 0
                    ? null
                    : vm.isPdf417
                        ? (vm.pdf417Height * 20) + 60
                        : (vm.showHeading ? null : 192),
                margin: const EdgeInsets.only(top: 20),
                color: Colors.transparent,
                child: Center(
                  child: BarcodeTemplateStackBuilder(
                    templateIndex: vm.templateIndex,
                    barcodeData: vm.barcodeData,
                    barcodeType: vm.barcodeType,
                    foregroundColor: vm.foregroundColor,
                    foregroundGradientColors: vm.hasActiveForegroundGradient
                        ? vm.foregroundGradientColors
                        : const [],
                    backgroundColor: vm.backgroundColor,
                    backgroundGradientColors: vm.hasActiveBackgroundGradient
                        ? vm.backgroundGradientColors
                        : const [],
                    hasExplicitBackground: vm.hasExplicitBackground,
                    barcodeHeight: vm.barcodeHeight,
                    pdf417Height: vm.pdf417Height,
                    headingText: vm.displayHeading,
                    showHeading: vm.showHeading,
                    headingColor: vm.headingColor,
                    headingFontSize: vm.headingFontSize,
                    showDetails: vm.showDetails,
                    detailsColor: vm.detailsColor,
                    detailsFontSize: vm.detailsFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.vm,
    required this.headingController,
  });

  final BarcodeCustomizeViewModel vm;
  final TextEditingController headingController;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final selectedTab = vm.selectedTab;
    final contentHeight = selectedTab == null
        ? 0.0
        : switch (selectedTab) {
            // PDF Scanner: keyboard open → panel height 100 (toggle + heading field stay visible).
            BarcodeCustomizeTab.text =>
              keyboardVisible && !vm.isBarCodeDetails ? 100.0 : 256.h,
            BarcodeCustomizeTab.template => 256.h,
            BarcodeCustomizeTab.color => 256.h,
            BarcodeCustomizeTab.height => 120.h,
          };

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabRow(vm: vm),
            if (selectedTab != null)
              ClipRect(
                child: SizedBox(
                  height: contentHeight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      12.w,
                      keyboardVisible &&
                              selectedTab == BarcodeCustomizeTab.text &&
                              !vm.isBarCodeDetails
                          ? 8.h
                          : 12.h,
                      12.w,
                      keyboardVisible &&
                              selectedTab == BarcodeCustomizeTab.text &&
                              !vm.isBarCodeDetails
                          ? 8.h
                          : 12.h,
                    ),
                    child: _TabContent(
                      vm: vm,
                      headingController: headingController,
                      keyboardVisible: keyboardVisible,
                    ),
                  ),
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
      (BarcodeCustomizeTab.template, ui.AppAssets.barTemplateRowTemplate, 'Template'),
      (BarcodeCustomizeTab.color, ui.AppAssets.barTemplateRowColor, 'Color'),
      (BarcodeCustomizeTab.height, ui.AppAssets.barTemplateRowHeight, 'Height'),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _ToolbarTab(
                iconPath: tab.$2,
                label: tab.$3,
                selected: vm.selectedTab == tab.$1,
                onTap: () => vm.setTab(tab.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolbarTab extends StatelessWidget {
  const _ToolbarTab({
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
          // Active tab top indicator (Figma / theme color).
          Container(
            width: 40.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: selected ? _accent : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 30.w,
                  height: 30.w,
                  fit: BoxFit.contain,
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
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.vm,
    required this.headingController,
    required this.keyboardVisible,
  });

  final BarcodeCustomizeViewModel vm;
  final TextEditingController headingController;
  final bool keyboardVisible;

  @override
  Widget build(BuildContext context) {
    final selectedTab = vm.selectedTab;
    if (selectedTab == null) return const SizedBox.shrink();

    switch (selectedTab) {
      case BarcodeCustomizeTab.text:
        return _TextTab(
          vm: vm,
          headingController: headingController,
          keyboardVisible: keyboardVisible,
        );
      case BarcodeCustomizeTab.template:
        return _TemplateTab(vm: vm);
      case BarcodeCustomizeTab.color:
        return _ColorTab(vm: vm);
      case BarcodeCustomizeTab.height:
        return _HeightTab(vm: vm);
    }
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({
    required this.vm,
    required this.headingController,
    required this.keyboardVisible,
  });

  final BarcodeCustomizeViewModel vm;
  final TextEditingController headingController;
  final bool keyboardVisible;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    // Keep TextField in a stable tree position so focus/keyboard is not lost
    // when viewInsets change (QR Text/Logo tab pattern).
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientToggle(
            leftLabel: 'Barcode Details',
            rightLabel: 'Barcode Heading',
            isLeftSelected: vm.isBarCodeDetails,
            onLeftTap: () => vm.setIsBarCodeDetails(true),
            onRightTap: () => vm.setIsBarCodeDetails(false),
          ),
          if (!vm.isBarCodeDetails) ...[
            SizedBox(height: 10.h),
            _HeadingTextField(
              controller: headingController,
              hintText: 'Enter text',
              onChanged: vm.setHeadingText,
              onClear: () {
                headingController.clear();
                vm.setHeadingText('');
              },
            ),
          ],
          if (!keyboardVisible) ...[
            SizedBox(height: 10.h),
            _TextOptionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextSectionLabel('Font Size'),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _accent,
                            inactiveTrackColor: const Color(0xFF4F4E4E),
                            trackHeight: 3,
                            thumbColor: _accent,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: vm.isBarCodeDetails
                                ? vm.detailsFontSize
                                : vm.headingFontSize,
                            min: 8,
                            max: 20,
                            divisions: 12,
                            onChanged: vm.isBarCodeDetails
                                ? vm.setDetailsFontSize
                                : vm.setHeadingFontSize,
                          ),
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            _TextOptionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextSectionLabel('Text Color'),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 32.w,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          BarcodeCustomizeViewModel.textColors.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () => vm.isBarCodeDetails
                                ? vm.setDetailsColor(Colors.black)
                                : vm.setHeadingColor(Colors.black),
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                QrColorHelper.defaultResetIcon,
                              ),
                            ),
                          );
                        }
                        if (index == 1) {
                          return GestureDetector(
                            onTap: () async {
                              final initial = vm.isBarCodeDetails
                                  ? vm.detailsColor
                                  : vm.headingColor;
                              final color = await showMultipleColorPicker(
                                context,
                                initial: initial,
                              );
                              if (color != null) {
                                if (vm.isBarCodeDetails) {
                                  vm.setDetailsColor(color);
                                } else {
                                  vm.setHeadingColor(color);
                                }
                              }
                            },
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                ui.AppAssets.multipleColorIcon,
                              ),
                            ),
                          );
                        }
                        final color =
                            BarcodeCustomizeViewModel.textColors[index - 2];
                        final selected = vm.isBarCodeDetails
                            ? vm.detailsColor == color
                            : vm.headingColor == color;
                        return GestureDetector(
                          onTap: () => vm.isBarCodeDetails
                              ? vm.setDetailsColor(color)
                              : vm.setHeadingColor(color),
                          child: Container(
                            width: 32.w,
                            height: 32.w,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? _accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vm.isBarCodeDetails
                      ? 'Show details in the barcode'
                      : 'Show heading in the barcode',
                  style: ui.AppTextStyles.iconUnderText(
                    color: const Color(0xFF464141),
                  ).copyWith(fontSize: 12.sp),
                ),
                Switch(
                  value: vm.isBarCodeDetails ? vm.showDetails : vm.showHeading,
                  onChanged: vm.isBarCodeDetails
                      ? vm.setShowDetails
                      : vm.setShowHeading,
                  activeTrackColor: _accent.withValues(alpha: 0.35),
                  activeThumbColor: _accent,
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ],
      ),
    );
  }
}

class _TextOptionCard extends StatelessWidget {
  const _TextOptionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeadingTextField extends StatelessWidget {
  const _HeadingTextField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: ui.AppTextStyles.helperText(color: const Color(0xFF1A1A1A))
              .copyWith(fontSize: 14.sp, letterSpacing: 0),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0))
                .copyWith(fontSize: 14.sp, letterSpacing: 0),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: onClear,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: _accent, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: _accent, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: _accent, width: 1.2),
            ),
          ),
        );
      },
    );
  }
}

class _TemplateTab extends StatelessWidget {
  const _TemplateTab({required this.vm});

  final BarcodeCustomizeViewModel vm;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: BarcodeCustomizeViewModel.templateOptions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = BarcodeCustomizeViewModel.templateOptions[index];
        final selected = vm.templateIndex == item.stackTemplateIndex;
        return GestureDetector(
          onTap: () => vm.selectTemplate(item.stackTemplateIndex),
          child: Container(
            width: 53.w,
            height: 53.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? _accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Image.asset(
              item.thumbnailAsset,
              width: 53.w,
              height: 53.w,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _ColorTab extends StatelessWidget {
  const _ColorTab({required this.vm});

  final BarcodeCustomizeViewModel vm;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    final dotSize = 32.w;
    final isForeground = vm.showForegroundOptions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientToggle(
            leftLabel: 'Foreground',
            rightLabel: 'Background',
            isLeftSelected: isForeground,
            onLeftTap: () => vm.setShowForegroundOptions(true),
            onRightTap: () => vm.setShowForegroundOptions(false),
          ),
          SizedBox(height: 10.h),
          _TextOptionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextSectionLabel('Solid Color'),
                SizedBox(height: 10.h),
                SizedBox(
                  height: dotSize,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: QrColorHelper.colorOptions.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final active = isForeground
                            ? vm.foregroundSolidSwatchUi == -1
                            : vm.backgroundSolidSwatchUi == -1;
                        return GestureDetector(
                          onTap: vm.selectDefaultSolid,
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: active
                                  ? _accent.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: active ? _accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: SvgPicture.asset(QrColorHelper.defaultResetIcon),
                          ),
                        );
                      }
                      if (index == 1) {
                        final active = isForeground
                            ? vm.foregroundSolidSwatchUi == -2
                            : vm.backgroundSolidSwatchUi == -2;
                        return GestureDetector(
                          onTap: () async {
                            final initial = isForeground
                                ? vm.foregroundColor
                                : vm.backgroundColor;
                            final color = await showMultipleColorPicker(
                              context,
                              initial: initial,
                            );
                            if (color != null) vm.selectCustomSolidColor(color);
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: active
                                  ? _accent.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: active ? _accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: SvgPicture.asset(ui.AppAssets.multipleColorIcon),
                          ),
                        );
                      }
                      final colorIndex = index - 2;
                      final color = QrColorHelper.colorOptions[colorIndex];
                      final selected = isForeground
                          ? vm.foregroundSolidSwatchUi == colorIndex
                          : vm.backgroundSolidSwatchUi == colorIndex;
                      return GestureDetector(
                        onTap: () => vm.selectSolidColor(colorIndex),
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? _accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          _TextOptionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextSectionLabel('Gradient Color'),
                SizedBox(height: 10.h),
                SizedBox(
                  height: dotSize,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: QrColorHelper.gradientColors.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final active = isForeground
                            ? vm.foregroundGradientSwatchUi == -1
                            : vm.backgroundGradientSwatchUi == -1;
                        return GestureDetector(
                          onTap: vm.selectDefaultGradient,
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: active
                                  ? _accent.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: active ? _accent : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: SvgPicture.asset(QrColorHelper.defaultResetIcon),
                          ),
                        );
                      }
                      final gradientIndex = index - 1;
                      final gradient = QrColorHelper.gradientColors[gradientIndex];
                      final selected = isForeground
                          ? vm.foregroundGradientSwatchUi == gradientIndex
                          : vm.backgroundGradientSwatchUi == gradientIndex;
                      return GestureDetector(
                        onTap: () => vm.selectGradient(gradientIndex),
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? _accent : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _HeightTab extends StatelessWidget {
  const _HeightTab({required this.vm});

  final BarcodeCustomizeViewModel vm;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    final isPdf417 = vm.isPdf417;
    final value = isPdf417
        ? vm.pdf417Height
        : (vm.barcodeHeight < 140
            ? 140.0
            : (vm.barcodeHeight > 160 ? 160.0 : vm.barcodeHeight));
    final label = isPdf417
        ? '${vm.pdf417Height.round()}'
        : '${vm.barcodeHeight.round()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TextOptionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TextSectionLabel('Height'),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _accent,
                        inactiveTrackColor: const Color(0xFF4F4E4E),
                        trackHeight: 3,
                        thumbColor: _accent,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        min: isPdf417 ? 8 : 140,
                        max: isPdf417 ? 10 : 160,
                        divisions: isPdf417 ? 2 : null,
                        onChanged: isPdf417
                            ? vm.setPdf417Height
                            : vm.setBarcodeHeight,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: ui.AppTextStyles.iconUnderText(
                      color: const Color(0xFF464141),
                    ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextSectionLabel extends StatelessWidget {
  const _TextSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ui.AppTextStyles.iconUnderText(color: const Color(0xFF1A1A1A)).copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _GradientToggle extends StatelessWidget {
  const _GradientToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3DCB6A), Color(0xFF0B5D2A)],
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _GradientToggleButton(
                  label: leftLabel,
                  selected: isLeftSelected,
                  onTap: onLeftTap,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _GradientToggleButton(
                  label: rightLabel,
                  selected: !isLeftSelected,
                  onTap: onRightTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientToggleButton extends StatelessWidget {
  const _GradientToggleButton({
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
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? _GradientToggle._gradient : null,
          color: selected ? null : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFFFFFFF) : const Color(0xFF404040),
          ),
        ),
      ),
    );
  }
}