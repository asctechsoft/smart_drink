import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/services/storage/database_helper.dart';
import 'package:smartdrinkai/services/storage/schema.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DrinkRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertDrinkRecord(DrinkRecord record) async {
    try {
      final db = await _dbHelper.database;
      return db.insert(DbSchema.tableDrinkRecord, record.toMap());
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.insertDrinkRecord failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> updateDrinkRecord(DrinkRecord record) async {
    try {
      final db = await _dbHelper.database;
      return db.update(
        DbSchema.tableDrinkRecord,
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.updateDrinkRecord failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> deleteDrinkRecord(int id) async {
    try {
      final db = await _dbHelper.database;
      return db.delete(
        DbSchema.tableDrinkRecord,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.deleteDrinkRecord failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<DrinkRecord>> getDrinkRecordsByDate(String dateKey) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbSchema.tableDrinkRecord,
        where: 'date_key = ?',
        whereArgs: [dateKey],
        orderBy: 'timestamp DESC',
      );
      return maps.map((m) => DrinkRecord.fromMap(m)).toList();
    } catch (e, stackTrace) {
      debugPrint(
        'DrinkRepository.getDrinkRecordsByDate failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<List<DrinkRecord>> getDrinkRecordsBetween(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbSchema.tableDrinkRecord,
        where: 'date_key >= ? AND date_key <= ?',
        whereArgs: [startDate, endDate],
        orderBy: 'timestamp ASC',
      );
      return maps.map((m) => DrinkRecord.fromMap(m)).toList();
    } catch (e, stackTrace) {
      debugPrint(
        'DrinkRepository.getDrinkRecordsBetween failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<int> getTotalMlByDate(String dateKey) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount_ml) as total FROM ${DbSchema.tableDrinkRecord} WHERE date_key = ?',
        [dateKey],
      );
      if (result.isEmpty) return 0;
      return (result.first['total'] as int?) ?? 0;
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.getTotalMlByDate failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> upsertDailySummary(DailySummary summary) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DbSchema.tableDailySummary,
        summary.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.upsertDailySummary failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<DailySummary?> getDailySummary(String dateKey) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbSchema.tableDailySummary,
        where: 'date_key = ?',
        whereArgs: [dateKey],
      );
      if (maps.isEmpty) return null;
      return DailySummary.fromMap(maps.first);
    } catch (e, stackTrace) {
      debugPrint('DrinkRepository.getDailySummary failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<DailySummary>> getDailySummariesBetween(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbSchema.tableDailySummary,
        where: 'date_key >= ? AND date_key <= ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date_key ASC',
      );
      return maps.map((m) => DailySummary.fromMap(m)).toList();
    } catch (e, stackTrace) {
      debugPrint(
        'DrinkRepository.getDailySummariesBetween failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }
}

