import 'package:provider/provider.dart';

import '../../features/home/presentation/view_model/home_view_model.dart';
import '../../features/home/presentation/view_model/recent_card_menu_view_model.dart';
import '../../features/parent/presentation/view_model/parent_view_model.dart';

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
      ];
}
