import 'package:flutter/material.dart';
import 'package:visiting_card/app/routes/route_names.dart';

import '../../features/folder/presentation/view/screen/barcode_folder_screen.dart';
import '../../features/folder/presentation/view/screen/qr_code_folder_screen.dart';
import '../../features/folder/presentation/view/screen/visiting_card_folder_screen.dart';
import '../../features/home/presentation/view/screen/recent_screen.dart';
import '../../features/parent/presentation/view/parent_screen.dart';
import '../../features/splash/presentation/view/screen/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String initialRoute = RouteNames.splash;

  static Map<String, WidgetBuilder> get routes => {
        RouteNames.splash: (_) => const SplashScreen(),
        RouteNames.parent: (_) => const ParentScreen(),
        RouteNames.recent: (_) => const RecentScreen(),
        RouteNames.visitingCardFolder: (_) => const VisitingCardFolderScreen(),
        RouteNames.qrCodeFolder: (_) => const QrCodeFolderScreen(),
        RouteNames.barcodeFolder: (_) => const BarcodeFolderScreen(),
      };
}