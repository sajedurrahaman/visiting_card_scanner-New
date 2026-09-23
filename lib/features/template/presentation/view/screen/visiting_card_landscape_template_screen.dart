import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

/// Landscape template picker. Selecting a card applies it and returns
/// to the editor so the same contact can keep working.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeTemplateScreen extends StatefulWidget {
  const VisitingCardLandscapeTemplateScreen({super.key});

  static Future<void> open(BuildContext context) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardLandscapeTemplateScreen(),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeTemplateScreen> createState() =>
      _VisitingCardLandscapeTemplateScreenState();
}

class _VisitingCardLandscapeTemplateScreenState
    extends State<VisitingCardLandscapeTemplateScreen> {
  static const _bg = Color(0xFF003303);

  late bool _horizontal;

  @override
  void initState() {
    super.initState();
    _horizontal =
        context.read<VisitingCardEditContactViewModel>().isHorizontal;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  List<VisitingCardTemplateItem> get _templates => _horizontal
      ? VisitingCardTemplateViewModel.horizontalTemplates
      : VisitingCardTemplateViewModel.verticalTemplates;

  void _apply(VisitingCardTemplateItem item) {
    context.read<VisitingCardEditContactViewModel>().applyTemplate(
          item,
          horizontal: _horizontal,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitingCardEditContactViewModel>();
    final pad = (MediaQuery.sizeOf(context).shortestSide * 0.035)
        .clamp(12.0, 18.0);
    final templates = _templates;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 20, pad, 12),
              child: Row(
                children: [
                  _OrientationChip(
                    label: 'Horizontal',
                    selected: _horizontal,
                    onTap: () => setState(() => _horizontal = true),
                  ),
                  const SizedBox(width: 22),
                  _OrientationChip(
                    label: 'Vertical',
                    selected: !_horizontal,
                    onTap: () => setState(() => _horizontal = false),
                  ),
                  const Spacer(),
                  Material(
                    color: const Color(0xFFFFFFFF),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close,
                          color: Color(0xFF000000),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  _horizontal ? pad + 24 : pad + 80,
                  4,
                  _horizontal ? pad + 24 : pad + 80,
                  pad,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _horizontal ? 2 : 3,
                  mainAxisSpacing: _horizontal ? 16 : 28,
                  crossAxisSpacing: _horizontal ? 20 : 48,
                  childAspectRatio: _horizontal ? 1.75 : 0.63,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final item = templates[index];
                  final selected = vm.templateId == item.id &&
                      vm.isHorizontal == _horizontal;
                  return Material(
                    color: const Color(0x00000000),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _apply(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF05B560)
                                : const Color(0x00000000),
                            width: selected ? 2 : 0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            item.frontAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFF0A3D0A),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
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

class _OrientationChip extends StatelessWidget {
  const _OrientationChip({
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                color: selected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF9AA89A),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
