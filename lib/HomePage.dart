import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Dashboard',
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic> categories = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from Firebase Realtime Database
  Future<void> _fetchData() async {
    try {
      final snapshot = await _database.child('shops').get();
      if (snapshot.exists) {
        setState(() {
          categories = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        print('No data available.');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Add a new category to Firebase
  void _addCategory() {
    final newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: newCategoryController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newCategory = newCategoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  await _database.child('shops/$newCategory').set({});
                  Navigator.of(context).pop();
                  _fetchData();
                }
              },
              child: Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

  // Add a new shop to a category in Firebase
  void _addShop(String category) {
    final shopNameController = TextEditingController();
    final contactController = TextEditingController();
    final locationController = TextEditingController();
    final popularItemsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Shop to $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: popularItemsController,
                decoration: InputDecoration(labelText: 'Popular Items (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final shopName = shopNameController.text.trim();
                final contact = contactController.text.trim();
                final location = locationController.text.trim();
                final popularItems = popularItemsController.text
                    .split(',')
                    .map((item) => item.trim())
                    .toList();

                if (shopName.isNotEmpty) {
                  await _database.child('shops/$category/$shopName').set({
                    'contact': contact,
                    'location': location,
                    'popularItems': popularItems,
                  });
                  Navigator.of(context).pop();
                  _fetchData();
                }
              },
              child: Text('Add Shop'),
            ),
          ],
        );
      },
    );
  }

  // Edit an existing shop in a category
  void _editShop(String category, String shopName) {
    final shop = categories[category][shopName];
    final contactController = TextEditingController(text: shop['contact']);
    final locationController = TextEditingController(text: shop['location']);
    final popularItemsController = TextEditingController(
      text: (shop['popularItems'] as List).join(', '),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Shop $shopName in $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: popularItemsController,
                decoration: InputDecoration(labelText: 'Popular Items (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final contact = contactController.text.trim();
                final location = locationController.text.trim();
                final popularItems = popularItemsController.text
                    .split(',')
                    .map((item) => item.trim())
                    .toList();

                await _database.child('shops/$category/$shopName').update({
                  'contact': contact,
                  'location': location,
                  'popularItems': popularItems,
                });
                Navigator.of(context).pop();
                _fetchData();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Delete a shop from a category in Firebase
  void _deleteShop(String category, String shopName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Shop $shopName from $category'),
          content: Text('Are you sure you want to delete this shop?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _database.child('shops/$category/$shopName').remove();
                Navigator.of(context).pop();
                _fetchData();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Dashboard'),
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: categories.keys.map((category) {
                return ExpansionTile(
                  title: Text(category),
                  children: categories[category].keys.map<Widget>((shopName) {
                    final shop = categories[category][shopName];
                    return ListTile(
                      title: Text(shopName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact: ${shop['contact'] ?? 'Not available'}'),
                          Text('Location: ${shop['location'] ?? 'Not available'}'),
                          Text('Popular Items: ${shop['popularItems'] != null ? (shop['popularItems'] as List).join(', ') : 'Not available'}'),
                        ],
                      ),
                      onTap: () => _editShop(category, shopName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editShop(category, shopName),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteShop(category, shopName),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addShop(category),
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        
        onPressed: (){
             print("FAB Pressed");  // Add this to check if the FAB is triggered
              _addCategory();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}
