import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class BarcodeTemplateWidget extends StatelessWidget {
  const BarcodeTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Barcode templates',
        style: ui.AppTextStyles.helperText(),
      ),
    );
  }
}
