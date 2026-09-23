import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/domain/visiting_card_font_style.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape Font style picker. Changes apply to the selected field.
///
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
            Container(
              height: 52,
              color: const Color(0xFF000000),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
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
                        const SizedBox(width: 18),
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
                        const SizedBox(width: 18),
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
                        const SizedBox(width: 18),
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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: const Color(0xFFFFFFFF),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
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
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 16, right: 12, bottom: 12),
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
              ),
            ),
          ],
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
