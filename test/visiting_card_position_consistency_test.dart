import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_live_preview.dart';
import 'package:visiting_card/features/template/presentation/view/widget/visiting_card_transform_overlay.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<List<({Rect bounds, int lines, double rounding})>> measure(
    WidgetTester tester,
    VisitingCardEditContactViewModel vm, {
    required double width,
    required bool contactInfo,
    bool selected = false,
    int? expectedAddressLines,
  }) async {
    final screen = contactInfo || !vm.isHorizontal
        ? const Size(390, 844)
        : const Size(844, 390);
    tester.view.reset();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = screen;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: screen,
              textScaler: TextScaler.linear(1.8),
            ),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: VisitingCardLivePreview(
                    key: ValueKey(
                      '$contactInfo-$width-${vm.sideIndex}-$selected',
                    ),
                    vm: vm,
                    showPager: false,
                    enableFieldTransform: true,
                    eightPointSelection: contactInfo,
                    selectionBorderOnlyWhenSelected: !contactInfo,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await GoogleFonts.pendingFonts();
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return find.byType(VisitingCardTransformOverlay).evaluate().map((element) {
      final overlay = element.widget as VisitingCardTransformOverlay;
      final paragraphs = find.descendant(
        of: find.byWidget(overlay), matching: find.byType(RichText),
      ).evaluate();
      var lines = 0;
      if (paragraphs.isNotEmpty) {
        final text = paragraphs.first.widget as RichText;
        final painter = TextPainter(
          text: text.text,
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.noScaling,
          maxLines: text.maxLines,
        )..layout(maxWidth: overlay.boxWidth);
        lines = painter.computeLineMetrics().length;
        if (text.text.toPlainText().toLowerCase() == vm.displayAddress.toLowerCase()) {
          expect(text.maxLines, 2);
          expect(text.softWrap, isTrue);
          expect(lines, lessThanOrEqualTo(2));
          if (expectedAddressLines != null) {
            expect(lines, expectedAddressLines);
            expect(painter.didExceedMaxLines, isFalse);
          }
        }
        painter.dispose();
      }
      return (
        bounds: Rect.fromLTWH(
          overlay.left / overlay.cardSize.width,
          overlay.top / overlay.cardSize.height,
          overlay.boxWidth / overlay.cardSize.width,
          overlay.boxHeight / overlay.cardSize.height,
        ),
        lines: lines,
        // The text engine rounds each line height to logical pixels. Check
        // line count exactly and allow at most one pixel per line per view.
        // Images have no line rounding and must preserve their height exactly.
        rounding: lines / overlay.cardSize.height,
      );
    }).toList();
  }

  void expectSame(
    List<({Rect bounds, int lines, double rounding})> before,
    List<({Rect bounds, int lines, double rounding})> after,
    String reason,
  ) {
    expect(after.length, before.length, reason: reason);
    expect(before, isNotEmpty, reason: reason);
    for (var i = 0; i < before.length; i++) {
      final oldBox = before[i].bounds;
      final newBox = after[i].bounds;
      expect(after[i].lines, before[i].lines, reason: reason);
      expect(newBox.left, closeTo(oldBox.left, 0.0001), reason: reason);
      expect(newBox.top, closeTo(oldBox.top, 0.0001), reason: reason);
      expect(newBox.width, closeTo(oldBox.width, 0.0001), reason: reason);
      expect(newBox.height, closeTo(oldBox.height,
        before[i].rounding + after[i].rounding + 0.0001), reason: reason);
    }
  }

  for (final horizontal in [true, false]) {
    testWidgets('capture snaps a partially swiped ${horizontal ? 'horizontal' : 'vertical'} card', (tester) async {
      addTearDown(tester.view.reset);
      final vm = VisitingCardEditContactViewModel(
        templateId: horizontal ? 'h19' : 'v1',
        isHorizontal: horizontal,
        frontAssetWithoutData: 'assets/images/unused-test-background.png',
        backAssetWithoutData: 'assets/images/unused-test-background.png',
      );
      vm.names.first.value = 'Emma Wilson';
      await measure(tester, vm, width: 320, contactInfo: true);
      final controller = tester.widget<PageView>(find.byType(PageView)).controller!;
      for (final fraction in [0.49, 0.51]) {
        vm.jumpSideForCapture = false;
        controller.jumpTo(controller.position.viewportDimension * fraction);
        await tester.pump();
        expect(controller.page, closeTo(fraction, 0.0001));
        // Request the side that round() already considers selected: capture
        // must still cancel the partial swipe rather than returning early.
        vm.jumpSideForCapture = true;
        vm.setSide(fraction.round());
        await tester.pump();
        expect(controller.page, fraction.round().toDouble());
        expect(tester.widget<PageView>(find.byType(PageView)).physics,
            isA<NeverScrollableScrollPhysics>());
        vm.setSide(1 - fraction.round());
        await tester.pump();
        expect(controller.page, (1 - fraction.round()).toDouble());
      }
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }

  for (final horizontal in [true, false]) {
    testWidgets('shape handles resize only their axis in ${horizontal ? 'landscape' : 'vertical'} preview', (tester) async {
      addTearDown(tester.view.reset);
      final vm = VisitingCardEditContactViewModel(
        templateId: horizontal ? 'h19' : 'v1', isHorizontal: horizontal,
        frontAssetWithoutData: 'assets/images/unused-test-background.png',
        backAssetWithoutData: 'assets/images/unused-test-background.png',
      );
      const asset = 'assets/visiting_card_scanner_shape/Group-14.png';
      vm.addCustomShape(asset);
      await measure(tester, vm, width: 320, contactInfo: !horizontal);
      await tester.runAsync(() => precacheImage(const AssetImage(asset),
          tester.element(find.byType(VisitingCardLivePreview))));
      await tester.pumpAndSettle();
      VisitingCardTransformOverlay overlay() =>
          tester.widget<VisitingCardTransformOverlay>(find.byType(VisitingCardTransformOverlay));
      final before = overlay();
      before.onStretchHorizontal!(12, fixOpposite: true);
      await tester.pumpAndSettle();
      final wider = overlay();
      expect(wider.boxWidth, closeTo(before.boxWidth + 12, 1e-6));
      expect(wider.boxHeight, closeTo(before.boxHeight, 1e-6));
      expect(wider.left + wider.boxWidth,
          closeTo(before.left + before.boxWidth, 1e-6));
      wider.onStretchVertical!(8, fixOpposite: true);
      await tester.pumpAndSettle();
      final taller = overlay();
      expect(taller.boxHeight, closeTo(wider.boxHeight + 8, 1e-6));
      expect(taller.boxWidth, closeTo(wider.boxWidth, 1e-6));
      expect(taller.top + taller.boxHeight,
          closeTo(wider.top + wider.boxHeight, 1e-6));
      taller.onUniformScale!(10, fixRight: false, fixBottom: false);
      await tester.pumpAndSettle();
      final scaled = overlay();
      expect(scaled.boxWidth / scaled.boxHeight,
          closeTo(taller.boxWidth / taller.boxHeight, 1e-6));
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }

  for (final id in ['h18', 'h20']) {
    testWidgets('$id wraps the reported addresses into two complete lines', (tester) async {
      addTearDown(tester.view.reset);
      final vm = VisitingCardEditContactViewModel(
        templateId: id,
        isHorizontal: true,
        frontAssetWithoutData: 'assets/images/unused-test-background.png',
        backAssetWithoutData: 'assets/images/unused-test-background.png',
      );
      for (final address in [
        'Khapara Road, Khilkhet, Dhaka, Bangladesh',
        '12/2, khapara road, khilket, dhaka, bangladesh',
      ]) {
        vm.addresses.first.value = address;
        final contact = await measure(tester, vm,
          width: 320, contactInfo: true, expectedAddressLines: 2);
        final landscape = await measure(tester, vm,
          width: 440, contactInfo: false, expectedAddressLines: 2);
        expectSame(contact, landscape, '$id: $address');
      }
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }

  for (final horizontal in [true, false]) {
    for (var template = 1; template <= (horizontal ? 20 : 21); template++) {
      final id = '${horizontal ? 'h' : 'v'}$template';
      testWidgets('$id preserves text, logo and QR bounds between editors', (
        tester,
      ) async {
        addTearDown(tester.view.reset);
        final vm = VisitingCardEditContactViewModel(
          templateId: id,
          isHorizontal: horizontal,
          frontAssetWithoutData: 'assets/images/unused-test-background.png',
          backAssetWithoutData: 'assets/images/unused-test-background.png',
        );
        vm.names.first.value = 'Emma Wilson';
        vm.designations.first.value = 'Creative Director';
        vm.companies.first.value = 'Acme Studio';
        vm.taglines.first.value = 'Design for a better tomorrow';
        vm.phones.first.value = '+880 1700 123456';
        vm.emails.first.value = 'emma@example.com';
        vm.websites.first.value = 'www.example.com';
        vm.addresses.first.value =
            '12/2, khapara road, khilket, dhaka, bangladesh';
        vm.frontLogoAssetPath =
            'assets/visiting_card_scanner_logo/edit_logo_1.svg';
        vm.backLogoAssetPath = vm.frontLogoAssetPath;
        vm.hasChosenFrontLogo = vm.hasChosenBackLogo = true;
        vm.qrAssetPath = 'assets/qrcode/contacts.svg';
        vm.hasChosenQr = true;

        for (final side in [0, 1]) {
          vm.sideIndex = side;
          final before = await measure(
            tester,
            vm,
            width: 320,
            contactInfo: true,
          );
          final after = await measure(
            tester,
            vm,
            width: horizontal ? 440 : 240,
            contactInfo: false,
          );
          expectSame(before, after, '$id side $side');
          // A saved width, font spacing and rotation must also survive the
          // screen change and selecting an element must not alter its box.
          for (final field in VisitingCardOverlayField.values) {
            final t = vm.defaultTransformFor(field);
            if (t == null) continue;
            vm.currentOverlays[VisitingCardFieldTransform.keyOf(field)] = t
                .copyWith(
                  left: 0.2,
                  top: 0.3,
                  width: field.isImageOverlay ? null : 0.24,
                  rotation: 0.25,
                  letterSpacing: 0.8,
                );
          }
          vm.selectedOverlay = VisitingCardOverlayField.name;
          final moved = await measure(
            tester,
            vm,
            width: 320,
            contactInfo: true,
            selected: true,
          );
          final reopened = await measure(
            tester,
            vm,
            width: horizontal ? 440 : 240,
            contactInfo: false,
            selected: true,
          );
          expectSame(moved, reopened, '$id side $side saved positions');
        }
        await tester.pumpWidget(const SizedBox());
        vm.dispose();
      });
    }
  }
}
