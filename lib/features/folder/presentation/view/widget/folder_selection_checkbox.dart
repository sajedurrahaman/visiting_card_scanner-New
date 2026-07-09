import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FolderSelectionCheckbox extends StatelessWidget {
  const FolderSelectionCheckbox({
    super.key,
    required this.isSelected,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF05B560) : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF05B560)
              : const Color(0xFFB0B0B0),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 14.sp,
              color: Colors.white,
            )
          : null,
    );
  }
}
