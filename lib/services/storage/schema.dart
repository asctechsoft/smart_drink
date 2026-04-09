class DbSchema {
  static const String dbName = 'drink_water.db';
  static const int dbVersion = 2;

  static const String tableUserProfile = 'user_profile';
  static const String tableDrinkRecord = 'drink_record';
  static const String tableDailySummary = 'daily_summary';
  static const String tableReminderSchedule = 'reminder_schedule';

  static const String createUserProfile =
      '''
    CREATE TABLE $tableUserProfile (
      id INTEGER PRIMARY KEY DEFAULT 1,
      gender TEXT NOT NULL DEFAULT 'female',
      weight REAL NOT NULL DEFAULT 60,
      weight_unit TEXT NOT NULL DEFAULT 'kg',
      height REAL NOT NULL DEFAULT 165,
      height_unit TEXT NOT NULL DEFAULT 'cm',
      age INTEGER NOT NULL DEFAULT 25,
      wake_up_time TEXT NOT NULL DEFAULT '07:00',
      bed_time TEXT NOT NULL DEFAULT '22:00',
      daily_goal_ml INTEGER NOT NULL DEFAULT 2000,
      volume_unit TEXT NOT NULL DEFAULT 'ml',
      activity_level TEXT NOT NULL DEFAULT 'sedentary',
      weather_condition TEXT NOT NULL DEFAULT 'normal',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String createDrinkRecord =
      '''
    CREATE TABLE $tableDrinkRecord (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount_ml INTEGER NOT NULL,
      original_amount_ml INTEGER NOT NULL DEFAULT 0,
      drink_type TEXT NOT NULL DEFAULT 'water',
      timestamp TEXT NOT NULL,
      date_key TEXT NOT NULL
    )
  ''';

  static const String migrationV2AddOriginalAmount =
      '''
    ALTER TABLE $tableDrinkRecord ADD COLUMN original_amount_ml INTEGER NOT NULL DEFAULT 0
  ''';

  static const String migrationV2BackfillOriginalAmount =
      '''
    UPDATE $tableDrinkRecord SET original_amount_ml = amount_ml WHERE original_amount_ml = 0
  ''';

  static const String createDrinkRecordIndex =
      '''
    CREATE INDEX idx_drink_record_date_key ON $tableDrinkRecord (date_key)
  ''';

  static const String createDailySummary =
      '''
    CREATE TABLE $tableDailySummary (
      date_key TEXT PRIMARY KEY,
      total_ml INTEGER NOT NULL DEFAULT 0,
      goal_ml INTEGER NOT NULL DEFAULT 2000,
      drink_count INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String createReminderSchedule =
      '''
    CREATE TABLE $tableReminderSchedule (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mode TEXT NOT NULL DEFAULT 'standard',
      time TEXT NOT NULL DEFAULT '08:00',
      label TEXT NOT NULL DEFAULT '',
      enabled INTEGER NOT NULL DEFAULT 1,
      interval_minutes INTEGER NOT NULL DEFAULT 90,
      repeat_days TEXT NOT NULL DEFAULT '1,2,3,4,5'
    )
  ''';
}

