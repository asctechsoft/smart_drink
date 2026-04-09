import 'package:flutter_test/flutter_test.dart';
import 'package:smartdrinkai/utils/water_calculation.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/user_profile.dart';
import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/models/ui_models/activity_level.dart';
import 'package:smartdrinkai/models/ui_models/weather_condition.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/models/ui_models/reminder_mode.dart';

void main() {
  group('WaterCalculation', () {
    test('calculateDailyGoal returns reasonable values', () {
      final goal = WaterCalculation.calculateDailyGoal(weightKg: 70);
      expect(goal, greaterThan(1500));
      expect(goal, lessThan(4000));
    });

    test('calculateDailyGoal adjusts for activity level', () {
      final sedentary = WaterCalculation.calculateDailyGoal(
        weightKg: 70,
        activity: ActivityLevel.sedentary,
      );
      final active = WaterCalculation.calculateDailyGoal(
        weightKg: 70,
        activity: ActivityLevel.veryActive,
      );
      expect(active, greaterThan(sedentary));
    });

    test('calculateDailyGoal adjusts for weather', () {
      final normal = WaterCalculation.calculateDailyGoal(
        weightKg: 70,
        weather: WeatherCondition.normal,
      );
      final hot = WaterCalculation.calculateDailyGoal(
        weightKg: 70,
        weather: WeatherCondition.hot,
      );
      expect(hot, greaterThan(normal));
    });

    test('progressPercent clamps between 0 and 1', () {
      expect(WaterCalculation.progressPercent(0, 2000), 0.0);
      expect(WaterCalculation.progressPercent(1000, 2000), 0.5);
      expect(WaterCalculation.progressPercent(3000, 2000), 1.0);
      expect(WaterCalculation.progressPercent(500, 0), 0.0);
    });

    test('adjustGoal adds extras correctly', () {
      final adjusted = WaterCalculation.adjustGoal(
        baseMl: 2000,
        activity: ActivityLevel.veryActive,
        weather: WeatherCondition.hot,
      );
      expect(adjusted, 2000 + 1000 + 600);
    });
  });

  group('UnitConverter', () {
    test('ml to oz and back', () {
      final oz = UnitConverter.mlToOz(1000);
      final backToMl = UnitConverter.ozToMl(oz);
      expect(backToMl, closeTo(1000, 1));
    });

    test('kg to lb and back', () {
      final lb = UnitConverter.kgToLb(70);
      final backToKg = UnitConverter.lbToKg(lb);
      expect(backToKg, closeTo(70, 0.01));
    });

    test('formatVolume in ml and oz', () {
      expect(UnitConverter.formatVolume(500, 'ml'), '500 ml');
      expect(UnitConverter.formatVolume(500, 'oz'), contains('oz'));
    });

    test('formatWeight in kg and lb', () {
      expect(UnitConverter.formatWeight(70, 'kg'), '70 kg');
      expect(UnitConverter.formatWeight(70, 'lb'), contains('lb'));
    });
  });

  group('AppDateUtils', () {
    test('formatDateKey pads correctly', () {
      final key = AppDateUtils.formatDateKey(DateTime(2024, 1, 5));
      expect(key, '2024-01-05');
    });

    test('parseDateKey round-trips', () {
      const key = '2024-03-15';
      final dt = AppDateUtils.parseDateKey(key);
      expect(dt.year, 2024);
      expect(dt.month, 3);
      expect(dt.day, 15);
    });

    test('startOfWeek returns Monday', () {
      // 2024-03-15 is a Friday
      final start = AppDateUtils.startOfWeek(DateTime(2024, 3, 15));
      expect(start.weekday, DateTime.monday);
    });

    test('endOfWeek returns Sunday', () {
      final end = AppDateUtils.endOfWeek(DateTime(2024, 3, 15));
      expect(end.weekday, DateTime.sunday);
    });

    test('startOfMonth and endOfMonth', () {
      final start = AppDateUtils.startOfMonth(DateTime(2024, 3, 15));
      expect(start.day, 1);
      final end = AppDateUtils.endOfMonth(DateTime(2024, 3, 15));
      expect(end.day, 31);
    });

    test('formatTime12h converts correctly', () {
      expect(AppDateUtils.formatTime12h('13:30'), '01:30 PM');
      expect(AppDateUtils.formatTime12h('09:00'), '09:00 AM');
      expect(AppDateUtils.formatTime12h('00:15'), '12:15 AM');
    });

    test('formatTime12h returns 12:00 AM for invalid values', () {
      expect(AppDateUtils.formatTime12h('25:00'), '12:00 AM');
      expect(AppDateUtils.formatTime12h('12:61'), '12:00 AM');
      expect(AppDateUtils.formatTime12h('-1:00'), '12:00 AM');
      expect(AppDateUtils.formatTime12h('abc'), '12:00 AM');
      expect(AppDateUtils.formatTime12h(''), '12:00 AM');
    });
  });

  group('DrinkRecord', () {
    test('toMap and fromMap round-trip', () {
      final record = DrinkRecord(
        amountMl: 250,
        originalAmountMl: 300,
        drinkType: 'tea',
      );
      final map = record.toMap();
      final restored = DrinkRecord.fromMap(map);
      expect(restored.amountMl, 250);
      expect(restored.originalAmountMl, 300);
      expect(restored.drinkType, 'tea');
    });

    test('copyWith preserves unmodified fields', () {
      final record = DrinkRecord(amountMl: 250, drinkType: 'water');
      final modified = record.copyWith(amountMl: 500);
      expect(modified.amountMl, 500);
      expect(modified.drinkType, 'water');
    });

    test('dateKey is set automatically from timestamp', () {
      final record = DrinkRecord(
        amountMl: 100,
        timestamp: DateTime(2024, 6, 15, 10, 30),
      );
      expect(record.dateKey, '2024-06-15');
    });

    test('fromMap with null date_key derives dateKey from timestamp', () {
      final record = DrinkRecord.fromMap({
        'amount_ml': 200,
        'timestamp': '2024-08-20T14:30:00.000',
      });
      expect(record.dateKey, '2024-08-20');
    });

    test('fromMap with empty date_key derives dateKey from timestamp', () {
      final record = DrinkRecord.fromMap({
        'amount_ml': 200,
        'timestamp': '2024-08-20T14:30:00.000',
        'date_key': '',
      });
      expect(record.dateKey, '2024-08-20');
    });

    test('constructor asserts amountMl is non-negative', () {
      expect(
        () => DrinkRecord(amountMl: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('DailySummary', () {
    test('toMap and fromMap round-trip', () {
      final summary = DailySummary(
        dateKey: '2024-03-15',
        totalMl: 1500,
        goalMl: 2000,
        drinkCount: 6,
      );
      final map = summary.toMap();
      final restored = DailySummary.fromMap(map);
      expect(restored.dateKey, '2024-03-15');
      expect(restored.totalMl, 1500);
      expect(restored.goalMl, 2000);
      expect(restored.drinkCount, 6);
    });

    test('fromMap with null date_key derives dateKey from updatedAt', () {
      final summary = DailySummary.fromMap({
        'total_ml': 500,
        'goal_ml': 2000,
        'drink_count': 2,
        'updated_at': '2024-09-10T08:00:00.000',
      });
      expect(summary.dateKey, '2024-09-10');
    });

    test('fromMap with empty date_key derives dateKey from updatedAt', () {
      final summary = DailySummary.fromMap({
        'total_ml': 500,
        'date_key': '',
        'updated_at': '2024-09-10T08:00:00.000',
      });
      expect(summary.dateKey, '2024-09-10');
    });
  });

  group('UserProfile', () {
    test('toMap and fromMap round-trip', () {
      final profile = UserProfile(
        gender: 'Male',
        weight: 80,
        weightUnit: 'kg',
        dailyGoalMl: 2500,
      );
      final map = profile.toMap();
      final restored = UserProfile.fromMap(map);
      expect(restored.gender, 'Male');
      expect(restored.weight, 80);
      expect(restored.dailyGoalMl, 2500);
    });

    test('copyWith works correctly', () {
      final profile = UserProfile(gender: 'Female', weight: 60);
      final modified = profile.copyWith(weight: 65, gender: 'Male');
      expect(modified.weight, 65);
      expect(modified.gender, 'Male');
      expect(modified.dailyGoalMl, profile.dailyGoalMl);
    });

    test('default values are sensible', () {
      final profile = UserProfile();
      expect(profile.weight, greaterThan(0));
      expect(profile.dailyGoalMl, greaterThan(0));
      expect(profile.wakeUpTime, isNotEmpty);
      expect(profile.bedTime, isNotEmpty);
    });

    test('fromMap with invalid activityLevel falls back to sedentary', () {
      final profile = UserProfile.fromMap({
        'activity_level': 'nonexistent_level',
        'weather_condition': 'normal',
      });
      expect(profile.activityLevel, 'sedentary');
    });

    test('fromMap with invalid weatherCondition falls back to normal', () {
      final profile = UserProfile.fromMap({
        'activity_level': 'sedentary',
        'weather_condition': 'invalid_weather',
      });
      expect(profile.weatherCondition, 'normal');
    });
  });

  group('ActivityLevel', () {
    test('all levels have non-negative extraMl', () {
      for (final level in ActivityLevel.values) {
        expect(level.extraMl, greaterThanOrEqualTo(0));
      }
    });

    test('higher activity = more water', () {
      expect(
        ActivityLevel.veryActive.extraMl,
        greaterThan(ActivityLevel.sedentary.extraMl),
      );
    });
  });

  group('WeatherCondition', () {
    test('hot weather requires more water', () {
      expect(
        WeatherCondition.hot.extraMl,
        greaterThan(WeatherCondition.normal.extraMl),
      );
    });
  });

  group('ReminderSchedule', () {
    test('toMap and fromMap round-trip', () {
      final schedule = ReminderSchedule(
        id: 5,
        mode: 'interval',
        time: '09:30',
        label: 'Morning reminder',
        enabled: true,
        intervalMinutes: 60,
        repeatDays: '1,2,3,4,5,6,7',
      );
      final map = schedule.toMap();
      final restored = ReminderSchedule.fromMap(map);
      expect(restored.id, 5);
      expect(restored.mode, 'interval');
      expect(restored.time, '09:30');
      expect(restored.label, 'Morning reminder');
      expect(restored.enabled, true);
      expect(restored.intervalMinutes, 60);
      expect(restored.repeatDays, '1,2,3,4,5,6,7');
    });

    test('copyWith preserves unmodified fields', () {
      final schedule = ReminderSchedule(
        mode: 'custom',
        time: '10:00',
        label: 'Test',
        intervalMinutes: 120,
      );
      final modified = schedule.copyWith(time: '14:00');
      expect(modified.time, '14:00');
      expect(modified.mode, 'custom');
      expect(modified.label, 'Test');
      expect(modified.intervalMinutes, 120);
      expect(modified.enabled, true);
    });

    test('default values are sensible', () {
      final schedule = ReminderSchedule();
      expect(schedule.mode, 'standard');
      expect(schedule.time, '08:00');
      expect(schedule.enabled, true);
      expect(schedule.intervalMinutes, greaterThan(0));
      expect(schedule.repeatDays, isNotEmpty);
    });

    test('fromMap with invalid time format falls back to 08:00', () {
      final schedule = ReminderSchedule.fromMap({
        'time': 'not-a-time',
      });
      expect(schedule.time, '08:00');
    });

    test('fromMap with null time falls back to 08:00', () {
      final schedule = ReminderSchedule.fromMap({
        'mode': 'standard',
      });
      expect(schedule.time, '08:00');
    });

    test('fromMap with malformed time falls back to 08:00', () {
      final schedule = ReminderSchedule.fromMap({
        'time': '9:30',
      });
      expect(schedule.time, '08:00');
    });
  });

  group('DrinkType', () {
    test('all drink types have non-empty labels', () {
      for (final type in DrinkType.values) {
        expect(type.label, isNotEmpty, reason: '${type.name} label is empty');
      }
    });

    test('all drink types have valid waterPercent (0-100)', () {
      for (final type in DrinkType.values) {
        expect(type.waterPercent, greaterThanOrEqualTo(0),
            reason: '${type.name} waterPercent below 0');
        expect(type.waterPercent, lessThanOrEqualTo(100),
            reason: '${type.name} waterPercent above 100');
      }
    });

    test('all drink types have non-empty imagePath', () {
      for (final type in DrinkType.values) {
        expect(type.imagePath, isNotEmpty,
            reason: '${type.name} imagePath is empty');
      }
    });

    test('water has 100% waterPercent', () {
      expect(DrinkType.water.waterPercent, 100);
    });
  });

  group('ReminderMode', () {
    test('fromString round-trips for all modes', () {
      for (final mode in ReminderMode.values) {
        final restored = ReminderMode.fromString(mode.name);
        expect(restored, mode);
      }
    });

    test('fromString defaults to standard for invalid input', () {
      expect(ReminderMode.fromString('nonexistent'), ReminderMode.standard);
      expect(ReminderMode.fromString(''), ReminderMode.standard);
    });
  });

  group('WaterCalculation edge cases', () {
    test('calculateDailyGoal with very low weight (30kg)', () {
      final goal = WaterCalculation.calculateDailyGoal(weightKg: 30);
      expect(goal, greaterThan(0));
      expect(goal, lessThan(2000));
    });

    test('calculateDailyGoal with very high weight (150kg)', () {
      final goal = WaterCalculation.calculateDailyGoal(weightKg: 150);
      expect(goal, greaterThan(3000));
    });

    test('adjustGoal with cold weather (extraMl should be 0)', () {
      final adjusted = WaterCalculation.adjustGoal(
        baseMl: 2000,
        activity: ActivityLevel.sedentary,
        weather: WeatherCondition.cold,
      );
      expect(adjusted, 2000);
      expect(WeatherCondition.cold.extraMl, 0);
    });

    test('progressPercent with negative currentMl', () {
      final result = WaterCalculation.progressPercent(-100, 2000);
      expect(result, 0.0);
    });
  });

  group('UnitConverter edge cases', () {
    test('formatVolume with 0 ml', () {
      expect(UnitConverter.formatVolume(0, 'ml'), '0 ml');
      expect(UnitConverter.formatVolume(0, 'oz'), '0 oz');
    });

    test('formatWeight with 0 kg', () {
      expect(UnitConverter.formatWeight(0, 'kg'), '0 kg');
      expect(UnitConverter.formatWeight(0, 'lb'), '0 lb');
    });

    test('formatHeight with cm and m units', () {
      expect(UnitConverter.formatHeight(175, 'cm'), '175 cm');
      expect(UnitConverter.formatHeight(175, 'm'), '1.75 m');
    });

    test('cm to m and back round-trip', () {
      final m = UnitConverter.cmToM(180);
      final backToCm = UnitConverter.mToCm(m);
      expect(backToCm, closeTo(180, 0.01));
    });
  });

  group('DrinkRecord edge cases', () {
    test('copyWith preserves originalAmountMl when not overridden', () {
      final record = DrinkRecord(
        amountMl: 250,
        originalAmountMl: 300,
        drinkType: 'tea',
      );
      final modified = record.copyWith(amountMl: 400);
      expect(modified.amountMl, 400);
      expect(modified.originalAmountMl, 300);
    });

    test('record with 0 amount', () {
      final record = DrinkRecord(amountMl: 0);
      expect(record.amountMl, 0);
      expect(record.originalAmountMl, 0);
      expect(record.drinkType, 'water');
      final map = record.toMap();
      final restored = DrinkRecord.fromMap(map);
      expect(restored.amountMl, 0);
    });
  });
}

