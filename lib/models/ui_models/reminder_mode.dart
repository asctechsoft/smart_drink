enum ReminderMode {
  standard('Standard'),
  interval('Interval'),
  custom('Custom');

  final String label;

  const ReminderMode(this.label);

  static ReminderMode fromString(String value) {
    return ReminderMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderMode.standard,
    );
  }
}

