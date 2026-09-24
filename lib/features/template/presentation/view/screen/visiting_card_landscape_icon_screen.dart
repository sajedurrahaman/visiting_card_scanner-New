import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

/// Landscape icon picker. Tapping an icon places it on the current card
/// and returns to the editor with that icon selected.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeIconScreen extends StatefulWidget {
  const VisitingCardLandscapeIconScreen({super.key});

  static final icons = [
    for (var i = 1; i <= 41; i++)
      'assets/visiting_card_scanner_icon/card_icon_$i.svg',
  ];

  static Future<void> open(BuildContext context) {
    final vm = context.read<VisitingCardEditContactViewModel>();
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const VisitingCardLandscapeIconScreen(),
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeIconScreen> createState() =>
      _VisitingCardLandscapeIconScreenState();
}

class _VisitingCardLandscapeIconScreenState
    extends State<VisitingCardLandscapeIconScreen> {
  static const _bg = Color(0xFF003303);

  void _place(String assetPath) {
    context.read<VisitingCardEditContactViewModel>().addCustomIcon(assetPath);
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
                      'Icon',
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
                itemCount: VisitingCardLandscapeIconScreen.icons.length,
                itemBuilder: (context, index) {
                  final path = VisitingCardLandscapeIconScreen.icons[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _place(path),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(path, fit: BoxFit.contain),
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
