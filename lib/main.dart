import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.insertTestData(); // Ensure predefined folders exist
  runApp(CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FolderScreen(),
    );
  }
}

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final data = await DBHelper.fetchFolders();
    setState(() {
      folders = data;
    });
  }

  void _addFolder() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add Folder"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Folder Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await DBHelper.addFolder(controller.text);
                    _loadFolders();
                  }
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  void _renameFolder(int folderId, String currentName) async {
    TextEditingController controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Rename Folder"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "New Folder Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    await DBHelper.updateFolderName(folderId, controller.text);
                    _loadFolders();
                  }
                  Navigator.pop(context);
                },
                child: Text("Update"),
              ),
            ],
          ),
    );
  }

  void _deleteFolder(int folderId) async {
    await DBHelper.deleteFolder(folderId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Folder deleted")));
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Organizer'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFolder, // Moves the add button to the top right
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading:
                folders[index]['preview_image'] != null
                    ? Image.network(
                      folders[index]['preview_image'],
                      width: 50,
                      height: 50,
                    )
                    : Icon(Icons.folder, color: Colors.black),
            title: Text(
              folders[index]['name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text("Cards: ${folders[index]['card_count'] ?? 0}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => _renameFolder(
                        folders[index]['id'],
                        folders[index]['name'],
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFolder(folders[index]['id']),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CardsScreen(
                        folderId: folders[index]['id'],
                        folderName: folders[index]['name'],
                      ),
                ),
              ).then((_) => _loadFolders());
            },
          );
        },
      ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  CardsScreen({required this.folderId, required this.folderName});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> cards = [];

  final List<Map<String, String>> deck = [
    {
      'name': 'Ace',
      'suit': 'Hearts',
      'imageUrl': 'https://deckofcardsapi.com/static/img/AH.png',
    },
    {
      'name': 'King',
      'suit': 'Hearts',
      'imageUrl': 'https://deckofcardsapi.com/static/img/KH.png',
    },
    {
      'name': 'Queen',
      'suit': 'Hearts',
      'imageUrl': 'https://deckofcardsapi.com/static/img/QH.png',
    },
    {
      'name': 'Jack',
      'suit': 'Hearts',
      'imageUrl': 'https://deckofcardsapi.com/static/img/JH.png',
    },
    {
      'name': 'Ace',
      'suit': 'Spades',
      'imageUrl': 'https://deckofcardsapi.com/static/img/AS.png',
    },
    {
      'name': 'King',
      'suit': 'Spades',
      'imageUrl': 'https://deckofcardsapi.com/static/img/KS.png',
    },
    {
      'name': 'Queen',
      'suit': 'Spades',
      'imageUrl': 'https://deckofcardsapi.com/static/img/QS.png',
    },
    {
      'name': 'Ace',
      'suit': 'Diamonds',
      'imageUrl': 'https://deckofcardsapi.com/static/img/AD.png',
    },
    {
      'name': 'King',
      'suit': 'Diamonds',
      'imageUrl': 'https://deckofcardsapi.com/static/img/KD.png',
    },
    {
      'name': 'Ace',
      'suit': 'Clubs',
      'imageUrl': 'https://deckofcardsapi.com/static/img/AC.png',
    },
    {
      'name': 'King',
      'suit': 'Clubs',
      'imageUrl': 'https://deckofcardsapi.com/static/img/KC.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final data = await DBHelper.fetchCards(widget.folderId);
    setState(() {
      cards = data;
    });
  }

  void _addCardFromDeck(int index) async {
    final selectedCard = deck[index];
    try {
      await DBHelper.addCard(
        selectedCard['name']!,
        selectedCard['suit']!,
        selectedCard['imageUrl']!,
        widget.folderId,
      );
      _loadCards();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot add more than 6 cards")));
    }
  }

  void _deleteCard(int id) async {
    await DBHelper.deleteCard(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Card deleted")));
    _loadCards();
  }

  // Show the deck of cards in a dialog with styling improvements
  void _showDeckDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Select a Card",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            content: SingleChildScrollView(
              // Make the content scrollable
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.all(8),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: deck.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        try {
                          await DBHelper.addCard(
                            deck[index]['name']!,
                            deck[index]['suit']!,
                            deck[index]['imageUrl']!,
                            widget.folderId,
                          );
                          _loadCards();
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cannot add more than 6 cards"),
                            ),
                          );
                        }
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Image.network(
                              deck[index]['imageUrl']!,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "${deck[index]['name']} of ${deck[index]['suit']}",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folderName} Cards'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showDeckDialog, // Opens the deck selection dialog
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Image.network(
                        cards[index]['imageUrl'],
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        "${cards[index]['name']} of ${cards[index]['suit']}",
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCard(cards[index]['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
