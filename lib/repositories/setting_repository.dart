import 'package:sqflite/sqflite.dart';
import 'package:steam/helpers/database_helper.dart';
import 'package:steam/models/setting.dart';

class SettingRepository {
  final dbHelper = DatabaseHelper();

  Future<int> updateSettings(Setting setting) async {
    final db = await dbHelper.database;
    return await db.update(
      'settings',
      setting.toMap(),
      where: 'id = ?',
      whereArgs: [setting.id ?? 1],
    );
  }

  Future<Setting> getSettings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('settings', limit: 1);
    if (maps.isNotEmpty) {
      return Setting.fromMap(maps.first);
    }
    return Setting(
      businessName: 'Cuci Motor Bersih',
      noteHeader: 'Terima kasih telah menggunakan jasa kami',
      noteFooter: 'Silahkan datang kembali',
    );
  }
}
