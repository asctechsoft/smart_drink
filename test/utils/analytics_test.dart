import 'package:flutter_test/flutter_test.dart';
import 'package:waternudge/utils/analytics.dart';

void main() {
  tearDown(Analytics.resetEventSinkForTest);

  group('isValidEventName', () {
    test('accepts a normal snake_case name', () {
      expect(Analytics.isValidEventName('drink_add_success'), isTrue);
    });

    test('rejects a name starting with a digit', () {
      expect(Analytics.isValidEventName('1_drink_add'), isFalse);
    });

    test('rejects a name over 40 characters', () {
      final tooLong = 'a' * 41;
      expect(Analytics.isValidEventName(tooLong), isFalse);
    });

    test('accepts a name at exactly 40 characters', () {
      final exact = 'a' * 40;
      expect(Analytics.isValidEventName(exact), isTrue);
    });

    test('rejects Firebase-reserved prefixes', () {
      expect(Analytics.isValidEventName('firebase_screen_view'), isFalse);
      expect(Analytics.isValidEventName('google_ad_click'), isFalse);
      expect(Analytics.isValidEventName('ga_session_start'), isFalse);
    });

    test('rejects a space or hyphen', () {
      expect(Analytics.isValidEventName('drink add'), isFalse);
      expect(Analytics.isValidEventName('drink-add'), isFalse);
    });
  });

  group('event sink', () {
    test('track() routes through the swapped sink with no platform channel', () {
      final events = <({String name, Map<String, Object>? parameters})>[];
      Analytics.setEventSinkForTest(
        (name, parameters) => events.add((name: name, parameters: parameters)),
      );

      Analytics.drinkAddSuccess(
        drinkType: 'water',
        amountMl: 250,
        totalMl: 500,
        goalMl: 2000,
        source: 'action_bar',
      );

      expect(events, hasLength(1));
      expect(events.single.name, 'drink_add_success');
      expect(events.single.parameters, {
        'drink_type': 'water',
        'amount_bucket': '200-299',
        'progress_bucket': '25-49',
        'source': 'action_bar',
      });
    });

    test('every parameter value is a String (GA4 drops numbers silently)', () {
      final events = <({String name, Map<String, Object>? parameters})>[];
      Analytics.setEventSinkForTest(
        (name, parameters) => events.add((name: name, parameters: parameters)),
      );

      // Exercise a representative spread of typed helpers, not just one.
      Analytics.drinkAddSuccess(
        drinkType: 'coffee',
        amountMl: 180,
        totalMl: 1800,
        goalMl: 2000,
        source: 'quick_add_button',
      );
      Analytics.reminderSave('interval', 4);
      Analytics.historyPeriodChange('next', 'week');
      Analytics.settingsHealthConnectToggle(enabled: true, success: false);

      for (final event in events) {
        for (final value in event.parameters?.values ?? const []) {
          expect(
            value,
            isA<String>(),
            reason: '${event.name} sent a non-String param: $value',
          );
        }
      }
    });
  });

  group('bucket helpers', () {
    test('volumeBucket bands are stable', () {
      expect(Analytics.volumeBucket(0), '0');
      expect(Analytics.volumeBucket(50), '<100');
      expect(Analytics.volumeBucket(150), '100-199');
      expect(Analytics.volumeBucket(1000), '1000+');
    });

    test('percentBucket handles a zero goal without dividing by zero', () {
      expect(Analytics.percentBucket(500, 0), 'unknown');
    });

    test('percentBucket bands progress correctly', () {
      expect(Analytics.percentBucket(0, 2000), '0');
      expect(Analytics.percentBucket(400, 2000), '1-24'); // 20%
      expect(Analytics.percentBucket(500, 2000), '25-49'); // 25%
      expect(Analytics.percentBucket(2000, 2000), '100-149');
      expect(Analytics.percentBucket(4000, 2000), '150+');
    });
  });
}
