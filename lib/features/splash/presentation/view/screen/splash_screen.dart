import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' hide Colors;
import 'package:visiting_card/app/routes/route_names.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapAndNavigate();
  }

  Future<void> _bootstrapAndNavigate() async {
    final minSplash = Future<void>.delayed(const Duration(seconds: 2));

    try {
      await AppStorageService.init().timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      // Keep going so a storage failure cannot brick launch on TestFlight.
      debugPrint('AppStorageService.init failed: $error\n$stackTrace');
    }

    await minSplash;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.parent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: SvgPicture.asset(
                AppAssets.splashLogo,
                width: 112.w,
                height: 112.w,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.h),
              child: Text(
                'Visiting Card Scanner',
                style: AppTextStyles.mainText(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
