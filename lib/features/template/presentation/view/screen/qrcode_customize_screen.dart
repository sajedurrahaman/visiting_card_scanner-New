import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:visiting_card/app/helper/multiple_color_picker.dart';
import 'package:visiting_card/app/helper/qr_color_helper.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/folder/presentation/view_model/folder_viewmodel.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qr_template_stack_builder.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qrcode_category_chip.dart';
import 'package:visiting_card/features/template/presentation/view_model/qrcode_customize_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/qrcode_template_viewmodel.dart';

class QrcodeCustomizeScreen extends StatelessWidget {
  const QrcodeCustomizeScreen({
    super.key,
    required this.qrData,
    required this.templateIndex,
    this.thumbnailAsset,
  });

  final String qrData;
  final int templateIndex;
  final String? thumbnailAsset;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QrcodeCustomizeViewModel(
        initialQrData: qrData,
        initialTemplateIndex: templateIndex,
        thumbnailAsset: thumbnailAsset,
      ),
      child: const _QrcodeCustomizeBody(),
    );
  }
}

class _QrcodeCustomizeBody extends StatefulWidget {
  const _QrcodeCustomizeBody();

  @override
  State<_QrcodeCustomizeBody> createState() => _QrcodeCustomizeBodyState();
}

class _QrcodeCustomizeBodyState extends State<_QrcodeCustomizeBody> {
  late final TextEditingController _overlayController;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  void initState() {
    super.initState();
    _overlayController = TextEditingController(
      text: context.read<QrcodeCustomizeViewModel>().overlayText,
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final vm = context.read<QrcodeCustomizeViewModel>();
    final ok = await vm.saveToGallery(
      homeViewModel: context.read<HomeViewModel>(),
      folderViewModel: context.read<FolderViewModel>(),
    );
    if (!mounted) return;
    ui.AppToast.success(context, ok ? 'Saved to gallery' : 'Save failed');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QrcodeCustomizeViewModel>();

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
          'QR Code',
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
          child: const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _PreviewCard(vm: vm)),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _EditorPanel(
              vm: vm,
              overlayController: _overlayController,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.vm});

  final QrcodeCustomizeViewModel vm;

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
                constraints: BoxConstraints(
                  minWidth: 210.w,
                  maxWidth: 320.w,
                ),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 230.w,
                      height: 230.w,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: _GradientQrPreview(
                          fontWeightFor: _fontWeightFor,
                          fontStyleFor: _fontStyleFor,
                        ),
                      ),
                    ),
                    if (vm.overlayText.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 16.h,
                          left: 10.w,
                          right: 10.w,
                        ),
                        child: Text(
                          vm.overlayText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: ui.AppFonts.sfPro,
                            fontSize: vm.overlayFontSize.sp,
                            fontWeight: _fontWeightFor(vm.selectedFontStyleIndex),
                            fontStyle: _fontStyleFor(vm.selectedFontStyleIndex),
                            color: vm.overlayTextColor,
                            letterSpacing:
                                vm.selectedFontStyleIndex == 4 ? 1.5 : 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static FontWeight _fontWeightFor(int index) {
    const weights = [
      FontWeight.w700,
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w400,
      FontWeight.w600,
      FontWeight.w800,
      FontWeight.w200,
      FontWeight.w900,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w700,
    ];
    return weights[index.clamp(0, weights.length - 1)];
  }

  static FontStyle _fontStyleFor(int index) {
    return index == 3 || index == 7 || index == 10
        ? FontStyle.italic
        : FontStyle.normal;
  }

}

class _GradientQrPreview extends StatelessWidget {
  const _GradientQrPreview({
    required this.fontWeightFor,
    required this.fontStyleFor,
  });

