import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/template/presentation/view/widget/barcode_template_widget.dart';
import 'package:visiting_card/features/template/presentation/view/widget/qrcode_template_widget.dart';
import 'package:visiting_card/features/template/presentation/view/widget/template_type_selector.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_template_widget.dart';
import 'package:visiting_card/features/template/presentation/view_model/template_viewmodel.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TemplateViewModel>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Text(
              'Template',
              textAlign: TextAlign.center,
              style: ui.AppTextStyles.mainText(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: TemplateTypeSelector(
              selectedIndex: viewModel.selectedIndex,
              onChanged: viewModel.changeTab,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: viewModel.selectedIndex,
              children: const [
                VisitingCardTemplateWidget(),
                QrcodeTemplateWidget(),
                BarcodeTemplateWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
