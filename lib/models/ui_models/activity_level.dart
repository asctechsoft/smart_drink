enum ActivityLevel {
  sedentary('sedentary', 'no_sports_or_exercise', 0),
  lightActive('light_active', 'work_out_1_2_times_a_week', 250),
  moderateActive('moderate_active', 'work_out_3_4_times_a_week', 600),
  veryActive('very_active', 'exercise_regularly', 1000);

  final String label;
  final String description;
  final int extraMl;

  const ActivityLevel(this.label, this.description, this.extraMl);
}

