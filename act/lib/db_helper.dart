import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            suit TEXT NOT NULL,
            image TEXT NOT NULL,
            folderId INTEGER NOT NULL,
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
          )
        ''');

        // Pre-populate folders
        await db.insert('folders', {'name': 'Hearts'});
        await db.insert('folders', {'name': 'Spades'});
        await db.insert('folders', {'name': 'Diamonds'});
        await db.insert('folders', {'name': 'Clubs'});

        // Pre-populate cards
        for (String suit in ['Hearts', 'Spades', 'Diamonds', 'Clubs']) {
          for (int num = 1; num <= 13; num++) {
            await db.insert('cards', {
              'name': '$num of $suit',
              'suit': suit,
              'image': 'assets/images/$suit/$num.png',
              'folderId': suit == 'Hearts'
                  ? 1
                  : suit == 'Spades'
                      ? 2
                      : suit == 'Diamonds'
                          ? 3
                          : 4,
            });
          }
        }
      },
    );
  }
}

