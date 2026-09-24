import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

/// Landscape Save → full-screen rename (other-app style).
///
/// Avoids ScreenUtil — portrait designSize breaks layout in landscape.
class VisitingCardLandscapeRenameScreen extends StatefulWidget {
  const VisitingCardLandscapeRenameScreen({
    super.key,
    required this.initialValue,
    this.hintText = 'Visiting Card',
  });

  final String initialValue;
  final String hintText;

  static Future<String?> open(
    BuildContext context, {
    required String initialValue,
    String hintText = 'Visiting Card',
  }) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VisitingCardLandscapeRenameScreen(
          initialValue: initialValue,
          hintText: hintText,
        ),
      ),
    );
  }

  @override
  State<VisitingCardLandscapeRenameScreen> createState() =>
      _VisitingCardLandscapeRenameScreenState();
}

class _VisitingCardLandscapeRenameScreenState
    extends State<VisitingCardLandscapeRenameScreen> {
  static const _bg = Color(0xFF003303);
  static const _primary = ui.Colors.parentIconSelectTextColor;

  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _returnToLandscape([String? name]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, name);
  }

  void _onCancel() => _returnToLandscape();

  void _onSave() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ui.AppToast.show(context, message: 'Name cannot be empty');
      return;
    }
    _returnToLandscape(name);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final pad = (size.shortestSide * 0.04).clamp(12.0, 20.0);
    final fieldWidth = (size.width * 0.55).clamp(280.0, 520.0);

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                pad,
                pad,
                pad,
                pad + viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - pad * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter card Name',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: pad * 1.25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onSave(),
                          onTap: () {
                            // Keep Save/Cancel reachable above the keyboard.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_scrollController.hasClients) return;
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            isDense: true,
                            hintText: widget.hintText,
                            hintStyle: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _primary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _primary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: _primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: fieldWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _onCancel,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _onSave,
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Extra space so buttons stay tappable above keyboard.
                    SizedBox(height: viewInsets.bottom > 0 ? 24 : 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
