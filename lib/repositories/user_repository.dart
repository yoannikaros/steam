import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/user.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<User>> getAllUsers() async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByUsername(String username) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final user = await getUserByUsername(username);
    return user == null;
  }

  Future<bool> verifyPassword(int userId, String password) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return maps.isNotEmpty;
  }

  Future<void> updateUsername(int userId, String newUsername) async {
    final Database db = await _databaseHelper.database;
    await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    final Database db = await _databaseHelper.database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> permanentDeleteUser(int userId) async {
    final Database db = await _databaseHelper.database;
    
    // Mulai transaksi untuk memastikan semua operasi berhasil atau gagal bersama
    await db.transaction((txn) async {
      // Hapus data terkait user dari tabel-tabel lain
      await txn.delete('orders', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('payments', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('savings', where: 'user_id = ?', whereArgs: [userId]);
      
      // Terakhir, hapus user
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });
  }

  Future<User> insertUser(User user) async {
    final Database db = await _databaseHelper.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<void> updateUser(User user) async {
    final Database db = await _databaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final Database db = await _databaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> authenticate(String username, String password) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return maps.isNotEmpty;
  }
}