  final FontWeight Function(int index) fontWeightFor;
  final FontStyle Function(int index) fontStyleFor;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QrcodeCustomizeViewModel>();
    return QrTemplateStackBuilder(
      templateIndex: vm.templateIndex,
      qrData: vm.qrData.isEmpty ? 'https://example.com' : vm.qrData,
      eyeShape: vm.eyeShape,
      dotShape: vm.dotShape,
      foregroundColor: vm.foregroundColor,
      foregroundGradientColors: vm.hasActiveForegroundGradient
          ? vm.foregroundGradientColors
          : null,
      backgroundColor: vm.backgroundColor,
      backgroundGradientColors: vm.hasActiveBackgroundGradient
          ? vm.backgroundGradientColors
          : const [],
      backgroundImage: vm.selectedBackgroundImage,
      logoAsset: vm.selectedLogoAsset,
      logoText: vm.logoText,
      logoSize: vm.logoSize,
      logoTextColor: vm.logoTextColor,
      logoFontSize: vm.logoFontSize,
      logoFontWeight: fontWeightFor(vm.selectedLogoFontStyleIndex),
      logoFontStyle: fontStyleFor(vm.selectedLogoFontStyleIndex),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.vm,
    required this.overlayController,
  });

  final QrcodeCustomizeViewModel vm;
  final TextEditingController overlayController;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final selectedTab = vm.selectedTab;
    final contentHeight = selectedTab == null
        ? 0.0
        : switch (selectedTab) {
            QrCustomizeTab.text => keyboardVisible ? 64.h : 256.h,
            QrCustomizeTab.template => 256.h,
            QrCustomizeTab.color => 256.h,
            QrCustomizeTab.logo => keyboardVisible ? 64.h : 256.h,
            _ => 160.h,
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
              SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  child: _TabContent(
                    vm: vm,
                    overlayController: overlayController,
                    keyboardVisible: keyboardVisible,
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

  final QrcodeCustomizeViewModel vm;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (QrCustomizeTab.text, ui.AppAssets.qrTemplateRowIconText, 'Text'),
      (QrCustomizeTab.template, ui.AppAssets.qrTemplateRowIconTemplate, 'Template'),
      (QrCustomizeTab.color, ui.AppAssets.qrTemplateRowIconColor, 'Color'),
      (QrCustomizeTab.logo, ui.AppAssets.qrTemplateRowIconLogo, 'Logo'),
      (QrCustomizeTab.dots, ui.AppAssets.qrTemplateRowIconDot, 'Dots'),
      (QrCustomizeTab.eyes, ui.AppAssets.qrTemplateRowIconEye, 'Eyes'),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
            clipBehavior: Clip.none,
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
              width: 55.w,
              height: 55.w,
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
  const _TabContent({
    required this.vm,
    required this.overlayController,
    required this.keyboardVisible,
  });

  final QrcodeCustomizeViewModel vm;
  final TextEditingController overlayController;
  final bool keyboardVisible;

  @override
  Widget build(BuildContext context) {
    final selectedTab = vm.selectedTab;
    if (selectedTab == null) {
      return const SizedBox.shrink();
    }

    switch (selectedTab) {
      case QrCustomizeTab.text:
        return _TextTab(
          vm: vm,
          controller: overlayController,
          keyboardVisible: keyboardVisible,
        );
      case QrCustomizeTab.template:
        return _TemplateTab(vm: vm);
      case QrCustomizeTab.color:
        return _ColorTab(vm: vm);
      case QrCustomizeTab.logo:
        return _LogoTab(
          vm: vm,
          controller: overlayController,
          keyboardVisible: keyboardVisible,
        );
      case QrCustomizeTab.dots:
        return _ShapeGrid(
          options: vm.dotOptions,
          crossAxisCount: 4,
          isSelected: (shape) => shape == vm.dotShape,
          onTap: (shape) => vm.selectDotShape(shape as QrDataModuleShape),
        );
      case QrCustomizeTab.eyes:
        return _ShapeGrid(
          options: vm.eyeOptions,
          iconPadding: EdgeInsets.all(6.w),
          isSelected: (shape) => shape == vm.eyeShape,
          onTap: (shape) => vm.selectEyeShape(shape as QrEyeShape),
        );
    }
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({
    required this.vm,
    required this.controller,
    required this.keyboardVisible,
  });

  final QrcodeCustomizeViewModel vm;
  final TextEditingController controller;
  final bool keyboardVisible;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OverlayTextField(
          controller: controller,
          onChanged: vm.setOverlayText,
          onClear: () {
            controller.clear();
            vm.clearOverlayText();
          },
        ),
        if (!keyboardVisible)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  _OptionCard(
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
                                fontSize: 12.sp,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: _accent,
                                  inactiveTrackColor: const Color(0xFF4F4E4E),
                                  trackHeight: 4,
                                  thumbColor: _accent,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                ),
                                child: Slider(
                                  value: vm.overlayFontSize,
                                  min: 10,
                                  max: 28,
                                  onChanged: vm.setOverlayFontSize,
                                ),
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 18.sp,
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
                  _OptionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TextSectionLabel('Text Color'),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 32.w,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: QrcodeCustomizeViewModel.textColors.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final active = vm.overlaySolidSwatchUi == -1;
                                return GestureDetector(
                                  onTap: vm.selectDefaultOverlayColor,
                                  child: Container(
                                    width: 32.w,
                                    height: 32.w,
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
                                final active = vm.overlaySolidSwatchUi == -2;
                                return GestureDetector(
                                  onTap: () async {
                                    final color = await showMultipleColorPicker(
                                      context,
                                      initial: vm.overlayTextColor,
                                    );
                                    if (color != null) {
                                      vm.selectCustomOverlayColor(color);
                                    }
                                  },
                                  child: Container(
                                    width: 32.w,
                                    height: 32.w,
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
                              final color =
                                  QrcodeCustomizeViewModel.textColors[colorIndex];
                              return GestureDetector(
                                onTap: () => vm.selectOverlaySolidColor(colorIndex),
                                child: Container(
                                  width: 32.w,
                                  height: 32.w,
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: vm.overlaySolidSwatchUi == colorIndex
                                          ? _accent
                                          : Colors.transparent,
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
                  _OptionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TextSectionLabel('Font Style'),
                        SizedBox(height: 8.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: QrcodeCustomizeViewModel.fontStyleLabels.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 6.w,
                            mainAxisSpacing: 6.h,
                            childAspectRatio: 2.8,
                          ),
                          itemBuilder: (context, index) {
                            final selected = vm.selectedFontStyleIndex == index;
                            return GestureDetector(
                              onTap: () => vm.setFontStyleIndex(index),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: selected ? _accent : const Color(0xFFE0E0E0),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  'fonts',
                                  style: TextStyle(
                                    fontFamily: ui.AppFonts.sfPro,
                                    fontSize: 10.sp,
                                    fontWeight: _PreviewCard._fontWeightFor(index),
                                    fontStyle: _PreviewCard._fontStyleFor(index),
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      style: ui.AppTextStyles.iconUnderText(
        color: const Color(0xFF1A1A1A),
      ).copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.child});

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

class _OverlayTextField extends StatelessWidget {
  const _OverlayTextField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
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
            hintText: 'Enter text',
            hintStyle: ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0))
                .copyWith(fontSize: 14.sp, letterSpacing: 0),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
              icon: Icon(Icons.close, size: 16.sp, color: const Color(0xFF9E9E9E)),
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

  final QrcodeCustomizeViewModel vm;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    final templates = vm.templatesForCategory(vm.templateCategory);
    return Column(
      children: [
        SizedBox(
          height: QrcodeCategoryChip.chipSize.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: QrcodeTemplateViewModel.categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = QrcodeTemplateViewModel.categories[index];
              return QrcodeCategoryChip(
                icon: category.icon,
                label: category.label,
                isSelected: vm.templateCategory == category.category,
                onTap: () => vm.setTemplateCategory(category.category),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: templates.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = templates[index];
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
                  child: item.isNone
                      ? Image.asset(
                          ui.AppAssets.noneIconOne,
                          width: 53.w,
                          height: 53.w,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          item.thumbnailAsset,
                          width: 53.w,
                          height: 53.w,
                          fit: BoxFit.contain,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ColorTab extends StatelessWidget {
  const _ColorTab({required this.vm});

  final QrcodeCustomizeViewModel vm;

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
          _OptionCard(
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
                            if (color != null) {
                              vm.selectCustomSolidColor(color);
                            }
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
                            child:
                                SvgPicture.asset(ui.AppAssets.multipleColorIcon),
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
          _OptionCard(
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
                      final gradient =
                          QrColorHelper.gradientColors[gradientIndex];
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
          if (!isForeground) ...[
            SizedBox(height: 10.h),
            _OptionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextSectionLabel('Images'),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 35.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: QrColorHelper.backgroundImages.length + 1,
                      itemBuilder: (context, index) {
                        const thumbSize = 35.0;
                        if (index == 0) {
                          final active = vm.backgroundImageSwatchUi == -1 ||
                              vm.selectedBackgroundImage == null;
                          return GestureDetector(
                            onTap: vm.resetBackgroundImage,
                            child: Container(
                              margin: EdgeInsets.only(right: 8.w),
                              height: thumbSize.w,
                              width: thumbSize.w,
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: active
                                    ? _accent.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: active ? _accent : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child:
                                  SvgPicture.asset(QrColorHelper.defaultResetIcon),
                            ),
                          );
                        }
                        final imageIndex = index - 1;
                        if (imageIndex < 0 ||
                            imageIndex >=
                                QrColorHelper.backgroundImages.length) {
                          return const SizedBox.shrink();
                        }
                        final imagePath =
                            QrColorHelper.backgroundImages[imageIndex];
                        final selected =
                            vm.selectedBackgroundImage == imagePath;
                        return GestureDetector(
                          onTap: () => vm.selectBackgroundImage(imageIndex),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: thumbSize.w,
                            width: thumbSize.w,
                            decoration: BoxDecoration(
                              color:
                                  selected ? Colors.white : Colors.transparent,
                              border: Border.all(
                                color: selected ? _accent : Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.transparent,
                              backgroundImage: AssetImage(imagePath),
                              radius: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _LogoTab extends StatelessWidget {
  const _LogoTab({
    required this.vm,
    required this.controller,
    required this.keyboardVisible,
  });

  final QrcodeCustomizeViewModel vm;
  final TextEditingController controller;
  final bool keyboardVisible;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    final logoTextController = TextEditingController(text: vm.logoText);
    logoTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: logoTextController.text.length),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.logoMode == QrLogoMode.text) ...[
            _LogoTextField(
              controller: logoTextController,
              onChanged: vm.setLogoText,
              onClear: vm.clearLogoText,
            ),
            if (!keyboardVisible) ...[
              SizedBox(height: 12.h),
              _GradientToggle(
                leftLabel: 'Image',
                rightLabel: 'Text',
                isLeftSelected: vm.logoMode == QrLogoMode.image,
                onLeftTap: () => vm.setLogoMode(QrLogoMode.image),
                onRightTap: () => vm.setLogoMode(QrLogoMode.text),
              ),
              SizedBox(height: 10.h),
              _OptionCard(
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
                            fontSize: 12.sp,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _accent,
                              inactiveTrackColor: const Color(0xFF4F4E4E),
                              trackHeight: 4,
                              thumbColor: _accent,
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: vm.logoFontSize,
                              min: 8,
                              max: 10,
                              divisions: 2,
                              onChanged: vm.setLogoFontSize,
                            ),
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 18.sp,
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
              _OptionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TextSectionLabel('Color'),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 32.w,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: QrColorHelper.colorOptions.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final active = vm.logoSolidSwatchUi == -1;
                            return GestureDetector(
                              onTap: vm.selectDefaultLogoColor,
                              child: Container(
                                width: 32.w,
                                height: 32.w,
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
                                child: SvgPicture.asset(
                                  QrColorHelper.defaultResetIcon,
                                ),
                              ),
                            );
                          }
                          if (index == 1) {
                            final active = vm.logoSolidSwatchUi == -2;
                            return GestureDetector(
                              onTap: () async {
                                final color = await showMultipleColorPicker(
                                  context,
                                  initial: vm.logoTextColor,
                                );
                                if (color != null) {
                                  vm.selectCustomLogoColor(color);
                                }
                              },
                              child: Container(
                                width: 32.w,
                                height: 32.w,
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
                                child: SvgPicture.asset(
                                  ui.AppAssets.multipleColorIcon,
                                ),
                              ),
                            );
                          }
                          final colorIndex = index - 2;
                          final color = QrColorHelper.colorOptions[colorIndex];
                          return GestureDetector(
                            onTap: () => vm.selectLogoSolidColor(colorIndex),
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: vm.logoSolidSwatchUi == colorIndex
                                      ? _accent
                                      : Colors.transparent,
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
              _OptionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TextSectionLabel('Font Style'),
                    SizedBox(height: 8.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          QrcodeCustomizeViewModel.fontStyleLabels.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 6.w,
                        mainAxisSpacing: 6.h,
                        childAspectRatio: 2.8,
                      ),
                      itemBuilder: (context, index) {
                        final selected =
                            vm.selectedLogoFontStyleIndex == index;
                        return GestureDetector(
                          onTap: () => vm.setLogoFontStyleIndex(index),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: selected
                                    ? _accent
                                    : const Color(0xFFE0E0E0),
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              'fonts',
                              style: TextStyle(
                                fontFamily: ui.AppFonts.sfPro,
                                fontSize: 10.sp,
                                fontWeight:
                                    _PreviewCard._fontWeightFor(index),
                                fontStyle: _PreviewCard._fontStyleFor(index),
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            _GradientToggle(
              leftLabel: 'Image',
              rightLabel: 'Text',
              isLeftSelected: vm.logoMode == QrLogoMode.image,
              onLeftTap: () => vm.setLogoMode(QrLogoMode.image),
              onRightTap: () => vm.setLogoMode(QrLogoMode.text),
            ),
            SizedBox(height: 12.h),
            _OptionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextSectionLabel('Size'),
                  SizedBox(height: 8.h),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _accent,
                      inactiveTrackColor: const Color(0xFF4F4E4E),
                      trackHeight: 4,
                      thumbColor: _accent,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: vm.logoSize,
                      min: 10,
                      max: 25,
                      divisions: 10,
                      onChanged: vm.setLogoSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            _OptionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextSectionLabel('Image'),
                  SizedBox(height: 10.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: QrColorHelper.logoOptions.length + 2,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final selected = !vm.hasLogoAsset;
                        return GestureDetector(
                          onTap: vm.clearSelectedLogo,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _accent.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: selected ? _accent : Colors.transparent,
                              ),
                            ),
                            child: SvgPicture.asset(
                              QrColorHelper.defaultResetIcon,
                            ),
                          ),
                        );
                      }
                      if (index == 1) {
                        final selected = vm.hasPickedLogo;
                        return GestureDetector(
                          onTap: () async {
                            final image = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              vm.selectPickedLogo(image.path);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _accent.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: selected ? _accent : Colors.transparent,
                              ),
                            ),
                            child: SvgPicture.asset(
                              QrColorHelper.imageAddIcon,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }
                      final logoIndex = index - 2;
                      final asset = QrColorHelper.logoOptions[logoIndex];
                      final selected = vm.selectedLogoIndex == logoIndex;
                      return GestureDetector(
                        onTap: () => vm.selectLogoAsset(logoIndex),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: selected
                                ? _accent.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: selected ? _accent : Colors.transparent,
                            ),
                          ),
                          child: SvgPicture.asset(asset, fit: BoxFit.contain),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogoTextField extends StatelessWidget {
  const _LogoTextField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
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
            hintText: 'Enter text',
            hintStyle: ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0))
                .copyWith(fontSize: 14.sp, letterSpacing: 0),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close, size: 16.sp, color: const Color(0xFF9E9E9E)),
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

class _ShapeGrid extends StatelessWidget {
  const _ShapeGrid({
    required this.options,
    required this.isSelected,
    required this.onTap,
    this.crossAxisCount = 5,
    this.iconPadding,
  });

  final List<Map<String, dynamic>> options;
  final bool Function(dynamic shape) isSelected;
  final void Function(dynamic shape) onTap;
  final int crossAxisCount;
  final EdgeInsetsGeometry? iconPadding;

  static const _accent = ui.Colors.parentIconSelectTextColor;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final shape = option['shape'];
        final selected = isSelected(shape);
        return GestureDetector(
          onTap: () => onTap(shape),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: selected ? _accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            padding: iconPadding,
            child: SvgPicture.asset(
              option['image'] as String,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
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
    colors: [
      Color(0xFF3DCB6A),
      Color(0xFF0B5D2A),
    ],
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
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFFFFFFF) : const Color(0xFF404040),
          ),
        ),
      ),
    );
  }
}
