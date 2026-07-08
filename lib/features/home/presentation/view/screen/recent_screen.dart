import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/features/home/presentation/view/widgets/recent_card_tile.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBFEF5),
              Colors.white,
            ],
            stops: [0.0, 0.20],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent',
                      style: ui.AppTextStyles.mainText(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                  itemCount: viewModel.recentCards.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.recentCards[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: RecentCardTile(item: item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
