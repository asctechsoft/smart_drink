class ReminderSchedule {
  final int? id;
  final String mode;
  final String time;
  final String label;
  final bool enabled;
  final int intervalMinutes;
  final String repeatDays;

  const ReminderSchedule({
    this.id,
    this.mode = 'standard',
    this.time = '08:00',
    this.label = '',
    this.enabled = true,
    this.intervalMinutes = 90,
    this.repeatDays = '1,2,3,4,5',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mode': mode,
      'time': time,
      'label': label,
      'enabled': enabled ? 1 : 0,
      'interval_minutes': intervalMinutes,
      'repeat_days': repeatDays,
    };
  }

  factory ReminderSchedule.fromMap(Map<String, dynamic> map) {
    return ReminderSchedule(
      id: map['id'] as int?,
      mode: map['mode'] as String? ?? 'standard',
      time: RegExp(r'^\d{2}:\d{2}$').hasMatch(map['time'] as String? ?? '')
          ? map['time'] as String
          : '08:00',
      label: map['label'] as String? ?? '',
      enabled: (map['enabled'] as int? ?? 1) == 1,
      intervalMinutes: map['interval_minutes'] as int? ?? 90,
      repeatDays: map['repeat_days'] as String? ?? '1,2,3,4,5',
    );
  }

  ReminderSchedule copyWith({
    int? id,
    String? mode,
    String? time,
    String? label,
    bool? enabled,
    int? intervalMinutes,
    String? repeatDays,
  }) {
    return ReminderSchedule(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      time: time ?? this.time,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}

