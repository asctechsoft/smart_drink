import '../ui_models/activity_level.dart';
import '../ui_models/weather_condition.dart';

class UserProfile {
  final int id;
  final String gender;
  final double weight;
  final String weightUnit;
  final double height;
  final String heightUnit;
  final int age;
  final String wakeUpTime;
  final String bedTime;
  final int dailyGoalMl;
  final String volumeUnit;
  final String activityLevel;
  final String weatherCondition;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id = 1,
    this.gender = 'female',
    this.weight = 60,
    this.weightUnit = 'kg',
    this.height = 165,
    this.heightUnit = 'cm',
    this.age = 25,
    this.wakeUpTime = '07:00',
    this.bedTime = '22:00',
    this.dailyGoalMl = 2000,
    this.volumeUnit = 'ml',
    this.activityLevel = 'sedentary',
    this.weatherCondition = 'normal',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'weight': weight,
      'weight_unit': weightUnit,
      'height': height,
      'height_unit': heightUnit,
      'age': age,
      'wake_up_time': wakeUpTime,
      'bed_time': bedTime,
      'daily_goal_ml': dailyGoalMl,
      'volume_unit': volumeUnit,
      'activity_level': activityLevel,
      'weather_condition': weatherCondition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int? ?? 1,
      gender: map['gender'] as String? ?? 'female',
      weight: (map['weight'] as num?)?.toDouble() ?? 60,
      weightUnit: map['weight_unit'] as String? ?? 'kg',
      height: (map['height'] as num?)?.toDouble() ?? 165,
      heightUnit: map['height_unit'] as String? ?? 'cm',
      age: map['age'] as int? ?? 25,
      wakeUpTime: map['wake_up_time'] as String? ?? '07:00',
      bedTime: map['bed_time'] as String? ?? '22:00',
      dailyGoalMl: map['daily_goal_ml'] as int? ?? 2000,
      volumeUnit: map['volume_unit'] as String? ?? 'ml',
      activityLevel:
          ActivityLevel.values.any(
            (e) => e.name == (map['activity_level'] as String?),
          )
          ? map['activity_level'] as String
          : 'sedentary',
      weatherCondition:
          WeatherCondition.values.any(
            (e) => e.name == (map['weather_condition'] as String?),
          )
          ? map['weather_condition'] as String
          : 'normal',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserProfile copyWith({
    int? id,
    String? gender,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    int? age,
    String? wakeUpTime,
    String? bedTime,
    int? dailyGoalMl,
    String? volumeUnit,
    String? activityLevel,
    String? weatherCondition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      age: age ?? this.age,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      bedTime: bedTime ?? this.bedTime,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      activityLevel: activityLevel ?? this.activityLevel,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

