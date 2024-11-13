import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ShopsPage extends StatefulWidget {
  final String categoryId;
  final Map category;

  ShopsPage({required this.categoryId, required this.category});

  @override
  _ShopsPageState createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  late DatabaseReference shopsRef;

  @override
  void initState() {
    super.initState();
    shopsRef = FirebaseDatabase.instance
        .ref()
        .child('shopCategories')
        .child(widget.categoryId)
        .child('shops');
  }

  void addShop() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final contactController = TextEditingController();
    final popularItemsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Shop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
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
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                shopsRef.child(id).set({
                  'name': nameController.text,
                  'location': locationController.text,
                  'contact': contactController.text,
                  'popularItems': popularItemsController.text.split(',').map((item) => item.trim()).toList(),
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

  void editShop(String id, Map shop) {
    final nameController = TextEditingController(text: shop['name']);
    final locationController = TextEditingController(text: shop['location']);
    final contactController = TextEditingController(text: shop['contact']);
    final popularItemsController = TextEditingController(text: (shop['popularItems'] as List).join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Shop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
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
                shopsRef.child(id).update({
                  'name': nameController.text,
                  'location': locationController.text,
                  'contact': contactController.text,
                  'popularItems': popularItemsController.text.split(',').map((item) => item.trim()).toList(),
                }).then((_) => Navigator.pop(context));
              },
              child: Text('Save'),
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

  void deleteShop(String id) {
    shopsRef.child(id).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category['name']} Shops')),
      body: StreamBuilder<DatabaseEvent>(
        stream: shopsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No shops available.'));
          }

          final data = snapshot.data!.snapshot.value;

          // Safely cast the data to Map<String, dynamic>
          final shops = (data as Map<dynamic, dynamic>).map((key, value) {
            return MapEntry(key.toString(), Map<String, dynamic>.from(value));
          });

          return ListView(
            children: shops.entries.map((entry) {
              final id = entry.key;
              final shop = entry.value;

              return ListTile(
                title: Text(shop['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${shop['location']}'),
                    Text('Contact: ${shop['contact']}'),
                    Text('Popular Items: ${(shop['popularItems'] as List).join(', ')}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => editShop(id, shop),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteShop(id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addShop,
        child: Icon(Icons.add),
      ),
    );
  }
}
