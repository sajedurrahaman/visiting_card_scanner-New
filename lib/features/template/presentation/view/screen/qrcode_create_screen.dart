import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/helper/qr_bar_code_helper.dart';
import 'package:visiting_card/features/template/presentation/helper/qr_barcode_input_helper.dart';
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
  late final TextEditingController _primaryController;
  final _secondaryController = TextEditingController();
  final _tertiaryController = TextEditingController();

  // PDF Scanner contact fields (10).
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController(text: 'http://');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  bool get _isContacts => widget.typeLabel == 'Contacts';

  @override
  void initState() {
    super.initState();
    _primaryController = TextEditingController(
      text: QrBarcodeInputHelper.initialTextForQrType(widget.typeLabel),
    );
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _tertiaryController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
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

    switch (widget.typeLabel) {
      case 'Wi-Fi':
        return 'WIFI:S:$primary;T:WPA;P:$secondary;H:false;;';
      case 'Email':
        return 'mailto:$primary';
      case 'Phone':
        return 'tel:$primary';
      case 'WhatsApp':
        return 'https://wa.me/$primary?text=${Uri.encodeComponent(secondary)}';
      case 'SMS':
        return 'SMSTO:$primary:$secondary';
      case 'Location':
        return 'geo:$primary,$secondary';
      case 'Contacts':
        // Same payload shape as PDF Scanner contactInputForm.
        return 'N:${_lastNameController.text} ${_firstNameController.text}\n'
            'ORG:${_companyController.text}\n'
            'TITLE:${_jobController.text}\n'
            'TEL:${_phoneController.text}\n'
            'EMAIL:${_emailController.text}\n'
            'URL:${_websiteController.text}\n'
            'ADR:${_addressController.text}, ${_cityController.text}, ${_countryController.text}\n';
      case 'Website':
      case 'Facebook':
      case 'Instagram':
      case 'X':
      case 'Spotify':
      case 'Viber':
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
                          if (!_isContacts)
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
                      if (_isContacts)
                        ..._buildContactFields()
                      else ...[
                        _buildPrimaryField(isMultiline),
                        ..._buildExtraFields(),
                      ],
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

  /// PDF Scanner contactInputForm — 10 fields.
  List<Widget> _buildContactFields() {
    return [
      _fieldRow(
        left: _labeledField(
          title: 'First Name:',
          hint: 'Enter Name',
          controller: _firstNameController,
          validator: (v) => QrBarCodeHelper.validateName(v?.trim()),
        ),
        right: _labeledField(
          title: 'Last Name:',
          hint: 'Enter Name',
          controller: _lastNameController,
          validator: (v) => QrBarCodeHelper.validateName(v?.trim()),
        ),
      ),
      SizedBox(height: 10.h),
      _fieldRow(
        left: _labeledField(
          title: 'Company Name:',
          hint: 'Enter Company',
          controller: _companyController,
          validator: (v) => QrBarCodeHelper.validateCompanyName(v?.trim()),
        ),
        right: _labeledField(
          title: 'Job Name:',
          hint: 'Enter Job',
          controller: _jobController,
          validator: (v) => QrBarCodeHelper.validateJobName(v?.trim()),
        ),
      ),
      SizedBox(height: 10.h),
      _fieldRow(
        left: _labeledField(
          title: 'Phone Number:',
          hint: 'Enter Phone',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (v) => QrBarCodeHelper.validatePhoneNumber(v?.trim()),
        ),
        right: _labeledField(
          title: 'Email Address:',
          hint: 'Enter Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              QrBarCodeHelper.validateEmail(v?.toLowerCase().trim()),
        ),
      ),
      SizedBox(height: 10.h),
      _labeledField(
        title: 'Website:',
        hint: 'Enter Web Address',
        controller: _websiteController,
        keyboardType: TextInputType.url,
        validator: (v) =>
            QrBarCodeHelper.validateWebsiteURLForContact((v ?? '').trim()),
      ),
      SizedBox(height: 10.h),
      _labeledField(
        title: 'Address:',
        hint: 'Enter Address',
        controller: _addressController,
        validator: (v) => QrBarCodeHelper.validateAddress(v?.trim()),
      ),
      SizedBox(height: 10.h),
      _fieldRow(
        left: _labeledField(
          title: 'City:',
          hint: 'Enter City',
          controller: _cityController,
          validator: (v) => QrBarCodeHelper.validateCityName(v?.trim()),
        ),
        right: _labeledField(
          title: 'Country:',
          hint: 'Enter Country',
          controller: _countryController,
          validator: (v) => QrBarCodeHelper.validateCountry(v?.trim()),
        ),
      ),
    ];
  }

  Widget _fieldRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 8.w),
        Expanded(child: right),
      ],
    );
  }

  Widget _labeledField({
    required String title,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ui.AppTextStyles.iconUnderText(
            color: const Color(0xFF1A1A1A),
          ).copyWith(fontWeight: FontWeight.w600, fontSize: 11.sp),
        ),
        SizedBox(height: 4.h),
        _extraField(
          controller: controller,
          hint: hint,
          validator: validator,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildPrimaryField(bool isMultiline) {
    final hint = QrBarcodeInputHelper.hintForQrType(widget.typeLabel);

    return TextFormField(
      controller: _primaryController,
      maxLength: _maxLength,
      maxLines: isMultiline ? 6 : 1,
      minLines: isMultiline ? 5 : 1,
      keyboardType: switch (widget.typeLabel) {
        'Email' => TextInputType.emailAddress,
        'Phone' || 'WhatsApp' || 'SMS' => TextInputType.phone,
        'Website' ||
        'Facebook' ||
        'Instagram' ||
        'X' ||
        'Spotify' ||
        'Viber' =>
          TextInputType.url,
        'Location' =>
          const TextInputType.numberWithOptions(decimal: true, signed: true),
        _ => TextInputType.text,
      },
      onChanged: (_) => setState(() {}),
      validator: (value) =>
          QrBarcodeInputHelper.validateQrPrimary(widget.typeLabel, value),
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
        errorMaxLines: 2,
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
            validator: (v) =>
                QrBarcodeInputHelper.validateQrSecondary(widget.typeLabel, v),
          ),
        ];
      case 'SMS':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Type or paste text',
            maxLines: 4,
            validator: (v) =>
                QrBarcodeInputHelper.validateQrSecondary(widget.typeLabel, v),
          ),
        ];
      case 'WhatsApp':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Enter Message',
            maxLines: 4,
            validator: (v) =>
                QrBarcodeInputHelper.validateQrSecondary(widget.typeLabel, v),
          ),
        ];
      case 'Location':
        return [
          SizedBox(height: 12.h),
          _extraField(
            controller: _secondaryController,
            hint: 'Enter Longitude',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (v) =>
                QrBarcodeInputHelper.validateQrSecondary(widget.typeLabel, v),
          ),
        ];
      default:
        return const [];
    }
  }

  Widget _extraField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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
        errorMaxLines: 2,
      ),
    );
  }
}
