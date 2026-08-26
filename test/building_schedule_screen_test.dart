import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/screens_onboarding/building_schedule_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.put(OnboardingController());
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BuildingScheduleScreen()),
    );
    await tester.pump();
  }

  testWidgets('ring starts at 0% and counts up while spinning', (tester) async {
    await pumpScreen(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('0%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2100));
    // Halfway through the 4.2s run.
    expect(find.text('50%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1050));
    expect(find.text('75%'), findsOneWidget);

    // Stop short of 100%: completion calls completeOnboarding, which needs the
    // database. The spin controller also repeats, so never pumpAndSettle here.
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('all three checklist rows are shown', (tester) async {
    await pumpScreen(tester);
    for (final key in const [
      'step_calculating_water_needs',
      'step_analyzing_habits',
      'step_building_schedule',
    ]) {
      expect(find.text(key.tr), findsOneWidget);
    }
    await tester.pump(const Duration(milliseconds: 1000));
  });

  testWidgets('steps tick off as the run progresses', (tester) async {
    await pumpScreen(tester);
    // Nothing done at the start.
    expect(find.byIcon(Icons.check_circle), findsNothing);

    // Past the first third.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Past the second third.
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
  });
}
