import 'package:smartdrinkai/models/data_models/daily_summary.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/repository/drink_repository.dart';
import 'package:smartdrinkai/services/storage/database_helper.dart';
import 'package:smartdrinkai/services/storage/schema.dart';
import 'package:smartdrinkai/utils/date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DrinkDataService {
  final DrinkRepository _drinkRepo = DrinkRepository();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addDrink({
    required int amountMl,
    double? originalAmountMl,
    String drinkType = 'water',
    int goalMl = 2000,
  }) async {
    final safeGoalMl = goalMl > 0 ? goalMl : 2000;
    try {
      final record = DrinkRecord(
        amountMl: amountMl,
        originalAmountMl: originalAmountMl,
        drinkType: drinkType,
      );
      final db = await _dbHelper.database;
      late int id;
      await db.transaction((txn) async {
        id = await txn.insert(DbSchema.tableDrinkRecord, record.toMap());
        await _updateDailySummaryInTxn(txn, record.dateKey, safeGoalMl);
      });
      return id;
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.addDrink failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _updateDailySummaryInTxn(
    Transaction txn,
    String dateKey,
    int goalMl,
  ) async {
    final totalResult = await txn.rawQuery(
      'SELECT SUM(amount_ml) as total FROM ${DbSchema.tableDrinkRecord} WHERE date_key = ?',
      [dateKey],
    );
    final totalMl = (totalResult.isEmpty)
        ? 0
        : (totalResult.first['total'] as int?) ?? 0;

    final countResult = await txn.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbSchema.tableDrinkRecord} WHERE date_key = ?',
      [dateKey],
    );
    final drinkCount = (countResult.isEmpty)
        ? 0
        : (countResult.first['cnt'] as int?) ?? 0;

    final summary = DailySummary(
      dateKey: dateKey,
      totalMl: totalMl,
      goalMl: goalMl,
      drinkCount: drinkCount,
    );
    await txn.insert(
      DbSchema.tableDailySummary,
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DrinkRecord>> getTodayRecords() async {
    try {
      final today = _todayKey();
      return _drinkRepo.getDrinkRecordsByDate(today);
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.getTodayRecords failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> getTodayTotal() async {
    try {
      final today = _todayKey();
      return _drinkRepo.getTotalMlByDate(today);
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.getTodayTotal failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<DrinkRecord>> getRecordsByDate(String dateKey) async {
    try {
      return await _drinkRepo.getDrinkRecordsByDate(dateKey);
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.getRecordsByDate failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<DrinkRecord>> getRecordsBetween(String start, String end) async {
    try {
      return await _drinkRepo.getDrinkRecordsBetween(start, end);
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.getRecordsBetween failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<DailySummary>> getSummariesBetween(
    String start,
    String end,
  ) async {
    try {
      return await _drinkRepo.getDailySummariesBetween(start, end);
    } catch (e, stackTrace) {
      debugPrint(
        'DrinkDataService.getSummariesBetween failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<int> updateRecord(DrinkRecord record, int goalMl) async {
    try {
      final db = await _dbHelper.database;
      late int result;
      await db.transaction((txn) async {
        result = await txn.update(
          DbSchema.tableDrinkRecord,
          record.toMap(),
          where: 'id = ?',
          whereArgs: [record.id],
        );
        await _updateDailySummaryInTxn(txn, record.dateKey, goalMl);
      });
      return result;
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.updateRecord failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> deleteRecord(int id, String dateKey, int goalMl) async {
    try {
      final db = await _dbHelper.database;
      late int result;
      await db.transaction((txn) async {
        result = await txn.delete(
          DbSchema.tableDrinkRecord,
          where: 'id = ?',
          whereArgs: [id],
        );
        await _updateDailySummaryInTxn(txn, dateKey, goalMl);
      });
      return result;
    } catch (e, stackTrace) {
      debugPrint('DrinkDataService.deleteRecord failed: $e\n$stackTrace');
      rethrow;
    }
  }

  String _todayKey() => AppDateUtils.todayKey();
}

