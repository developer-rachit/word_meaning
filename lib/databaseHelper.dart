import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'words.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY,
          word TEXT,
          meaning TEXT
        )     
     ''');
  }

  Future<List<Words>> getWords() async {
    Database db = await instance.database;
    var words = await db.query('words', orderBy: 'word');

    List<Words> wordsList =
        words.isNotEmpty ? words.map((c) => Words.fromMap(c)).toList() : [];

    return wordsList;
  }

  Future<int> add(Words word) async {
    Database db = await instance.database;
    return await db.insert('words', word.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}
