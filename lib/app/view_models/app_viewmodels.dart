import 'package:provider/provider.dart';

import '../../features/folder/presentation/view_model/folder_viewmodel.dart';
import '../../features/home/presentation/view_model/home_view_model.dart';
import '../../features/home/presentation/view_model/recent_card_menu_view_model.dart';
import '../../features/parent/presentation/view_model/parent_view_model.dart';
import '../../features/settings/presentation/view_model/settings_viewmodel.dart';
import '../../features/template/presentation/view_model/barcode_template_viewmodel.dart';
import '../../features/template/presentation/view_model/qrcode_template_viewmodel.dart';
import '../../features/template/presentation/view_model/template_viewmodel.dart';
import '../../features/template/presentation/view_model/visiting_card_template_viewmodel.dart';

class AppViewModels {
  AppViewModels._();

  static List<ChangeNotifierProvider> get viewmodels => [
        ChangeNotifierProvider<ParentViewModel>(
          create: (_) => ParentViewModel(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(),
        ),
        ChangeNotifierProvider<RecentCardMenuViewModel>(
          create: (_) => RecentCardMenuViewModel(),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(),
        ),
        ChangeNotifierProvider<FolderViewModel>(
          create: (_) => FolderViewModel(),
        ),
        ChangeNotifierProvider<TemplateViewModel>(
          create: (_) => TemplateViewModel(),
        ),
        ChangeNotifierProvider<VisitingCardTemplateViewModel>(
          create: (_) => VisitingCardTemplateViewModel(),
        ),
        ChangeNotifierProvider<QrcodeTemplateViewModel>(
          create: (_) => QrcodeTemplateViewModel(),
        ),
        ChangeNotifierProvider<BarcodeTemplateViewModel>(
          create: (_) => BarcodeTemplateViewModel(),
        ),
      ];
}
