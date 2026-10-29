import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_mobile/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  testWidgets('advances through onboarding and completes on the last page', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onComplete: () => completed = true),
      ),
    );

    expect(find.text('İngilizceye sağlam bir başlangıç'), findsOneWidget);
    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    expect(find.text('Kendi öğrenme yolunu keşfet'), findsOneWidget);

    await tester.tap(find.text('Atla'));
    expect(completed, isTrue);
  });
}
