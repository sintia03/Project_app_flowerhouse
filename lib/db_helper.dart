import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  initDb() async {
    String sql =
        'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)';
    String path = join(await getDatabasesPath(), 'user_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(sql);
      },
    );
  }

  //fungsi menyimpan data ke database (register atau mendaftar kan data ke database)
  Future<int> register(String username, String password) async {
    var dbClient = await db;
    return await dbClient.insert('users', {
      'username': username,
      'password': password,
    });
  }

  //fungsi membaca data atau select dari database untuk keperluan login dan chek kecocokan
  Future<bool> chekLogin(String username, String password) async {
    String sql =
        "SELECT * FROM users WHERE username= '$username' AND password = '$password'";
    var dbClient = await db;
    var result = await dbClient.rawQuery(sql);
    return result.isNotEmpty;
  }
}
