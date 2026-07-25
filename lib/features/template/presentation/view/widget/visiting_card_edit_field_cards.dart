import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

List<BoxShadow> get _cardShadow => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];

class VisitingSelectActionCard extends StatelessWidget {
  const VisitingSelectActionCard({
    super.key,
    required this.label,
    required this.buttonLabel,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String buttonLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ui.AppTextStyles.helperText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: enabled ? onTap : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: enabled
                    ? ui.Colors.parentIconSelectTextColor
                    : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontFamily: ui.AppFonts.sfPro,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VisitingSimpleFieldCard extends StatelessWidget {
  const VisitingSimpleFieldCard({
    super.key,
    required this.title,
    required this.entries,
    required this.onChanged,
    required this.onClear,
    this.onAdd,
    this.showAddIcon = true,
  });

  final String title;
  final List<ContactFieldEntry> entries;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onClear;
  final VoidCallback? onAdd;
  final bool showAddIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: ui.AppFonts.sfPro,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: ui.Colors.parentIconSelectTextColor,
                  ),
                ),
              ),
              if (showAddIcon && onAdd != null)
                GestureDetector(
                  onTap: onAdd,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: SvgPicture.asset(
                      ui.AppAssets.visitingTemplateAddIcon,
                      width: 16.w,
                      height: 16.w,
                    ),
                  ),
                ),
            ],
          ),
          ...List.generate(entries.length, (index) {
            return _UnderlinedInputRow(
              key: ValueKey('$title-$index-${entries.length}'),
              value: entries[index].value,
              onChanged: (v) => onChanged(index, v),
              onClear: () => onClear(index),
              showClearIcon: index > 0,
            );
          }),
        ],
      ),
    );
  }
}

class VisitingTypedFieldCard extends StatefulWidget {
  const VisitingTypedFieldCard({
    super.key,
    required this.title,
    required this.entries,
    required this.typeOptions,
    required this.onValueChanged,
    required this.onTypeChanged,
    required this.onClear,
    required this.onAdd,
  });

  final String title;
  final List<ContactFieldEntry> entries;
  final List<String> typeOptions;
  final void Function(int index, String value) onValueChanged;
  final void Function(int index, String type) onTypeChanged;
  final void Function(int index) onClear;
  final VoidCallback onAdd;

  @override
  State<VisitingTypedFieldCard> createState() => _VisitingTypedFieldCardState();
}

class _VisitingTypedFieldCardState extends State<VisitingTypedFieldCard> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant VisitingTypedFieldCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers(forceText: oldWidget.entries.length != widget.entries.length);
  }

  void _syncControllers({bool forceText = true}) {
    while (_controllers.length > widget.entries.length) {
      _controllers.removeLast().dispose();
    }
    while (_controllers.length < widget.entries.length) {
      final index = _controllers.length;
      _controllers.add(
        TextEditingController(text: widget.entries[index].value),
      );
    }
    for (var i = 0; i < widget.entries.length; i++) {
      final next = widget.entries[i].value;
      if (_controllers[i].text == next) continue;
      // Skip overwrite while typing; still apply clear/remove updates.
      if (!forceText && next.isNotEmpty) continue;
      _controllers[i].value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: ui.AppFonts.sfPro,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: ui.Colors.parentIconSelectTextColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onAdd,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: SvgPicture.asset(
                    ui.AppAssets.visitingTemplateAddIcon,
                    width: 16.w,
                    height: 16.w,
                  ),
                ),
              ),
            ],
          ),
          ...List.generate(widget.entries.length, (index) {
            if (index >= _controllers.length) {
              return const SizedBox.shrink();
            }
            final entry = widget.entries[index];
            final selected = widget.typeOptions.contains(entry.type)
                ? entry.type
                : widget.typeOptions.first;
            return Padding(
              key: ValueKey('${widget.title}-typed-$index'),
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 78.w,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selected,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                        style: TextStyle(
                          fontFamily: ui.AppFonts.sfPro,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A1A),
                        ),
                        items: widget.typeOptions
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) widget.onTypeChanged(index, v);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controllers[index],
                      autofocus: false,
                      onChanged: (v) => widget.onValueChanged(index, v),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        fontFamily: ui.AppFonts.sfPro,
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFFE0E0E0),
                            width: 1.w,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFFE0E0E0),
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: ui.Colors.parentIconSelectTextColor,
                            width: 1.2.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  if (index > 0)
                    GestureDetector(
                      onTap: () => widget.onClear(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: SvgPicture.asset(
                          ui.AppAssets.visitingTemplateCrossIcon,
                          width: 16.w,
                          height: 16.w,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UnderlinedInputRow extends StatefulWidget {
  const _UnderlinedInputRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.showClearIcon = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClearIcon;

  @override
  State<_UnderlinedInputRow> createState() => _UnderlinedInputRowState();
}

class _UnderlinedInputRowState extends State<_UnderlinedInputRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _UnderlinedInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: false,
            onChanged: widget.onChanged,
            onTapOutside: (_) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            style: TextStyle(
              fontFamily: ui.AppFonts.sfPro,
              fontSize: 14.sp,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0),
                  width: 1.w,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0),
                  width: 1.w,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ui.Colors.parentIconSelectTextColor,
                  width: 1.2.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ),
        if (widget.showClearIcon) ...[
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: widget.onClear,
            child: SvgPicture.asset(
              ui.AppAssets.visitingTemplateCrossIcon,
              width: 16.w,
              height: 16.w,
            ),
          ),
        ],
      ],
    );
  }
}

class VisitingGradientButton extends StatelessWidget {
  const VisitingGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  static const gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3DCB6A), Color(0xFF0B5D2A)],
  );

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: 36.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: ui.AppFonts.sfPro,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class VisitingOutlinedButton extends StatelessWidget {
  const VisitingOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: ui.Colors.parentIconSelectTextColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: ui.AppFonts.sfPro,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: ui.Colors.parentIconSelectTextColor,
          ),
        ),
      ),
    );
  }
}
