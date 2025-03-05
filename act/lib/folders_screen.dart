import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = true;

  final Map<String, String> suitImages = {
    'Hearts': 'assets/images/Hearts.png',
    'Spades': 'assets/images/Spades.png',
    'Diamonds': 'assets/images/Diamonds.png',
    'Clubs': 'assets/images/Clubs.png',
  };

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() async {
    await _dbHelper.database; // Ensure DB is initialized
    final folders = await _dbHelper.getFolders();
    setState(() {
      _folders = folders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Organizer')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? Center(child: Text('No folders found.'))
              : ListView.builder(
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    String folderName = _folders[index]['name'];
                    return ListTile(
                      leading: Image.asset(
                        suitImages[folderName] ?? 'assets/images/Clubs.png',
                        width: 40,
                        height: 40,
                      ),
                      title: Text(folderName),
                      trailing: Icon(Icons.folder),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CardsScreen(folderId: _folders[index]['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
