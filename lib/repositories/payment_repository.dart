import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/payment.dart';

class PaymentRepository {
  final dbHelper = DatabaseHelper();

  Future<int> insertPayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('payments', orderBy: 'payment_date DESC');
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<Payment?> getPaymentById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Payment>> getPaymentsByOrderId(int orderId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getPaymentsWithOrderDetails() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT p.*, o.date as order_date, o.time as order_time, 
      c.name as customer_name, s.name as service_name
      FROM payments p
      JOIN orders o ON p.order_id = o.id
      LEFT JOIN customers c ON o.customer_id = c.id
      JOIN services s ON o.service_id = s.id
      ORDER BY p.payment_date DESC
    ''');
  }
}
