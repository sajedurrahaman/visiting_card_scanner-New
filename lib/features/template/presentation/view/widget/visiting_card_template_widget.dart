import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class VisitingCardTemplateWidget extends StatelessWidget {
  const VisitingCardTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Visiting Card templates',
        style: ui.AppTextStyles.helperText(),
      ),
    );
  }
}
