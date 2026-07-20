import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card/features/template/presentation/view_model/barcode_template_viewmodel.dart';

class BarcodeTemplateTile extends StatelessWidget {
  const BarcodeTemplateTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final BarcodeTemplateItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        item.thumbnailAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => SizedBox(
          height: 100.h,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 24.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }
}
