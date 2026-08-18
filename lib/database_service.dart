import 'dart:developer';
import 'package:data_management_practical9/mood_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();

  factory DatabaseService() => _databaseService;

  DatabaseService._internal();

  static Database? _database;

  static const String tableName = 'Moods';
  static const String columnId = 'id';
  static const String columnScale = 'scale';
  static const String columnDescription = 'description';
  static const String columnCreatedOn = 'createdOn';

  // Get an instance of database(only 1 instance is needed)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();     //create database
    return _database!;
  }

  // Initialize a database
  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();    //where data to install
    String path = join(getDirectory.path, 'moods.db');                //database called as moods.db
    log('Database path: $path');
    return await openDatabase(        //create database
      path,
      onCreate: _onCreate,            //helper functions
      version: 1,
    );
  }

  // Create an instance of database = Create a table
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnScale INTEGER,
        $columnDescription TEXT,
        $columnCreatedOn DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    log('TABLE CREATED');
  }

  Future<List<MoodModel>> getMood() async {       //functions that involve data always use future, ned to return data into model
    final db = await database;
    var data = await db.query(tableName);
    List<MoodModel> moods =
        List.generate(data.length, (index) => MoodModel.fromJson(data[index]));     //populating list, helper function (MoodModel.fromJson) in model class, put data into list
    log('Retrieved ${moods.length} moods');
    return moods;
  }

  Future<void> insertMood(MoodModel mood) async {   //involved data must use future async and await
    final db = await database;          //database will run in background
    var data = await db.insert(         //rawInsert use to insert data(no need write in full aldy compiler will understand)
      tableName,
      {
        columnScale: mood.scale,
        columnDescription: mood.description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('Inserted $data');
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await database;
    var data = await db.update(
      tableName,
      mood.toMap(),                     //mood model convert to json format, existing data is in mood
      where: '$columnId = ?',
      whereArgs: [mood.id],
    );
    log('Updated $data');
  }

  Future<void> deleteMood(int id) async {
    final db = await database;
    var data = await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    log('Deleted $data');
  }
}
