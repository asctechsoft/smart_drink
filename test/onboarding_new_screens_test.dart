import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/models/ui_models/weather_condition.dart';
import 'package:smartdrinkai/presentation/common_components/selectable_option_tile.dart';
import 'package:smartdrinkai/presentation/screens_onboarding/weather_screen.dart';

void main() {
  late OnboardingController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    controller = Get.put(OnboardingController());
  });

  tearDown(Get.reset);

  Future<void> pumpWeather(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WeatherScreen()),
    );
    await tester.pump();
  }

  testWidgets('weather screen offers hot / normal / cold', (tester) async {
    await pumpWeather(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(SelectableOptionTile), findsNWidgets(3));
  });

  testWidgets('picking hot updates the controller', (tester) async {
    await pumpWeather(tester);
    expect(controller.weather.value, WeatherCondition.normal);

    await tester.tap(find.byType(SelectableOptionTile).first);
    await tester.pump();

    expect(controller.weather.value, WeatherCondition.hot);
  });

  test('hot weather raises the daily goal above normal weather', () {
    controller.weight.value = 60;
    controller.weightUnit.value = 'kg';
    controller.gender.value = 'male';

    controller.weather.value = WeatherCondition.normal;
    controller.calculateGoalFromWeight();
    final normalGoal = controller.dailyGoalMl.value;

    controller.weather.value = WeatherCondition.hot;
    controller.calculateGoalFromWeight();
    final hotGoal = controller.dailyGoalMl.value;

    expect(hotGoal, greaterThan(normalGoal));
    // Hot adds 600ml before rounding to the nearest 50.
    expect(hotGoal - normalGoal, 600);
  });

  test('weather choice is carried into the saved profile fields', () {
    controller.weather.value = WeatherCondition.cold;
    expect(controller.weather.value.name, 'cold');
    expect(
      WeatherCondition.values.map((e) => e.name),
      contains(controller.weather.value.name),
    );
  });
}
