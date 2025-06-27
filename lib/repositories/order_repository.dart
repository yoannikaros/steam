import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/order.dart';

class OrderRepository {
  final dbHelper = DatabaseHelper();

  Future<int> insertOrder(Order order) async {
    final db = await dbHelper.database;
    return await db.insert('orders', order.toMap());
  }

  Future<int> updateOrder(Order order) async {
    final db = await dbHelper.database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Order>> getAllOrders() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('orders', orderBy: 'date DESC, time DESC');
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<Order?> getOrderById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date ASC, time ASC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Order>> getOrdersByDate(String date) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getOrdersWithDetails() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT o.*, c.name as customer_name, c.phone as customer_phone, 
      c.plate_number, s.name as service_name, s.price as service_price
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      JOIN services s ON o.service_id = s.id
      ORDER BY o.date DESC, o.time DESC
    ''');
  }

  Future<Map<String, dynamic>?> getOrderWithDetails(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT o.*, c.name as customer_name, c.phone as customer_phone, 
      c.plate_number, s.name as service_name, s.price as service_price
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      JOIN services s ON o.service_id = s.id
      WHERE o.id = ?
    ''', [id]);
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final db = await dbHelper.database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateOrderPaymentStatus(int id, int isPaid) async {
    final db = await dbHelper.database;
    return await db.update(
      'orders',
      {'is_paid': isPaid},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
