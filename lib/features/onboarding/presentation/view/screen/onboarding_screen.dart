import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visiting_card/app/routes/route_names.dart';
import 'package:visiting_card/app/storage/app_storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _OnboardingPage(
      illustration: 'assets/images/onboarding_scan.png',
      title: 'Scan any visiting card',
      description:
          'Point your camera at a card or its QR code. We read the details and save them for you.',
    ),
    _OnboardingPage(
      illustration: 'assets/images/onboarding_create.png',
      title: 'Create your own card',
      description:
          'Pick a template, add your details and a QR code, and your card is ready.',
    ),
    _OnboardingPage(
      illustration: 'assets/images/onboarding_organize.svg',
      title: 'Keep every card organized',
      description:
          'Save scanned cards and custom designs in folders, so you can find and share them whenever you need.',
      isSvg: true,
    ),
  ];

  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    await AppStorageService.instance.markOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.parent);
  }

  void _next() {
    if (_pageIndex == _pages.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _illustration(_OnboardingPage page) {
    if (page.isSvg) {
      return SvgPicture.asset(page.illustration, fit: BoxFit.fill);
    }
    return Image.asset(page.illustration, fit: BoxFit.fill);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06783A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final panelTop = height * 0.665;
          final cornerRadius = width * 0.08;

          return Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, index) => _illustration(_pages[index]),
              ),
              if (_pages[_pageIndex].isSvg)
                Positioned(
                  left: width * 0.174,
                  top: height * 0.067,
                  height: height * 0.05,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Visiting Card Scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.047,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: panelTop,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cornerRadius),
                      topRight: Radius.circular(cornerRadius),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.062,
                      height * 0.034,
                      width * 0.062,
                      MediaQuery.paddingOf(context).bottom + height * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP ${_pageIndex + 1} OF ${_pages.length}',
                          style: TextStyle(
                            color: const Color(0xFF00783B),
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: height * 0.018),
                        Text(
                          _pages[_pageIndex].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF101713),
                            fontSize: width * 0.058,
                            height: 1.13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: height * 0.012),
                        Text(
                          _pages[_pageIndex].description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF59645F),
                            fontSize: width * 0.047,
                            height: 1.38,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: List.generate(_pages.length, (index) {
                                  final active = index == _pageIndex;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: width * 0.02,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: active
                                          ? width * 0.066
                                          : width * 0.022,
                                      height: width * 0.022,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? const Color(0xFF07984A)
                                            : const Color(0xFFD2E6D9),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.35,
                              height: height * 0.067,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF12B554),
                                      Color(0xFF00783B),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: _isFinishing ? null : _next,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _pageIndex == _pages.length - 1
                                                ? 'Get started'
                                                : 'Next',
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * 0.046,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: width * 0.018),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: width * 0.052,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height * 0.061,
                right: width * 0.055,
                width: width * 0.17,
                height: height * 0.055,
                child: Semantics(
                  button: true,
                  label: 'Skip onboarding',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _isFinishing ? null : _finishOnboarding,
                      child: _pages[_pageIndex].isSvg
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.34),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.039,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.illustration,
    required this.title,
    required this.description,
    this.isSvg = false,
  });

  final String illustration;
  final String title;
  final String description;
  final bool isSvg;
}
