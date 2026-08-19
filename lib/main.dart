import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/firebase/firebase_services.dart';

import 'app/routes/app_routes.dart';
import 'app/storage/app_storage_service.dart';
import 'app/view_models/app_viewmodels.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeFirebase();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  await AppStorageService.init();
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
