import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/firebase/firebase_services.dart';

import 'app/routes/app_routes.dart';
import 'app/storage/app_storage_service.dart';
import 'app/view_models/app_viewmodels.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppBootstrap());
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<void> _startup = _initialize();

  Future<void> _initialize() async {
    final firebaseInitialization = initializeFirebase().catchError((error) {
      debugPrint('Error initializing Firebase: $error');
    });

    await Future.wait<void>([firebaseInitialization, AppStorageService.init()]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
            'App startup failed: ${snapshot.error}\n${snapshot.stackTrace}',
          );
          return const MaterialApp(home: _StartupErrorScreen());
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(home: _StartupLoadingScreen());
        }

        return MultiProvider(
          providers: AppViewModels.viewmodels,
          child: const MyApp(),
        );
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF078640)),
            SizedBox(height: 20),
            Text('Starting Visiting Card Scanner…'),
          ],
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'The app could not finish starting. Check the debug console for '
            'the startup error, then restart the app.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
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
