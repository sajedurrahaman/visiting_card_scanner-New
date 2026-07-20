import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qrcode_category_chip.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qrcode_template_tile.dart';
import 'package:visiting_card/features/template/presentation/view_model/qrcode_template_viewmodel.dart';

class QrcodeTemplateWidget extends StatelessWidget {
  const QrcodeTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QrcodeTemplateViewModel>();
    final categories = QrcodeTemplateViewModel.categories;
    final templates = viewModel.templates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: SizedBox(
            height: QrcodeCategoryChip.chipSize.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final category = categories[index];
                return QrcodeCategoryChip(
                  icon: category.icon,
                  label: category.label,
                  isSelected: viewModel.selectedCategory == category.category,
                  onTap: () => viewModel.changeCategory(category.category),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
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
              return QrcodeTemplateTile(
                item: item,
                onTap: () => viewModel.selectTemplate(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
