import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'app/routes/app_routes.dart';
import 'app/view_models/app_viewmodels.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never await heavy native I/O here. If Isar/SharedPreferences hangs or
  // crashes before runApp, iOS stays on the white launch screen forever
  // (common on TestFlight/release). Storage is initialized on SplashScreen.
  runApp(
    MultiProvider(
      providers: AppViewModels.viewmodels,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Visiting Card Scanner',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
