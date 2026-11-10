import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_edit_contact_info_screen.dart';
import 'package:visiting_card/features/template/presentation/view/screen/visiting_card_landscape_edit_screen.dart';
import 'package:visiting_card/features/template/presentation/view/widget/template_orientation_tabs.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_template_tile.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class VisitingCardTemplateWidget extends StatelessWidget {
  const VisitingCardTemplateWidget({super.key});

  Future<void> _openEditScreen(
    BuildContext context,
    VisitingCardTemplateViewModel viewModel,
    VisitingCardTemplateItem item,
  ) async {
    viewModel.selectTemplate(item.id);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => VisitingCardEditContactViewModel.fromTemplate(
            item,
            isHorizontal: viewModel.isHorizontal,
          ),
          child: const VisitingCardEditContactInfoScreen(),
        ),
      ),
    );
  }

  Future<void> _openScratchEditor(BuildContext context) async {
    const blankCanvas = 'assets/images/blank_visiting_card.svg';
    final vm = VisitingCardEditContactViewModel(
      templateId: 'h1',
      isHorizontal: true,
      frontAssetWithoutData: blankCanvas,
      backAssetWithoutData: blankCanvas,
    );
    await VisitingCardLandscapeEditScreen.open(
      context,
      vm: vm,
      offerSaveToPhone: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VisitingCardTemplateViewModel>();
    final templates = viewModel.templates;

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
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
                    onTap: () => _openEditScreen(context, viewModel, item),
                    onShowFront: () => viewModel.showFront(item.id),
                    onShowBack: () => viewModel.showBack(item.id),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 14.w,
          bottom: 106.h,
          child: Semantics(
            button: true,
            label: 'Create visiting card from scratch',
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              elevation: 8,
              shadowColor: const Color(0x55002E1D),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openScratchEditor(context),
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF21C46B), Color(0xFF00552E)],
                    ),
                    border: Border.all(color: Colors.white, width: 4.w),
                  ),
                  child: Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 29.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
