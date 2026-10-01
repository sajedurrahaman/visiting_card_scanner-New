import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visiting_card/features/template/domain/visiting_card_field_transform.dart';
import 'package:visiting_card/features/template/presentation/view_model/visiting_card_edit_contact_viewmodel.dart';

void main() {
  VisitingCardEditContactViewModel createVm() => VisitingCardEditContactViewModel(
    templateId: 'h1', isHorizontal: true,
    frontAssetWithoutData: '', backAssetWithoutData: '',
  );
  const field = VisitingCardOverlayField.name;
  const key = 'dup:shape-test';
  const initial = VisitingCardFieldTransform(
    left: 0.4, top: 0.3, size: 0.2,
    duplicateOf: VisitingCardEditContactViewModel.customShapeSource,
  );

  for (final card in [const Size(350, 200), const Size(200, 320)]) {
    for (final horizontal in [true, false]) {
      for (final fixed in [true, false]) {
        for (final delta in [-8.0, 12.0]) {
          test('shape edge $card horizontal=$horizontal fixed=$fixed delta=$delta', () {
            final vm = createVm();
            addTearDown(vm.dispose);
            // A non-square source shape, so height cannot be inferred from size.
            vm.currentOverlays[key] = initial;
            final width = card.width * initial.size;
            final height = width / 2;
            vm.stretchOverlayAxis(field, horizontal: horizontal,
              pixelDelta: delta, cardSize: card, fixOpposite: fixed,
              seedWidthFraction: width / card.width, seedHeightPx: height,
              duplicateId: 'shape-test');
            final next = vm.currentOverlays[key]!;
            final nextW = width * next.shapeScaleX;
            final nextH = height * next.shapeScaleY;
            expect(nextW, closeTo(width + (horizontal ? delta : 0), 1e-8));
            expect(nextH, closeTo(height + (horizontal ? 0 : delta), 1e-8));
            expect(next.size, initial.size);
            expect(next.left * card.width + (fixed ? nextW : 0),
              closeTo(initial.left * card.width + (fixed ? width : 0), 1e-8));
            expect(next.top * card.height + (fixed ? nextH : 0),
              closeTo(initial.top * card.height + (fixed ? height : 0), 1e-8));
            final restored = VisitingCardFieldTransform.fromJson(next.toJson());
            expect(restored.shapeScaleX, next.shapeScaleX);
            expect(restored.shapeScaleY, next.shapeScaleY);
          });
        }
      }
    }
  }

  test('rotated shape keeps opposite edge anchored', () {
    final vm = createVm();
    addTearDown(vm.dispose);
    const card = Size(350, 200);
    final rotated = initial.copyWith(rotation: math.pi / 3);
    vm.currentOverlays[key] = rotated;
    vm.stretchOverlayAxis(field, horizontal: true, pixelDelta: 10,
      cardSize: card, fixOpposite: true, seedWidthFraction: 0.2,
      seedHeightPx: 35, duplicateId: 'shape-test');
    final next = vm.currentOverlays[key]!;
    expect(next.left * card.width + 80 * math.cos(rotated.rotation),
      closeTo(rotated.left * card.width + 70 * math.cos(rotated.rotation), 1e-8));
    expect(next.top * card.height + 80 * math.sin(rotated.rotation),
      closeTo(rotated.top * card.height + 70 * math.sin(rotated.rotation), 1e-8));
  });

  test('shape corners retain the original image scaling behavior', () {
    final vm = createVm();
    addTearDown(vm.dispose);
    const card = Size(350, 200);
    final shape = initial.copyWith(shapeScaleX: 1.5, shapeScaleY: 0.8);
    vm.currentOverlays[key] = shape;
    vm.currentOverlays['logo'] = shape.copyWith(duplicateOf: 'logo');
    vm.scaleOverlayUniform(field, 14, card, duplicateId: 'shape-test',
      fixRight: true, fixBottom: true);
    vm.scaleOverlayUniform(VisitingCardOverlayField.logo, 14, card,
      fixRight: true, fixBottom: true);
    final next = vm.currentOverlays[key]!;
    final logo = vm.currentOverlays['logo']!;
    expect(next.size, logo.size);
    expect(next.left, logo.left);
    expect(next.top, logo.top);
    expect(next.shapeScaleX, shape.shapeScaleX);
    expect(next.shapeScaleY, shape.shapeScaleY);
  });

  test('logo edge resizing retains its previous uniform size behavior', () {
    final vm = createVm();
    addTearDown(vm.dispose);
    vm.currentOverlays['logo'] = initial.copyWith(duplicateOf: 'logo');
    vm.stretchOverlayAxis(VisitingCardOverlayField.logo,
      horizontal: true, pixelDelta: 10, cardSize: const Size(350, 200));
    final next = vm.currentOverlays['logo']!;
    expect(next.size, closeTo(initial.size + 10 / 350, 1e-8));
    expect(next.shapeScaleX, 1);
    expect(next.shapeScaleY, 1);
  });

  test('old saved transforms have no shape stretching', () {
    final restored = VisitingCardFieldTransform.fromJson({'left': 0.2, 'top': 0.3, 'size': 0.1});
    expect(restored.shapeScaleX, 1);
    expect(restored.shapeScaleY, 1);
  });
}
