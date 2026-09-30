import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/domain/visiting_card_font_style.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape Font style picker. Changes apply to the selected field.
///
/// Left ~40% = font list; right = live card Preview + Cancel / Apply.
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeFontStyleScreen extends StatefulWidget {
  const VisitingCardLandscapeFontStyleScreen({super.key});

  static Future<void> open(BuildContext context) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardLandscapeFontStyleScreen(),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeFontStyleScreen> createState() =>
      _VisitingCardLandscapeFontStyleScreenState();
}

class _VisitingCardLandscapeFontStyleScreenState
    extends State<VisitingCardLandscapeFontStyleScreen> {
  static const _bg = Color(0xFF003303);
  static const _previewPanelBg = Color(0xFF003C1C);
  static const _previewPanelBorder = Color(0xFF004C1C);
  static const _previewDivider = Color(0xFF295E43);
  static const _previewCardFrame = Color(0xFF004820);

  late final VisitingCardFieldTransforms _baseline;
  late final VisitingCardOverlayField? _baselineOverlay;
  late final String? _baselineDuplicateId;
  var _didSnapshot = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSnapshot) return;
    _didSnapshot = true;
    final vm = context.read<VisitingCardEditContactViewModel>();
    _baseline = vm.fieldTransformsSnapshot;
    _baselineOverlay = vm.selectedOverlay;
    _baselineDuplicateId = vm.selectedDuplicateId;
  }

  void _restoreBaseline(VisitingCardEditContactViewModel vm) {
    vm.applyFieldTransforms(_baseline);
    vm.selectedOverlay = _baselineOverlay;
    vm.selectedDuplicateId = _baselineDuplicateId;
    vm.notifyListeners();
  }

  void _onCancel() {
    final vm = context.read<VisitingCardEditContactViewModel>();
    _restoreBaseline(vm);
    Navigator.pop(context);
  }

  void _onApply() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    final current = vm.activeTransform;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(vm, current),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final listW = constraints.maxWidth * 0.48;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: listW,
                        child: _fontList(vm, current),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.38,
                                maxHeight: constraints.maxHeight * 0.78,
                              ),
                              child: _previewPanel(vm),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(
    VisitingCardEditContactViewModel vm,
    VisitingCardFieldTransform? current,
  ) {
    return Container(
      height: 52,
      color: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: _FontMarkButton(
                    selected: vm.selectedFontIsBold,
                    onTap: vm.toggleSelectedFontBold,
                    child: const Text(
                      'B',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FontMarkButton(
                    selected: vm.selectedFontIsItalic,
                    onTap: vm.toggleSelectedFontItalic,
                    child: const Text(
                      'I',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FontMarkButton(
                    selected: current?.fontUnderline ?? false,
                    onTap: vm.toggleSelectedFontUnderline,
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFFFFFF),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FontMarkButton(
                    selected: current?.fontStrike ?? false,
                    onTap: vm.toggleSelectedFontStrike,
                    child: Transform.rotate(
                      angle: 3.1416,
                      child: const Text(
                        'U',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFFFFFFF),
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: const Color(0xFFFFFFFF),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _onCancel,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      Icons.close,
                      color: Color(0xFF000000),
                      size: 18,
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

  Widget _fontList(
    VisitingCardEditContactViewModel vm,
    VisitingCardFieldTransform? current,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      itemCount: VisitingCardFontPreset.presets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = VisitingCardFontPreset.presets[index];
        final selected = current?.fontPreset == index;
        final sample = visitingCardGoogleStyle(
          item.family,
          TextStyle(
            fontSize: item.previewFontSize,
            fontWeight: item.weight,
            letterSpacing: item.letterSpacing,
            color: const Color(0xFFFFFFFF),
            height: 1.1,
          ),
        );
        return Material(
          color: const Color(0x00000000),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => vm.setSelectedFontPreset(index),
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3D1A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF05B560)
                      : const Color(0xFF1B5C30),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                visitingCardFontPresetLabel(
                  index,
                  item,
                  vm.selectedOverlaySample,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sample,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _previewPanel(VisitingCardEditContactViewModel vm) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _previewPanelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _previewPanelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFFFFFFFF),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Preview',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 1,
              thickness: 1,
              color: _previewDivider,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _previewCardFrame,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Center(
                    child: _selectedFieldPreview(vm),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PreviewActionButton(
                  label: 'Cancel',
                  outlined: true,
                  onTap: _onCancel,
                ),
                const SizedBox(width: 12),
                _PreviewActionButton(
                  label: 'Apply',
                  outlined: false,
                  onTap: _onApply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Only the selected text field — font / B-I-U updates show here live.
  Widget _selectedFieldPreview(VisitingCardEditContactViewModel vm) {
    final transform = vm.activeTransform;
    final raw = vm.selectedOverlaySample;
    if (transform == null || raw.isEmpty) {
      return const Text(
        'Select a text field',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final display = visitingCardStyledText(
      raw,
      transform,
      templateUppercase: false,
    );
    final preset = VisitingCardFontPreset.of(transform.fontPreset);
    final color = transform.textColor ?? const Color(0xFFFFFFFF);
    final base = TextStyle(
      color: color,
      fontSize: (preset?.previewFontSize ?? 18).toDouble().clamp(16, 28),
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
    final style = applyVisitingCardFont(base, transform);

    return Text(
      display,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  final String label;
  final bool outlined;
  final VoidCallback onTap;

  static const _applyGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF00A942),
      Color(0xFF00622F),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 96,
          height: 36,
          decoration: BoxDecoration(
            gradient: outlined ? null : _applyGradient,
            color: outlined ? const Color(0x00000000) : null,
            borderRadius: BorderRadius.circular(24),
            border: outlined
                ? Border.all(color: const Color(0xFFFFFFFF), width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
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

class _FontMarkButton extends StatelessWidget {
  const _FontMarkButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF05B560) : const Color(0xFF12381C),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}
