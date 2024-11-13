import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'shops_page.dart';

class ShopCategoriesPage extends StatefulWidget {
  @override
  _ShopCategoriesPageState createState() => _ShopCategoriesPageState();
}

class _ShopCategoriesPageState extends State<ShopCategoriesPage> {
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref().child('shopCategories');

  Map<String, dynamic> shopCategories = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchShopCategories();
  }

  void fetchShopCategories() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      setState(() {
        shopCategories = data != null ? Map<String, dynamic>.from(data) : {};
        isLoading = false;
      });
    });
  }

  void addCategory() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Shop Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                databaseRef.child(id).set({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'shops': {},
                }).then((_) => Navigator.pop(context));
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Shop Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                databaseRef.child(id).remove().then((_) => Navigator.pop(context));
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop Categories')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: shopCategories.entries.map((entry) {
                final id = entry.key;
                final category = entry.value as Map;
                return ListTile(
                  title: Text(category['name']),
                  subtitle: Text(category['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShopsPage(categoryId: id, category: category),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteCategory(id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCategory,
        child: Icon(Icons.add),
      ),
    );
  }
}
