import 'package:smartdrinkai/models/data_models/user_profile.dart';
import 'package:smartdrinkai/models/ui_models/activity_level.dart';
import 'package:smartdrinkai/models/ui_models/weather_condition.dart';

class WaterCalculation {
  static int calculateDailyGoal({
    required double weightKg,
    String gender = 'female',
    ActivityLevel activity = ActivityLevel.sedentary,
    WeatherCondition weather = WeatherCondition.normal,
  }) {
    // Basic rule: ~35ml/kg for males, ~31ml/kg for females (simplified average)
    final mlPerKg = gender.toLowerCase() == 'male' ? 35 : 31;
    final baseMl = (weightKg * mlPerKg).round();
    final adjusted = baseMl + activity.extraMl + weather.extraMl;
    return (adjusted / 50).round() * 50;
  }

  static int adjustGoal({
    required int baseMl,
    ActivityLevel activity = ActivityLevel.sedentary,
    WeatherCondition weather = WeatherCondition.normal,
  }) {
    return baseMl + activity.extraMl + weather.extraMl;
  }

  static int calculateDailyGoalFromProfile(UserProfile profile) {
    return calculateDailyGoal(
      weightKg: profile.weightUnit == 'kg'
          ? profile.weight
          : profile.weight * 0.453592,
      gender: profile.gender,
      activity: ActivityLevel.values.firstWhere(
        (e) => e.name == profile.activityLevel,
        orElse: () => ActivityLevel.sedentary,
      ),
      weather: WeatherCondition.values.firstWhere(
        (e) => e.name == profile.weatherCondition,
        orElse: () => WeatherCondition.normal,
      ),
    );
  }

  static double progressPercent(int currentMl, int goalMl) {
    if (goalMl <= 0) return 0;
    return currentMl / goalMl;
  }
}

