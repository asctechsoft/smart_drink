import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartdrinkai/presentation/common_components/ruler_picker.dart';

/// Locates the ruler's parts on screen so the glowing dot, the rail and the
/// selected number can be checked against each other numerically.
void main() {
  const screenWidth = 312.0; // 360dp screen minus the screens' 24dp padding

  Future<void> pumpRuler(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: screenWidth,
              child: RulerPicker(
                minValue: 100,
                maxValue: 250,
                initialValue: 170,
                unit: 'cm',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dot sits on the rail and clear of the selected number', (
    tester,
  ) async {
    await pumpRuler(tester);

    // The selected value appears twice: the big header and the ruler row.
    final labels = tester.widgetList<Text>(find.text('170')).toList();
    expect(labels.length, 2, reason: 'header + selected row label');

    final rowLabel = find.text('170').last;
    final labelRect = tester.getRect(rowLabel);

    // The dot is the only 20x20 circular container.
    final dot = find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final d = w.decoration;
      return d is BoxDecoration &&
          d.shape == BoxShape.circle &&
          w.constraints?.maxWidth == 20;
    });
    expect(dot, findsOneWidget);
    final dotRect = tester.getRect(dot);

    final rulerRect = tester.getRect(
      find.ancestor(of: dot, matching: find.byType(Stack)).last,
    );

    debugPrint('ruler:  ${rulerRect.left} .. ${rulerRect.right}');
    debugPrint('label:  ${labelRect.left} .. ${labelRect.right}');
    debugPrint('dot:    ${dotRect.left} .. ${dotRect.right}');

    // The dot must be fully to the right of the number, never across it.
    expect(
      dotRect.left,
      greaterThan(labelRect.right),
      reason: 'glowing dot must not overlap the number',
    );

    // The dot rides the rail, which sits on the component's centre line.
    expect(dotRect.center.dx, closeTo(rulerRect.center.dx, 2));

    // Number is left of centre, ticks to the right of it.
    expect(labelRect.right, lessThan(rulerRect.center.dx));

    // The dot is vertically centred on the selected number.
    expect(dotRect.center.dy, closeTo(labelRect.center.dy, 2));
  });
}
