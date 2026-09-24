import 'package:dsp_base/convenience_imports.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/tour/tour_controller.dart';
import 'package:waternudge/tour/tour_steps.dart';
import 'package:waternudge/utils/analytics.dart';

typedef _Event = ({String name, Map<String, Object>? parameters});

/// A controller with all three Today anchors already registered (so
/// `startGroup` never blocks on `waitForAnchor`) and a fixed A/B [variant] —
/// tests never touch Remote Config.
TourController _controllerWith(String variant) {
  final controller = TourController(readVariant: () => variant);
  for (final step in tourSteps) {
    controller.registerAnchor(step.anchorId, GlobalKey());
  }
  return controller;
}

/// Runs [actions] against a fresh controller and returns every event the
/// walk emitted, in order.
Future<List<_Event>> _walk(
  String variant,
  List<Future<void> Function(TourController)> actions,
) async {
  final events = <_Event>[];
  Analytics.setEventSinkForTest(
    (name, parameters) => events.add((name: name, parameters: parameters)),
  );
  // Each walk simulates a fresh install: a previous walk in the same test
  // marks the tour done, which would otherwise block every walk after the
  // first from starting at all.
  await PrefAssist.setBoolean(PrefConst.coachMarkHomeSeen, false);
  final controller = _controllerWith(variant);
  await controller.start();
  for (final action in actions) {
    await action(controller);
  }
  return events;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefAssist.init();
  });

  tearDown(Analytics.resetEventSinkForTest);

  group('behaviour — exact event sequence for a walk', () {
    test('start, next, next, previous emits action before view, in order', () async {
      final events = await _walk(TourController.variantPlain, [
        (c) => c.next(), // step1 -> step2
        (c) => c.next(), // step2 -> step3
        (c) => c.previous(), // step3 -> step2
      ]);

      expect(events.map((e) => e.name), [
        'tour_today_step1_view',
        'tour_today_step1_next_tap',
        'tour_today_step2_view',
        'tour_today_step2_next_tap',
        'tour_today_step3_view',
        'tour_today_step3_previous_tap', // fires on the step being LEFT
        'tour_today_step2_view', // then the step being landed on
      ]);
    });

    test('every event carries the variant as a parameter, not in the name', () async {
      final events = await _walk(TourController.variantPlain, []);

      expect(events, hasLength(1)); // just the initial step1_view
      expect(events.single.name, 'tour_today_step1_view');
      expect(events.single.parameters, {'variant': 'plain'});
    });

    test('previous is a no-op on the first step — no previous_tap exists', () async {
      final events = await _walk(TourController.variantPulse, [
        (c) => c.previous(),
      ]);

      expect(events.map((e) => e.name), ['tour_today_step1_view']);
    });

    test('the last step\'s primary action is gotit_tap, not next_tap', () async {
      final events = await _walk(TourController.variantPulse, [
        (c) => c.next(),
        (c) => c.next(),
      ]);

      expect(events.map((e) => e.name), [
        'tour_today_step1_view',
        'tour_today_step1_next_tap',
        'tour_today_step2_view',
        'tour_today_step2_next_tap',
        'tour_today_step3_view',
      ]);
    });

    test('completing the last step ends the tour with no further next event', () async {
      final events = await _walk(TourController.variantPulse, [
        (c) => c.next(),
        (c) => c.next(),
        (c) => c.next(), // completes from step3
      ]);

      expect(events.last.name, 'tour_today_step3_gotit_tap');
      expect(events.where((e) => e.name.contains('step3')), hasLength(2)); // view + gotit_tap
    });

    test('skip logs close_tap for the step the user was actually on', () async {
      final events = await _walk(TourController.variantPulse, [
        (c) => c.next(),
        (c) => c.skip(),
      ]);

      expect(events.last.name, 'tour_today_step2_close_tap');
    });

    test('marks the tour done so a second start() this session does nothing', () async {
      final events = <_Event>[];
      Analytics.setEventSinkForTest(
        (name, parameters) => events.add((name: name, parameters: parameters)),
      );
      final controller = _controllerWith(TourController.variantPulse);
      expect(await controller.start(), isTrue);
      await controller.skip();

      final second = _controllerWith(TourController.variantPulse);
      expect(await second.start(), isFalse);
    });
  });

  group('spec mirror — every distinct event name the tour can produce', () {
    test('matches docs/analytics_spec.md §5 by set equality', () async {
      final names = <String>{};

      // Close from every step.
      names.addAll((await _walk(TourController.variantPulse, [])).map((e) => e.name));
      names.addAll(
        (await _walk(TourController.variantPulse, [(c) => c.skip()])).map((e) => e.name),
      );
      names.addAll(
        (await _walk(TourController.variantPulse, [
          (c) => c.next(),
          (c) => c.skip(),
        ])).map((e) => e.name),
      );
      names.addAll(
        (await _walk(TourController.variantPulse, [
          (c) => c.next(),
          (c) => c.next(),
          (c) => c.skip(),
        ])).map((e) => e.name),
      );
      // Previous from every step that has one.
      names.addAll(
        (await _walk(TourController.variantPulse, [
          (c) => c.next(),
          (c) => c.previous(),
        ])).map((e) => e.name),
      );
      names.addAll(
        (await _walk(TourController.variantPulse, [
          (c) => c.next(),
          (c) => c.next(),
          (c) => c.previous(),
        ])).map((e) => e.name),
      );
      // Complete the whole group.
      names.addAll(
        (await _walk(TourController.variantPulse, [
          (c) => c.next(),
          (c) => c.next(),
          (c) => c.next(),
        ])).map((e) => e.name),
      );

      // Typed out literally — see docs/analytics_spec.md §5 and the porting
      // doc's note on why a generated loop defeats a spreadsheet Ctrl-F.
      expect(names, {
        'tour_today_step1_view',
        'tour_today_step1_next_tap',
        'tour_today_step1_close_tap',
        'tour_today_step2_view',
        'tour_today_step2_next_tap',
        'tour_today_step2_previous_tap',
        'tour_today_step2_close_tap',
        'tour_today_step3_view',
        'tour_today_step3_gotit_tap',
        'tour_today_step3_previous_tap',
        'tour_today_step3_close_tap',
      });
    });
  });

  group('A/B variant assignment', () {
    test('assignLocalVariant is sticky across calls', () async {
      await TourController.assignLocalVariant();
      final first = PrefAssist.getString(PrefConst.tourAbVariant);
      expect(first, isNotEmpty);

      await TourController.assignLocalVariant();
      final second = PrefAssist.getString(PrefConst.tourAbVariant);
      expect(second, first);
    });
  });
}
