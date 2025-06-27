import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/service.dart';

class ServiceRepository {
  final dbHelper = DatabaseHelper();

  Future<int> insertService(Service service) async {
    final db = await dbHelper.database;
    return await db.insert('services', service.toMap());
  }

  Future<int> updateService(Service service) async {
    final db = await dbHelper.database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Service>> getAllServices() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('services');
    return List.generate(maps.length, (i) {
      return Service.fromMap(maps[i]);
    });
  }

  Future<Service?> getServiceById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Service.fromMap(maps.first);
    }
    return null;
  }
}
