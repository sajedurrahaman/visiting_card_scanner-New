import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/helper/visiting_card_qr_payload.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_logo_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_tempalte_qrcode_screen.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape contact profile. Every field from Edit Contact Info is on this
/// one screen. Logo sits on the right: Logos opens the asset grid, Upload
/// opens the gallery.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeProfileScreen extends StatefulWidget {
  const VisitingCardLandscapeProfileScreen({super.key});

  static Future<void> open(BuildContext context) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardLandscapeProfileScreen(),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeProfileScreen> createState() =>
      _VisitingCardLandscapeProfileScreenState();
}

class _VisitingCardLandscapeProfileScreenState
    extends State<VisitingCardLandscapeProfileScreen> {
  static const _bg = Color(0xFF003303);
  static const _green = Color(0xFF149944);
  static const _label = Color(0xFF1A1A1A);
  static final _picker = ImagePicker();

  bool _uploading = false;
  bool _orienting = false;
  bool _committed = false;
  bool _allowPop = false;
  late final VisitingCardEditContactViewModel _vm;

  String? _savedLogoPath;
  bool _savedHasLogo = false;
  String? _savedQrPath;
  bool _savedHasQr = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<VisitingCardEditContactViewModel>();
    _vm = vm;
    _savedLogoPath = vm.logoAssetPath;
    _savedHasLogo = vm.hasChosenLogo;
    _savedQrPath = vm.qrAssetPath;
    _savedHasQr = vm.hasChosenQr;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _revertAssets() {
    if (_committed) return;
    _committed = true;
    _vm.restoreLogoAndQr(
      logoPath: _savedLogoPath,
      hasLogo: _savedHasLogo,
      qrPath: _savedQrPath,
      hasQr: _savedHasQr,
    );
    _vm.clearOverlaySelection();
  }

  Future<void> _close() async {
    if (_allowPop) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _revertAssets();
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _waitUntil({required bool landscape}) async {
    final deadline = DateTime.now().add(const Duration(milliseconds: 1600));
    while (DateTime.now().isBefore(deadline)) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      final ready = landscape
          ? size.width > size.height + 24
          : size.height > size.width + 24;
      if (ready) return;
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> _chooseQr(VisitingCardEditContactViewModel vm) async {
    if (!vm.canEditQr || _orienting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _orienting = true);
    await WidgetsBinding.instance.endOfFrame;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _waitUntil(landscape: false);
    if (!mounted) return;

    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardTempalteQrcodeScreen(
          qrData: VisitingCardQrPayload.fromEditContact(vm),
        ),
      ),
    );

    if (!mounted) return;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await _waitUntil(landscape: true);
    if (!mounted) return;
    setState(() => _orienting = false);
    if (path == null || path.isEmpty) return;
    vm.applyQrImage(path);
    ui.AppToast.success(context, 'QR Code uploaded successfully');
  }

  Future<void> _openLogos() {
    return VisitingCardLandscapeLogoScreen.open(
      context,
      libraryOnly: true,
      setCardLogo: true,
    );
  }

  Future<void> _uploadLogo() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      final vm = context.read<VisitingCardEditContactViewModel>();
      final path = await vm.persistLogoFile(File(picked.path));
      if (!mounted) return;
      vm.applyLogoImage(path);
      vm.selectOverlay(VisitingCardOverlayField.logo);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save(VisitingCardEditContactViewModel vm) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final error = vm.validateRequiredContactFields();
    if (error != null) {
      ui.AppToast.show(
        context,
        message: error,
        backgroundColor: const Color(0xFFE53935),
      );
      return;
    }
    _committed = true;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    final size = MediaQuery.sizeOf(context);
    final pad = (size.shortestSide * 0.03).clamp(12.0, 18.0);
    final sideWidth = (size.width * 0.30).clamp(210.0, 280.0);

    if (_orienting) {
      return const ColoredBox(
        color: _bg,
        child: SizedBox.expand(),
      );
    }

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
          backgroundColor: _bg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad + 6, 12, pad, 8),
              child: Row(
                children: [
                  const Text(
                    'Edit Contact Info',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _close,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(Icons.close, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _fields(vm)),
                    SizedBox(width: pad),
                    SizedBox(
                      width: sideWidth,
                      child: SingleChildScrollView(
                        child: _logoSide(vm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
    );
  }

  Widget _fields(VisitingCardEditContactViewModel vm) {
    return ListView(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      children: [
        if (vm.canEditQr)
          _QrCard(
            enabled: true,
            onTap: () => _chooseQr(vm),
          ),
        _SimpleCard(
          title: 'Name',
          entries: vm.names,
          hasError: vm.isFieldInvalid(ContactValidationField.name),
          maxLength: vm.maxDisplayNameLength,
          onChanged: (i, v) => vm.updateSimpleField(vm.names, i, v),
          onClear: (i) => vm.clearField(vm.names, i),
          onAdd: () => vm.addField(vm.names, defaultType: ''),
          onRemove: (i) => vm.removeField(vm.names, i),
        ),
        _SimpleCard(
          title: 'Designation',
          entries: vm.designations,
          hasError: vm.isFieldInvalid(ContactValidationField.designation),
          onChanged: (i, v) => vm.updateSimpleField(vm.designations, i, v),
          onClear: (i) => vm.clearField(vm.designations, i),
          onAdd: () => vm.addField(vm.designations, defaultType: ''),
          onRemove: (i) => vm.removeField(vm.designations, i),
        ),
        _SimpleCard(
          title: 'Company',
          entries: vm.companies,
          hasError: vm.isFieldInvalid(ContactValidationField.company),
          onChanged: (i, v) => vm.updateSimpleField(vm.companies, i, v),
          onClear: (i) => vm.clearField(vm.companies, i),
          onAdd: () => vm.addField(vm.companies, defaultType: ''),
          onRemove: (i) => vm.removeField(vm.companies, i),
        ),
        _SimpleCard(
          title: 'Company Tagline',
          entries: vm.taglines,
          onChanged: (i, v) => vm.updateSimpleField(vm.taglines, i, v),
          onClear: (i) => vm.clearField(vm.taglines, i),
          onAdd: () => vm.addField(vm.taglines, defaultType: ''),
          onRemove: (i) => vm.removeField(vm.taglines, i),
        ),
        _TypedCard(
          title: 'Tell',
          entries: vm.phones,
          typeOptions: VisitingCardEditContactViewModel.telTypes,
          hasError: vm.isFieldInvalid(ContactValidationField.phone),
          onChanged: (i, v) => vm.updateTypedField(vm.phones, i, value: v),
          onType: (i, t) => vm.updateTypedField(vm.phones, i, type: t),
          onRemove: (i) => vm.removeField(vm.phones, i),
          onAdd: () => vm.addField(vm.phones, defaultType: 'Work'),
        ),
        _TypedCard(
          title: 'Email',
          entries: vm.emails,
          typeOptions: VisitingCardEditContactViewModel.emailWebsiteTypes,
          hasError: vm.isFieldInvalid(ContactValidationField.email),
          onChanged: (i, v) => vm.updateTypedField(vm.emails, i, value: v),
          onType: (i, t) => vm.updateTypedField(vm.emails, i, type: t),
          onRemove: (i) => vm.removeField(vm.emails, i),
          onAdd: () => vm.addField(vm.emails, defaultType: 'Company'),
        ),
        _TypedCard(
          title: 'Website',
          entries: vm.websites,
          typeOptions: VisitingCardEditContactViewModel.emailWebsiteTypes,
          onChanged: (i, v) => vm.updateTypedField(vm.websites, i, value: v),
          onType: (i, t) => vm.updateTypedField(vm.websites, i, type: t),
          onRemove: (i) => vm.removeField(vm.websites, i),
          onAdd: () => vm.addField(vm.websites, defaultType: 'Company'),
        ),
        _SimpleCard(
          title: 'Address',
          entries: vm.addresses,
          hasError: vm.isFieldInvalid(ContactValidationField.address),
          onChanged: (i, v) => vm.updateSimpleField(vm.addresses, i, v),
          onClear: (i) => vm.clearField(vm.addresses, i),
          onAdd: () => vm.addField(vm.addresses, defaultType: ''),
          onRemove: (i) => vm.removeField(vm.addresses, i),
        ),
      ],
    );
  }

  Widget _logoSide(VisitingCardEditContactViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.canEditLogo) ...[
          const Text(
            'Upload your logo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(label: 'Logos', onTap: _openLogos),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlineButton(
                  label: 'Upload',
                  onTap: _uploading ? null : _uploadLogo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        _SaveButton(onTap: () => _save(vm)),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'QR Code',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _VisitingCardLandscapeProfileScreenState._label,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Material(
            color: const Color(0x00000000),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: enabled
                      ? const LinearGradient(
                          colors: [Color(0xFF3DCB6A), Color(0xFF149944)],
                        )
                      : null,
                  color: enabled ? null : const Color(0xFFD9D9D9),
                ),
                child: const Center(
                  widthFactor: 1,
                  child: Text(
                    'Choose QR Code',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.title,
    required this.entries,
    required this.onChanged,
    required this.onClear,
    required this.onAdd,
    required this.onRemove,
    this.hasError = false,
    this.maxLength,
  });

  final String title;
  final List<ContactFieldEntry> entries;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onClear;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final bool hasError;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: hasError
            ? Border.all(color: const Color(0x88E53935))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: hasError
                        ? const Color(0xFFE53935)
                        : _VisitingCardLandscapeProfileScreenState._green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _RoundIcon(
                asset: ui.AppAssets.visitingTemplateAddIcon,
                onTap: onAdd,
              ),
            ],
          ),
          for (var i = 0; i < entries.length; i++)
            _ValueRow(
              value: entries[i].value,
              maxLength: maxLength,
              hasError: hasError && i == 0,
              onChanged: (v) => onChanged(i, v),
              onClear: () => i == 0 ? onClear(i) : onRemove(i),
            ),
        ],
      ),
    );
  }
}

