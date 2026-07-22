import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visiting_card/app/helper/ui_helper.dart' as ui;
import 'package:visiting_card/app/routes/route_names.dart';
import 'package:visiting_card/features/home/presentation/view/widgets/home_screen_barcode_bottom_sheet.dart';
import 'package:visiting_card/features/home/presentation/view/widgets/home_screen_qrcode_bottom_sheet.dart';
import 'package:visiting_card/features/home/presentation/view/widgets/home_screen_visiting_card_bottom_sheet.dart';
import 'package:visiting_card/features/home/presentation/view/widgets/recent_card_tile.dart';
import 'package:visiting_card/features/home/presentation/view_model/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadRecentFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return SafeArea(
      bottom: false,
      child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
              child: Text(
                'Visiting Card Scanner',
                style: ui.AppTextStyles.mainText(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(title: 'Scan'),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ScanAction(
                          icon: ui.AppAssets.homeVisitingCard,
                          label: 'Visiting Card',
                          onTap: () =>
                              HomeScreenVisitingCardBottomSheet.show(context),
                        ),
                        _ScanAction(
                          icon: ui.AppAssets.homeQrCode,
                          label: 'QR Code',
                          onTap: () =>
                              HomeScreenQrcodeBottomSheet.show(context),
                        ),
                        _ScanAction(
                          icon: ui.AppAssets.homeBarCode,
                          label: 'Barcode',
                          onTap: () =>
                              HomeScreenBarcodeBottomSheet.show(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                    if (viewModel.hasRecentCards)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: _SectionTitle(title: 'Recent'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.recent,
                                    );
                                  },
                                  child: Text(
                                    'View All',
                                    style: ui.AppTextStyles.sellAllText(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(6.w, 8.h, 6.w, 120.h),
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
                      )
                    else
                      const Expanded(child: _EmptyRecentState()),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ui.AppTextStyles.mainText(),
        ),
      ],
    );
  }
}

class _ScanAction extends StatelessWidget {
  const _ScanAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96.w,
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                icon,
                width: 36.w,
                height: 36.w,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ui.AppTextStyles.iconUnderText(
                color: const Color(0xFF1A1A1A),
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecentState extends StatelessWidget {
  const _EmptyRecentState();

  @override
  Widget build(BuildContext context) {
    // Center between Scan section and bottom nav bar.
    return Padding(
      padding: EdgeInsets.only(bottom: 72.h),
      child: Center(
        child: Image.asset(
          ui.AppAssets.homeScreenRecentEmpty,
          width: 200.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

