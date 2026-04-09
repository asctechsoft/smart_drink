class DrinkRecord {
  final int? id;
  final int amountMl;
  final double originalAmountMl;
  final String drinkType;
  final DateTime timestamp;
  final String dateKey;

  DrinkRecord({
    this.id,
    required this.amountMl,
    double? originalAmountMl,
    this.drinkType = 'water',
    DateTime? timestamp,
    String? dateKey,
  }) : assert(amountMl >= 0),
       originalAmountMl = originalAmountMl ?? amountMl.toDouble(),
       timestamp = timestamp ?? DateTime.now(),
       dateKey = dateKey ?? _formatDateKey(timestamp ?? DateTime.now());

  static String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount_ml': amountMl,
      'original_amount_ml': originalAmountMl,
      'drink_type': drinkType,
      'timestamp': timestamp.toIso8601String(),
      'date_key': dateKey,
    };
  }

  factory DrinkRecord.fromMap(Map<String, dynamic> map) {
    final amountMl = map['amount_ml'] as int? ?? 0;
    final timestamp =
        DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now();
    final rawDateKey = map['date_key'] as String?;
    final dateKey = (rawDateKey != null && rawDateKey.isNotEmpty)
        ? rawDateKey
        : _formatDateKey(timestamp);
    return DrinkRecord(
      id: map['id'] as int?,
      amountMl: amountMl,
      originalAmountMl: (map['original_amount_ml'] as num? ?? amountMl).toDouble(),
      drinkType: map['drink_type'] as String? ?? 'water',
      timestamp: timestamp,
      dateKey: dateKey,
    );
  }

  DrinkRecord copyWith({
    int? id,
    int? amountMl,
    double? originalAmountMl,
    String? drinkType,
    DateTime? timestamp,
    String? dateKey,
  }) {
    return DrinkRecord(
      id: id ?? this.id,
      amountMl: amountMl ?? this.amountMl,
      originalAmountMl: originalAmountMl ?? this.originalAmountMl,
      drinkType: drinkType ?? this.drinkType,
      timestamp: timestamp ?? this.timestamp,
      dateKey: dateKey ?? this.dateKey,
    );
  }
}

