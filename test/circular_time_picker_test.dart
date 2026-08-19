import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/presentation/common_components/circular_time_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'time_format': '24h'});
    Get.testMode = true;
    Get.put(SettingsController());
  });

  tearDown(Get.reset);

  Future<void> pumpDial(
    WidgetTester tester, {
    required bool isNight,
    required String time,
    ValueChanged<String>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularTimePicker(
              initialTime: time,
              isNight: isNight,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('day dial paints and shows the initial time', (tester) async {
    await pumpDial(tester, isNight: false, time: '06:30');
    expect(tester.takeException(), isNull);
    expect(find.text('06:30'), findsOneWidget);
    // Hour markers around the face.
    for (final label in ['00', '06', '12', '18']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('night dial paints the crescent without error', (tester) async {
    await pumpDial(tester, isNight: true, time: '22:30');
    expect(tester.takeException(), isNull);
    expect(find.text('22:30'), findsOneWidget);
  });

  testWidgets('dragging the dial reports a snapped time', (tester) async {
    String? reported;
    await pumpDial(
      tester,
      isNight: false,
      time: '00:00',
      onChanged: (t) => reported = t,
    );

    // Drag to the dial's right edge, which is 06:00 on a 24h face.
    final center = tester.getCenter(find.byType(CircularTimePicker));
    final radius = tester.getSize(find.byType(CircularTimePicker)).width / 2;
    await tester.dragFrom(center, Offset(radius - 6, 0));
    await tester.pump();

    expect(reported, '06:00');
    expect(find.text('06:00'), findsOneWidget);
  });
}
