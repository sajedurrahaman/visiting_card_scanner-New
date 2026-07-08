import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/presentation/view/screen/home_screen.dart';
import 'package:visiting_card/features/parent/presentation/view/widgets/parent_bottom_nav_bar.dart';
import 'package:visiting_card/features/parent/presentation/view_model/parent_view_model.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<ParentViewModel>().currentIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBFEF5),
              Colors.white,
            ],
            stops: [0.0, 0.40],
          ),
        ),
        child: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            _PlaceholderTab(title: 'Template'),
            _PlaceholderTab(title: 'Folder'),
            _PlaceholderTab(title: 'Settings'),
          ],
        ),
      ),
      floatingActionButton: const ParentCenterNavButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const ParentBottomNavBar(),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Text(
          title,
          style: ui.AppTextStyles.mainText(),
        ),
      ),
    );
  }
}

class ParentCenterNavButton extends StatelessWidget {
  const ParentCenterNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.read<ParentViewModel>().onCenterButtonTap,
      child: SvgPicture.asset(
        ui.AppAssets.parentNavLogoCenter,
        width: 64.w,
        height: 64.w,
      ),
    );
  }
}
