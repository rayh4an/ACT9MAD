import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'card_organizer.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE folders (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
        );
        await db.execute(
          "CREATE TABLE cards (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, suit TEXT, imageUrl TEXT, folderId INTEGER, FOREIGN KEY(folderId) REFERENCES folders(id))",
        );
        await _insertDefaultFolders(db); // Insert default folders on app launch
      },
    );
  }

  /// Insert default folders when the app starts
  static Future<void> _insertDefaultFolders(Database db) async {
    List<Map<String, dynamic>> existingFolders = await db.query('folders');
    if (existingFolders.isEmpty) {
      await db.insert('folders', {'name': 'Hearts'});
      await db.insert('folders', {'name': 'Spades'});
      await db.insert('folders', {'name': 'Diamonds'});
      await db.insert('folders', {'name': 'Clubs'});
    }
  }

  /// Ensure folders exist when app starts
  static Future<void> insertTestData() async {
    final db = await database();
    await _insertDefaultFolders(db); // Reinitialize default folders
  }

  static Future<List<Map<String, dynamic>>> fetchFolders() async {
    final db = await database();
    return await db.rawQuery(
      "SELECT f.*, "
      "(SELECT COUNT(*) FROM cards WHERE folderId = f.id) as card_count, "
      "(SELECT imageUrl FROM cards WHERE folderId = f.id LIMIT 1) as preview_image "
      "FROM folders f",
    );
  }

  static Future<void> addFolder(String name) async {
    final db = await database();
    await db.insert('folders', {'name': name});
  }

  static Future<void> updateFolderName(int id, String newName) async {
    final db = await database();
    await db.update(
      'folders',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteFolder(int id) async {
    final db = await database();
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
    await db.delete('cards', where: 'folderId = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> fetchCards(int folderId) async {
    final db = await database();
    return await db.query(
      'cards',
      where: 'folderId = ?',
      whereArgs: [folderId],
    );
  }

  static Future<void> addCard(
    String name,
    String suit,
    String imageUrl,
    int folderId,
  ) async {
    final db = await database();
    await db.insert('cards', {
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'folderId': folderId,
    });
  }

  static Future<void> deleteCard(int id) async {
    final db = await database();
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
