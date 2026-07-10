import 'package:flutter/material.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;

class QrcodeTemplateWidget extends StatelessWidget {
  const QrcodeTemplateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'QR Code templates',
        style: ui.AppTextStyles.helperText(),
      ),
    );
  }
}
