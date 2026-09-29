import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape logo picker. Library logos and a gallery upload both set the
/// card logo and return to the editor with that logo selected.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeLogoScreen extends StatefulWidget {
  const VisitingCardLandscapeLogoScreen({
    super.key,
    this.libraryOnly = false,
    this.setCardLogo = false,
  });

  /// Profile Logos page: title and asset grid, without the upload tab.
  final bool libraryOnly;

  /// Sets the card's logo field instead of adding another logo.
  final bool setCardLogo;

  static const _dir = 'assets/visiting_card_scanner_logo';

  static final logos = [
    for (var i = 1; i <= 30; i++) '$_dir/edit_logo_$i.svg',
    '$_dir/Group 1707498097.svg',
    '$_dir/Group 1707498098.svg',
  ];

  static Future<void> open(
    BuildContext context, {
    bool libraryOnly = false,
    bool setCardLogo = false,
  }) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: VisitingCardLandscapeLogoScreen(
            libraryOnly: libraryOnly,
            setCardLogo: setCardLogo,
          ),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeLogoScreen> createState() =>
      _VisitingCardLandscapeLogoScreenState();
}

class _VisitingCardLandscapeLogoScreenState
    extends State<VisitingCardLandscapeLogoScreen> {
  static const _bg = Color(0xFF003303);
  static final _picker = ImagePicker();

  bool _library = true;
  bool _picking = false;

  void _apply(String path) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    if (widget.setCardLogo) {
      vm.applyLogoImage(path);
      vm.selectOverlay(VisitingCardOverlayField.logo);
    } else {
      vm.placeLogo(path);
    }
    Navigator.pop(context);
  }

  Future<void> _upload() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      final vm = context.read<VisitingCardEditContactViewModel>();
      final path = await vm.persistLogoFile(File(picked.path));
      if (!mounted) return;
      _apply(path);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad =
        (MediaQuery.sizeOf(context).shortestSide * 0.035).clamp(12.0, 18.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: _bg,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad + 4, 12, pad, 12),
                child: Row(
                  children: [
                    if (widget.libraryOnly)
                      const Text(
                        'Logos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else ...[
                      _LogoTab(
                        label: 'Logo Library',
                        selected: _library,
                        onTap: () => setState(() => _library = true),
                      ),
                      const SizedBox(width: 10),
                      _LogoTab(
                        label: 'Upload Logo',
                        selected: !_library,
                        onTap: () => setState(() => _library = false),
                      ),
                    ],
                    const Spacer(),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: widget.libraryOnly || _library
                  ? _libraryGrid(pad)
                  : _uploadBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _libraryGrid(double pad) {
    final size = MediaQuery.sizeOf(context);
    final portrait = size.height > size.width;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(pad + 6, 6, pad + 6, 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: portrait ? 4 : 9,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: VisitingCardLandscapeLogoScreen.logos.length,
      itemBuilder: (context, index) {
        final path = VisitingCardLandscapeLogoScreen.logos[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _apply(path),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(path, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  Widget _uploadBody() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Color(0xFF8A8A8A),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload Your Logo',
            style: TextStyle(
              color: Color(0xFF6E6E6E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: const Color(0x00000000),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _picking ? null : _upload,
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF3DCB6A),
                      Color(0xFF149944),
                    ],
                  ),
                ),
                child: const Center(
                  widthFactor: 1,
                  child: Text(
                    'Upload Logo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

class _LogoTab extends StatelessWidget {
  const _LogoTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
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
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected ? null : const Color(0xFF0B3D1A),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF3DCB6A),
                      Color(0xFF149944),
                    ],
                  )
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFE7F2E7),
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
