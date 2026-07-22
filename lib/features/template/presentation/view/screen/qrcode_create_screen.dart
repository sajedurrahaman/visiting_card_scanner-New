import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view/screen/qrcode_customize_screen.dart';

class QrcodeCreateScreen extends StatefulWidget {
  const QrcodeCreateScreen({
    super.key,
    required this.typeLabel,
    required this.templateIndex,
    this.thumbnailAsset,
  });

  final String typeLabel;
  final int templateIndex;
  final String? thumbnailAsset;

  @override
  State<QrcodeCreateScreen> createState() => _QrcodeCreateScreenState();
}

class _QrcodeCreateScreenState extends State<QrcodeCreateScreen> {
  static const _maxLength = 300;

  final _formKey = GlobalKey<FormState>();
  final _primaryController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _tertiaryController = TextEditingController();

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _tertiaryController.dispose();
    super.dispose();
  }

  String get _typeIcon {
    switch (widget.typeLabel) {
      case 'Website':
        return ui.AppAssets.qrDialogWebsite;
      case 'Wi-Fi':
        return ui.AppAssets.qrDialogWifi;
      case 'Text':
        return ui.AppAssets.qrDialogText;
      case 'Contacts':
        return ui.AppAssets.qrDialogContacts;
      case 'SMS':
        return ui.AppAssets.qrDialogSms;
      case 'Phone':
        return ui.AppAssets.qrDialogPhone;
      case 'Location':
        return ui.AppAssets.qrDialogLocation;
      case 'WhatsApp':
        return ui.AppAssets.qrDialogWhatsapp;
      case 'Facebook':
        return ui.AppAssets.qrDialogFacebook;
      case 'Instagram':
        return ui.AppAssets.qrDialogInstagram;
      case 'Email':
        return ui.AppAssets.qrDialogEmail;
      case 'Viber':
        return ui.AppAssets.qrDialogViber;
      case 'X':
        return ui.AppAssets.qrDialogX;
      case 'Spotify':
        return ui.AppAssets.qrDialogSpotify;
      case 'Product':
        return ui.AppAssets.qrDialogProduct;
      default:
        return ui.AppAssets.qrDialogText;
    }
  }

  String _buildQrData() {
    final primary = _primaryController.text.trim();
    final secondary = _secondaryController.text.trim();
    final tertiary = _tertiaryController.text.trim();

    switch (widget.typeLabel) {
      case 'Website':
        if (primary.startsWith('http://') || primary.startsWith('https://')) {
          return primary;
        }
        return 'https://$primary';
      case 'Wi-Fi':
        return 'WIFI:T:WPA;S:$primary;P:$secondary;;';
      case 'Email':
        return 'mailto:$primary';
      case 'Phone':
      case 'WhatsApp':
      case 'Viber':
        return 'tel:$primary';
      case 'SMS':
        return 'SMSTO:$primary:$secondary';
      case 'Location':
        return 'geo:$primary,$secondary';
      case 'Contacts':
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$primary\nTEL:$secondary\nEMAIL:$tertiary\nEND:VCARD';
      case 'Facebook':
      case 'Instagram':
      case 'X':
      case 'Spotify':
      case 'Product':
        return primary;
      case 'Text':
      default:
        return primary;
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
        builder: (_) => QrcodeCustomizeScreen(
          qrData: _buildQrData(),
          templateIndex: widget.templateIndex,
          thumbnailAsset: widget.thumbnailAsset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMultiline = widget.typeLabel == 'Text' ||
        widget.typeLabel == 'SMS' ||
        widget.typeLabel == 'Product';

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
                            valueListenable: _primaryController,
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
                      _buildPrimaryField(isMultiline),
                      ..._buildExtraFields(),
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

  Widget _buildPrimaryField(bool isMultiline) {
    final hint = switch (widget.typeLabel) {
      'Website' => 'Enter website URL',
      'Wi-Fi' => 'Enter network name (SSID)',
      'Email' => 'Enter email address',
      'Phone' || 'WhatsApp' || 'Viber' => 'Enter phone number',
      'SMS' => 'Enter phone number',
      'Location' => 'Enter latitude',
      'Contacts' => 'Enter full name',
      'Facebook' ||
      'Instagram' ||
      'X' ||
      'Spotify' ||
      'Product' =>
        'Enter link or text',
      _ => 'Type or paste text',
    };

    return TextFormField(
      controller: _primaryController,
      maxLength: _maxLength,
      maxLines: isMultiline ? 6 : 1,
      minLines: isMultiline ? 5 : 1,
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0)),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: ui.Colors.parentIconSelectTextColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExtraFields() {
    switch (widget.typeLabel) {
      case 'Wi-Fi':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Enter password',
            requiredField: true,
          ),
        ];
      case 'SMS':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Type or paste text',
            maxLines: 4,
            requiredField: true,
          ),
        ];
      case 'Location':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Enter longitude',
            requiredField: true,
          ),
        ];
      case 'Contacts':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Enter phone number',
            requiredField: false,
          ),
          SizedBox(height: 12.h),
          _extraField(
            controller: _tertiaryController,
            hint: 'Enter email',
            requiredField: false,
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _extraField({
    required TextEditingController controller,
    required String hint,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ui.AppTextStyles.helperText(color: const Color(0xFFB0B0B0)),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: ui.Colors.parentIconSelectTextColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
