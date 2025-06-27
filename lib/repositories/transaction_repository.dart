import 'package:sqflite/sqflite.dart' as sql;
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/transaction.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper();

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'transaction_date DESC');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<List<Transaction>> getTransactionsByDateRange(String startDate, String endDate) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<Map<String, double>> getSummary(String startDate, String endDate) async {
    final db = await dbHelper.database;

    // Total income
    final List<Map<String, dynamic>> incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'income' AND transaction_date BETWEEN ? AND ?
    ''', [startDate, endDate]);

    // Total expense
    final List<Map<String, dynamic>> expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'expense' AND transaction_date BETWEEN ? AND ?
    ''', [startDate, endDate]);

    double totalIncome = incomeResult.first['total'] ?? 0;
    double totalExpense = expenseResult.first['total'] ?? 0;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'profit': totalIncome - totalExpense,
    };
  }
}
