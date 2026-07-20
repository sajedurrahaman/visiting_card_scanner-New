import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view/widget/template_orientation_tabs.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_template_tile.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class VisitingCardTemplateWidget extends StatelessWidget {
  const VisitingCardTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VisitingCardTemplateViewModel>();
    final templates = viewModel.templates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: TemplateOrientationTabs(
            orientation: viewModel.orientation,
            onChanged: viewModel.changeOrientation,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              viewModel.isHorizontal ? 16.w : 48.w,
              4.h,
              viewModel.isHorizontal ? 16.w : 48.w,
              120.h,
            ),
            itemCount: templates.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final item = templates[index];
              return VisitingCardTemplateTile(
                item: item,
                isHorizontal: viewModel.isHorizontal,
                isSelected: viewModel.selectedTemplateId == item.id,
                sideIndex: viewModel.sideFor(item.id),
                onTap: () => viewModel.selectTemplate(item.id),
                onShowFront: () => viewModel.showFront(item.id),
                onShowBack: () => viewModel.showBack(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
