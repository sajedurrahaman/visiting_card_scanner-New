import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view/widget/barcode_template_tile.dart';
import 'package:visiting_card/features/template/presentation/view_model/barcode_template_viewmodel.dart';

class BarcodeTemplateWidget extends StatelessWidget {
  const BarcodeTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarcodeTemplateViewModel>();
    final templates = viewModel.templates;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final item = templates[index];
        return BarcodeTemplateTile(
          item: item,
          onTap: () => viewModel.selectTemplate(item.id),
        );
      },
    );
  }
}
