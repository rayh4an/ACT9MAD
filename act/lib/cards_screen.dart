import 'package:flutter/material.dart';
import 'db_helper.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    final db = await _dbHelper.database;
    final cards = await db.query('cards', where: 'folderId = ?', whereArgs: [widget.folderId]);
    setState(() {
      _cards = cards;
    });
  }

  void _addCard(String name, String suit, String image) async {
    final db = await _dbHelper.database;
    await db.insert('cards', {
      'name': name,
      'suit': suit,
      'image': image,
      'folderId': widget.folderId,
    });
    _loadCards();
  }

  void _deleteCard(int id) async {
    final db = await _dbHelper.database;
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _deleteCard(_cards[index]['id']),
            child: Card(
              child: Column(
                children: [
                  Image.asset(_cards[index]['image'], height: 80),
                  Text(_cards[index]['name']),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCard('Ace of Spades', 'Spades', 'assets/images/Spades/1.png');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
