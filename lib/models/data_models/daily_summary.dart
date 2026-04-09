class DailySummary {
  final String dateKey;
  final int totalMl;
  final int goalMl;
  final int drinkCount;
  final DateTime updatedAt;

  DailySummary({
    required this.dateKey,
    this.totalMl = 0,
    this.goalMl = 2000,
    this.drinkCount = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date_key': dateKey,
      'total_ml': totalMl,
      'goal_ml': goalMl,
      'drink_count': drinkCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    final updatedAt =
        DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now();
    final rawDateKey = map['date_key'] as String?;
    final dateKey = (rawDateKey != null && rawDateKey.isNotEmpty)
        ? rawDateKey
        : _formatDateKey(updatedAt);
    return DailySummary(
      dateKey: dateKey,
      totalMl: map['total_ml'] as int? ?? 0,
      goalMl: map['goal_ml'] as int? ?? 2000,
      drinkCount: map['drink_count'] as int? ?? 0,
      updatedAt: updatedAt,
    );
  }

  DailySummary copyWith({
    String? dateKey,
    int? totalMl,
    int? goalMl,
    int? drinkCount,
    DateTime? updatedAt,
  }) {
    return DailySummary(
      dateKey: dateKey ?? this.dateKey,
      totalMl: totalMl ?? this.totalMl,
      goalMl: goalMl ?? this.goalMl,
      drinkCount: drinkCount ?? this.drinkCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

