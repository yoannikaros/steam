import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/saving.dart';

class SavingRepository {
  final dbHelper = DatabaseHelper();

  Future<int> insertSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.insert('savings', saving.toMap());
  }

  Future<int> updateSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.update(
      'savings',
      saving.toMap(),
      where: 'id = ?',
      whereArgs: [saving.id],
    );
  }

  Future<int> deleteSaving(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Saving>> getAllSavings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('savings', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<Saving?> getSavingById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Saving>> getSavingsByType(String type) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<double> getTotalSavings() async {
    final db = await dbHelper.database;
    
    // Total deposits
    final List<Map<String, dynamic>> depositResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM savings WHERE type = 'deposit'
    ''');
    
    // Total withdrawals
    final List<Map<String, dynamic>> withdrawalResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM savings WHERE type = 'withdrawal'
    ''');
    
    double totalDeposits = depositResult.first['total'] ?? 0;
    double totalWithdrawals = withdrawalResult.first['total'] ?? 0;
    
    return totalDeposits - totalWithdrawals;
  }
}
