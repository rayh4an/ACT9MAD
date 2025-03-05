import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "card_organizer.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const cardTable = 'cards';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnSuit = 'suit';
  static const columnImage = 'image';
  static const columnFolderId = 'folderId';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> resetDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(path); // Deletes old database to start fresh
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $folderTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cardTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImage TEXT NOT NULL,
        $columnFolderId INTEGER NOT NULL,
        FOREIGN KEY ($columnFolderId) REFERENCES $folderTable($columnId) ON DELETE CASCADE
      )
    ''');

    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

    for (var suit in suits) {
      await db.insert(folderTable, {'name': suit});
    }

    for (String suit in suits) {
      int folderId = suits.indexOf(suit) + 1;
      for (int num = 1; num <= 3; num++) { // Ensure only 3 cards are added
        await db.insert(cardTable, {
          'name': '$num of $suit',
          'suit': suit,
          'image': 'assets/images/$suit.png',
          'folderId': folderId,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query(folderTable);
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    final db = await database;
    return await db.query(cardTable, where: '$columnFolderId = ?', whereArgs: [folderId]);
  }

  Future<int> addCard(Map<String, dynamic> card) async {
    final db = await database;
    final cardCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $cardTable WHERE $columnFolderId = ?', [card['folderId']]));

    if (cardCount != null && cardCount >= 6) {
      throw Exception("Cannot add more than 6 cards in this folder!");
    }

    return await db.insert(cardTable, card);
  }

  Future<int> deleteCard(int id, int folderId) async {
    final db = await database;
    final cardCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $cardTable WHERE $columnFolderId = ?', [folderId]));

    if (cardCount != null && cardCount <= 3) {
      throw Exception("You must keep at least 3 cards in this folder!");
    }

    return await db.delete(cardTable, where: '$columnId = ?', whereArgs: [id]);
  }
}
