import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape shape picker. Tapping a shape places it on the current card
/// and returns to the editor with that shape selected.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeShapeScreen extends StatefulWidget {
  const VisitingCardLandscapeShapeScreen({super.key});

  static final basicShapes = [
    'assets/visiting_card_scanner_shape/Vector.png',
    'assets/visiting_card_scanner_shape/Vector-1.png',
    'assets/visiting_card_scanner_shape/Group.png',
    for (var i = 1; i <= 27; i++)
      'assets/visiting_card_scanner_shape/Group-$i.png',
  ];

  static final strokeShapes = [
    'assets/visiting_card_scanner_shape/stroke_polygon_192.svg',
    'assets/visiting_card_scanner_shape/stroke_rectangle_43644.svg',
    for (var i = 2; i <= 7; i++)
      'assets/visiting_card_scanner_shape/stroke_star_$i.svg',
    'assets/visiting_card_scanner_shape/stroke_vector.svg',
    for (var i = 1; i <= 21; i++)
      'assets/visiting_card_scanner_shape/stroke_vector_$i.svg',
  ];

  static final decorativeShapes = [
    for (var i = 1; i <= 16; i++)
      'assets/visiting_card_scanner_shape/decorative_${i < 10 ? '0' : ''}$i.svg',
  ];

  static Future<void> open(BuildContext context) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardLandscapeShapeScreen(),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeShapeScreen> createState() =>
      _VisitingCardLandscapeShapeScreenState();
}

class _VisitingCardLandscapeShapeScreenState
    extends State<VisitingCardLandscapeShapeScreen> {
  static const _bg = Color(0xFF003303);
  static const _green = Color(0xFF0BA653);

  int _categoryIndex = 0;

  List<String> get _shapes => switch (_categoryIndex) {
    1 => VisitingCardLandscapeShapeScreen.strokeShapes,
    2 => VisitingCardLandscapeShapeScreen.decorativeShapes,
    _ => VisitingCardLandscapeShapeScreen.basicShapes,
  };

  String get _categoryTitle => switch (_categoryIndex) {
    1 => 'Basic Shape',
    2 => 'Decorative Shape',
    _ => 'Basic Shape',
  };

  void _place(String assetPath) {
    context.read<VisitingCardEditContactViewModel>().placeShape(assetPath);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pad = (MediaQuery.sizeOf(context).shortestSide * 0.035).clamp(
      12.0,
      18.0,
    );
    final size = MediaQuery.sizeOf(context);
    final columns = size.height > size.width ? 5 : 11;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: _bg,
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad + 4, 10, pad, 10),
                child: Row(
                  children: [
                    const Text(
                      'Shape',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
            Padding(
              padding: EdgeInsets.fromLTRB(pad + 8, 16, pad + 8, 10),
              child: Row(
                children: [
                  _CategoryTab(
                    label: 'Basic',
                    icon: Icons.change_history_rounded,
                    selected: _categoryIndex == 0,
                    onTap: () => setState(() => _categoryIndex = 0),
                  ),
                  SizedBox(width: 12),
                  _CategoryTab(
                    label: 'Stroke',
                    icon: Icons.star_border_rounded,
                    selected: _categoryIndex == 1,
                    onTap: () => setState(() => _categoryIndex = 1),
                  ),
                  SizedBox(width: 12),
                  _CategoryTab(
                    label: 'Decorative',
                    icon: Icons.palette_outlined,
                    selected: _categoryIndex == 2,
                    onTap: () => setState(() => _categoryIndex = 2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(pad + 8, 0, pad + 8, 8),
              child: Row(
                children: [
                  Container(width: 4, height: 18, color: _green),
                  const SizedBox(width: 6),
                  Text(
                    _categoryTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(pad + 8, 2, pad + 8, 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _shapes.length,
                itemBuilder: (context, index) {
                  final path = _shapes[index];
                  final isSvg = path.toLowerCase().endsWith('.svg');
                  return Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                      side: const BorderSide(color: Color(0xFFE7E7E7)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _place(path),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: isSvg
                            ? SvgPicture.asset(path, fit: BoxFit.contain)
                            : Image.asset(path, fit: BoxFit.contain),
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

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF08A34F) : const Color(0xFFF1F3F7),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
