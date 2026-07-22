import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view/screen/barcode_customize_screen.dart';

class BarcodeCreateScreen extends StatefulWidget {
  const BarcodeCreateScreen({
    super.key,
    required this.typeLabel,
    required this.templateIndex,
    this.thumbnailAsset,
  });

  final String typeLabel;
  final int templateIndex;
  final String? thumbnailAsset;

  @override
  State<BarcodeCreateScreen> createState() => _BarcodeCreateScreenState();
}

class _BarcodeCreateScreenState extends State<BarcodeCreateScreen> {
  static const _maxLength = 300;

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _typeIcon {
    switch (widget.typeLabel) {
      case 'ISBN':
        return ui.AppAssets.barIsbn;
      case 'ITF':
        return ui.AppAssets.barItf;
      case 'ITF-14':
        return ui.AppAssets.barItf14;
      case 'MSI':
        return ui.AppAssets.barMsi;
      case 'PDF417':
        return ui.AppAssets.barPdf417;
      case 'UPC-A':
        return ui.AppAssets.barUpcA;
      case 'UPC-E':
        return ui.AppAssets.barUpcE;
      case 'EAN-13':
        return ui.AppAssets.barEan13;
      case 'EAN-8':
        return ui.AppAssets.barEan8;
      case 'Data Matrix':
        return ui.AppAssets.barDataMatrix;
      case 'Code 128':
        return ui.AppAssets.barCode128;
      case 'Code 93':
        return ui.AppAssets.barCode93;
      case 'Code 39':
        return ui.AppAssets.barCode39;
      case 'Codabar':
        return ui.AppAssets.barCodaBar;
      default:
        return ui.AppAssets.barGeneralTypes;
    }
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeCustomizeScreen(
          barcodeData: _controller.text.trim(),
          templateIndex: widget.templateIndex,
          typeLabel: widget.typeLabel,
          thumbnailAsset: widget.thumbnailAsset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create', style: ui.AppTextStyles.mainText()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0E0),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              _typeIcon,
                              width: 18.w,
                              height: 18.w,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              '${widget.typeLabel} :',
                              style: ui.AppTextStyles.helperText(
                                color: const Color(0xFF1A1A1A),
                              ).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (_, value, _) {
                              return Text(
                                '${value.text.length}/$_maxLength',
                                style: ui.AppTextStyles.iconUnderText(
                                  color: const Color(0xFF9E9E9E),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _controller,
                        maxLength: _maxLength,
                        maxLines: 5,
                        minLines: 4,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Type or paste text',
                          hintStyle: ui.AppTextStyles.helperText(
                            color: const Color(0xFFB0B0B0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFFFF),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E5E5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E5E5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: ui.Colors.parentIconSelectTextColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DCB6A), Color(0xFF0B5D2A)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _onCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0x00000000),
                        shadowColor: const Color(0x00000000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Create',
                        style: ui.AppTextStyles.helperText(
                          color: const Color(0xFFFFFFFF),
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
