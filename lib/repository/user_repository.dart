import 'package:smartdrinkai/models/data_models/reminder_schedule.dart';
import 'package:smartdrinkai/models/data_models/user_profile.dart';
import 'package:smartdrinkai/services/storage/database_helper.dart';
import 'package:smartdrinkai/services/storage/schema.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertOrUpdateProfile(UserProfile profile) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        DbSchema.tableUserProfile,
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'UserRepository.insertOrUpdateProfile failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<UserProfile?> getProfile() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(DbSchema.tableUserProfile, limit: 1);
      if (maps.isEmpty) return null;
      return UserProfile.fromMap(maps.first);
    } catch (e, stackTrace) {
      debugPrint('UserRepository.getProfile failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> insertReminderSchedule(ReminderSchedule schedule) async {
    try {
      final db = await _dbHelper.database;
      return db.insert(DbSchema.tableReminderSchedule, schedule.toMap());
    } catch (e, stackTrace) {
      debugPrint(
        'UserRepository.insertReminderSchedule failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<int> updateReminderSchedule(ReminderSchedule schedule) async {
    try {
      final db = await _dbHelper.database;
      return db.update(
        DbSchema.tableReminderSchedule,
        schedule.toMap(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
    } catch (e, stackTrace) {
      debugPrint(
        'UserRepository.updateReminderSchedule failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<int> deleteReminderSchedule(int id) async {
    try {
      final db = await _dbHelper.database;
      return db.delete(
        DbSchema.tableReminderSchedule,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      debugPrint(
        'UserRepository.deleteReminderSchedule failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<List<ReminderSchedule>> getReminderSchedules({String? mode}) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbSchema.tableReminderSchedule,
        where: mode != null ? 'mode = ?' : null,
        whereArgs: mode != null ? [mode] : null,
        orderBy: 'time ASC',
      );
      return maps.map((m) => ReminderSchedule.fromMap(m)).toList();
    } catch (e, stackTrace) {
      debugPrint('UserRepository.getReminderSchedules failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteAllReminderSchedules() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(DbSchema.tableReminderSchedule);
    } catch (e, stackTrace) {
      debugPrint(
        'UserRepository.deleteAllReminderSchedules failed: $e\n$stackTrace',
      );
      rethrow;
    }
  }
}

