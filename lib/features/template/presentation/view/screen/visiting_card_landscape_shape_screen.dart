import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape shape picker. Tapping a shape places it on the current card
/// and returns to the editor with that shape selected.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeShapeScreen extends StatefulWidget {
  const VisitingCardLandscapeShapeScreen({super.key});

  static final shapes = [
    'assets/visiting_card_scanner_shape/Vector.png',
    'assets/visiting_card_scanner_shape/Vector-1.png',
    'assets/visiting_card_scanner_shape/Group.png',
    for (var i = 1; i <= 27; i++)
      'assets/visiting_card_scanner_shape/Group-$i.png',
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _place(String assetPath) {
    context.read<VisitingCardEditContactViewModel>().addCustomShape(assetPath);
    Navigator.pop(context);
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
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(pad + 8, 16, pad + 8, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 11,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemCount: VisitingCardLandscapeShapeScreen.shapes.length,
                itemBuilder: (context, index) {
                  final path = VisitingCardLandscapeShapeScreen.shapes[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _place(path),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(path, fit: BoxFit.contain),
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