class _TypedCard extends StatelessWidget {
  const _TypedCard({
    required this.title,
    required this.entries,
    required this.typeOptions,
    required this.onChanged,
    required this.onType,
    required this.onRemove,
    required this.onAdd,
    this.hasError = false,
  });

  final String title;
  final List<ContactFieldEntry> entries;
  final List<String> typeOptions;
  final void Function(int index, String value) onChanged;
  final void Function(int index, String type) onType;
  final void Function(int index) onRemove;
  final VoidCallback onAdd;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: hasError
            ? Border.all(color: const Color(0x88E53935))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: hasError
                        ? const Color(0xFFE53935)
                        : _VisitingCardLandscapeProfileScreenState._green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _RoundIcon(
                asset: ui.AppAssets.visitingTemplateAddIcon,
                onTap: onAdd,
              ),
            ],
          ),
          for (var i = 0; i < entries.length; i++)
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: typeOptions.contains(entries[i].type)
                          ? entries[i].type
                          : typeOptions.first,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Color(0xFF9E9E9E),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _VisitingCardLandscapeProfileScreenState._label,
                      ),
                      items: [
                        for (final type in typeOptions)
                          DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) onType(i, value);
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: _ValueRow(
                    value: entries[i].value,
                    hasError: hasError && i == 0,
                    onChanged: (v) => onChanged(i, v),
                    onClear: () => onRemove(i),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatefulWidget {
  const _ValueRow({
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.hasError = false,
    this.maxLength,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasError;
  final int? maxLength;

  @override
  State<_ValueRow> createState() => _ValueRowState();
}

class _ValueRowState extends State<_ValueRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ValueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.hasError
        ? const Color(0xFFE53935)
        : const Color(0xFFE0E0E0);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onTapOutside: (_) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            style: const TextStyle(
              color: _VisitingCardLandscapeProfileScreenState._label,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: line),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _VisitingCardLandscapeProfileScreenState._green,
                ),
              ),
            ),
          ),
        ),
        _RoundIcon(
          asset: ui.AppAssets.visitingTemplateCrossIcon,
          onTap: widget.onClear,
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: SvgPicture.asset(asset, width: 16, height: 16),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8FBF96)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFF3DCB6A), Color(0xFF0E8A3A)],
            ),
          ),
          child: const Center(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
