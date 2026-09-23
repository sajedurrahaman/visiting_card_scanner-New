import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Landscape Edit Text: type a new value, then Apply or Cancel.
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeEditTextScreen extends StatefulWidget {
  const VisitingCardLandscapeEditTextScreen({
    super.key,
    required this.initialValue,
  });

  final String initialValue;

  static Future<String?> open(
    BuildContext context, {
    required String initialValue,
  }) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardLandscapeEditTextScreen(
          initialValue: initialValue,
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeEditTextScreen> createState() =>
      _VisitingCardLandscapeEditTextScreenState();
}

class _VisitingCardLandscapeEditTextScreenState
    extends State<VisitingCardLandscapeEditTextScreen> {
  static const _bg = Color(0xFF003303);

  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCancel() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context);
  }

  void _onApply() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final pad = (size.shortestSide * 0.045).clamp(12.0, 22.0);

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                pad,
                pad,
                pad,
                pad + viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: (constraints.maxWidth * 0.74).clamp(280.0, 560.0),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          minLines: 3,
                          maxLines: 3,
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          textAlignVertical: TextAlignVertical.top,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            hintText: 'Start typing here',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              16,
                              14,
                              16,
                              14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: pad * 2.8),
                      Column(
                        children: [
                          _ActionButton(
                            label: 'Apply',
                            background: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF3DCB6A),
                                Color(0xFF0B5D2A),
                              ],
                            ),
                            onTap: _onApply,
                          ),
                          const SizedBox(height: 10),
                          _ActionButton(
                            label: 'Cancel',
                            background: const Color(0xFFE53935),
                            onTap: _onCancel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.onTap,
  });

  final String label;
  final Object background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 108,
          height: 36,
          decoration: BoxDecoration(
            color: background is Color ? background as Color : null,
            gradient: background is Gradient ? background as Gradient : null,
            borderRadius: BorderRadius.circular(10),
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
