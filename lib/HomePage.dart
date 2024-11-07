import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';  // Make sure you import the generated Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Use the correct Firebase options here
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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

  // Add a new shop category
  void _addCategory() async {
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
                final newCategory = newCategoryController.text;

                if (newCategory.isNotEmpty) {
                  // Create a new empty category in the database
                  await _database.child('shops/$newCategory').set({});

                  Navigator.of(context).pop();
                  _fetchData(); // Reload data after adding category
                }
              },
              child: Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

  // Add a new shop to a category
  void _addShop(String category) async {
    final shopTypeController = TextEditingController();
    final newShopNameController = TextEditingController();
    final newShopContactController = TextEditingController();
    final newShopLocationController = TextEditingController();
    final newShopItemsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Shop to $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newShopNameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: newShopContactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: newShopLocationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: newShopItemsController,
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
                final newShopName = newShopNameController.text;
                final newShopContact = newShopContactController.text;
                final newShopLocation = newShopLocationController.text;
                final newShopItems = newShopItemsController.text.split(',').map((item) => item.trim()).toList();

                if (newShopName.isNotEmpty &&
                    newShopContact.isNotEmpty &&
                    newShopLocation.isNotEmpty) {
                  // Add the new shop to Firebase under the selected category
                  await _database.child('shops/$category/$newShopName').set({
                    'contact': newShopContact,
                    'location': newShopLocation,
                    'popularItems': newShopItems,  // Array of popular items
                  });

                  Navigator.of(context).pop();
                  _fetchData(); // Reload data after adding
                }
              },
              child: Text('Add Shop'),
            ),
          ],
        );
      },
    );
  }

  // Edit an existing shop
  void _editShop(String category, String shopName) async {
    final shop = categories[category][shopName];
    final newShopNameController = TextEditingController(text: shopName);
    final newShopContactController = TextEditingController(text: shop['contact']);
    final newShopLocationController = TextEditingController(text: shop['location']);
    final newShopItemsController = TextEditingController(text: shop['popularItems'].join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $shopName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newShopNameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: newShopContactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: newShopLocationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: newShopItemsController,
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
                final newShopName = newShopNameController.text;
                final newShopContact = newShopContactController.text;
                final newShopLocation = newShopLocationController.text;
                final newShopItems = newShopItemsController.text.split(',').map((item) => item.trim()).toList();

                if (newShopName.isNotEmpty &&
                    newShopContact.isNotEmpty &&
                    newShopLocation.isNotEmpty) {
                  await _database.child('shops/$category/$shopName').remove();
                  await _database.child('shops/$category/$newShopName').set({
                    'contact': newShopContact,
                    'location': newShopLocation,
                    'popularItems': newShopItems,  // Array of popular items
                  });

                  Navigator.of(context).pop();
                  _fetchData(); // Reload data after editing
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Delete a shop
  void _deleteShop(String category, String shopName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete $shopName'),
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
                _fetchData(); // Reload data after deleting
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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCategory, // Button to add a new category
          ),
        ],
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
                      subtitle: Text('Location: ${shop['location']}'),
                      onTap: () => _editShop(category, shopName), // Edit shop
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteShop(category, shopName), // Delete shop
                      ),
                    );
                  }).toList(),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addShop(category), // Add shop
                  ),
                );
              }).toList(),
            ),
    );
  }
}
