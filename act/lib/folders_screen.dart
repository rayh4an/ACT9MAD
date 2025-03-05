import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() async {
    final db = await _dbHelper.database;
    final folders = await db.query('folders');
    setState(() {
      _folders = folders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Organizer')),
      body: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_folders[index]['name']),
            trailing: Icon(Icons.folder),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardsScreen(folderId: _folders[index]['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

