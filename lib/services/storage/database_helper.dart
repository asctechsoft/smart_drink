import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;
  Completer<Database>? _initCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _initCompleter!.complete(_database!);
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // On web: databaseFactory is already set to databaseFactoryFfiWeb
      // by configureSqfliteForWeb() in main.dart — just pass the name.
      return openDatabase(
        DbSchema.dbName,
        version: DbSchema.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/${DbSchema.dbName}';
    return openDatabase(
      path,
      version: DbSchema.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DbSchema.createUserProfile);
    await db.execute(DbSchema.createDrinkRecord);
    await db.execute(DbSchema.createDrinkRecordIndex);
    await db.execute(DbSchema.createDailySummary);
    await db.execute(DbSchema.createReminderSchedule);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(DbSchema.migrationV2AddOriginalAmount);
      await db.execute(DbSchema.migrationV2BackfillOriginalAmount);
    }
  }
}

