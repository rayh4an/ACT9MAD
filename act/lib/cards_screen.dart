import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _cards = [];
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
    _loadCards();
  }

  void _loadCards() async {
    await _dbHelper.database;
    final cards = await _dbHelper.getCards(widget.folderId);
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  void _addCard() async {
    try {
      if (_cards.length >= 6) {
        throw Exception("This folder can only hold 6 cards!");
      }

      int newCardNumber = _cards.length + 1;
      String suit = _cards.isNotEmpty ? _cards[0]['suit'] : "Unknown";

      Map<String, dynamic> newCard = {
        'name': '$newCardNumber of $suit',
        'suit': suit,
        'image': suitImages[suit] ?? '',
        'folderId': widget.folderId,
      };

      await _dbHelper.addCard(newCard);
      _loadCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _deleteCard(int id) async {
    try {
      await _dbHelper.deleteCard(id, widget.folderId);
      _loadCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cards'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addCard, // Restored Add Feature
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _cards.isEmpty
                ? Center(child: Text('No cards found.'))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns for bigger cards
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      String suit = _cards[index]['suit'];
                      String number = _cards[index]['name'].split(" ")[0];
                      String suitImage = suitImages[suit] ?? '';

                      return Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 220,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Text(
                              number,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20, // Moves the image slightly higher
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              suitImage,
                              width: 140, // Doubled size
                              height: 140, // Doubled size
                              fit: BoxFit.contain, // Proper scaling
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(_cards[index]['id']),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}

