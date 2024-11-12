import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewShopTypesPage extends StatefulWidget {
  @override
  _ViewShopTypesPageState createState() => _ViewShopTypesPageState();
}

class _ViewShopTypesPageState extends State<ViewShopTypesPage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> shopTypes = []; // List of shop types

  @override
  void initState() {
    super.initState();
    fetchShopTypes();
  }

  // Fetch data from Firebase
  void fetchShopTypes() {
    databaseRef.child('shopTypes').once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        var fetchedData = event.snapshot.value;

        // Ensure the data is of List type and print it
        if (fetchedData is List) {
          setState(() {
            shopTypes = fetchedData.map((shopType) {
              return {
                'name': shopType['name'] ?? 'No Name',
                'description': shopType['description'] ?? 'No Description',
                'shops': shopType['shops'] ?? [], // Shops under this shop type
              };
            }).toList();
          });
        } else {
          setState(() {
            shopTypes = [];
          });
        }
      } else {
        setState(() {
          shopTypes = [];
        });
      }
    }).catchError((error) {
      setState(() {
        shopTypes = [];
      });
    });
  }

  // Edit Shop Type
  void editShopType(int index) {
    final shopType = shopTypes[index];
    final nameController = TextEditingController(text: shopType['name']);
    final descriptionController = TextEditingController(text: shopType['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Shop Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Shop Type Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Shop Type Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String updatedName = nameController.text;
                String updatedDescription = descriptionController.text;

                // Update Firebase
                databaseRef.child('shopTypes').child(index.toString()).update({
                  'name': updatedName,
                  'description': updatedDescription,
                }).then((_) {
                  setState(() {
                    shopTypes[index]['name'] = updatedName;
                    shopTypes[index]['description'] = updatedDescription;
                  });
                  Navigator.pop(context);
                });
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Delete Shop Type
  void deleteShopType(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Shop Type"),
          content: Text("Are you sure you want to delete this shop type?"),
          actions: [
            TextButton(
              onPressed: () {
                // Remove shop type from Firebase
                databaseRef.child('shopTypes').child(index.toString()).remove().then((_) {
                  setState(() {
                    shopTypes.removeAt(index);
                  });
                  Navigator.pop(context);
                });
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  // Edit Shop
  void editShop(int shopTypeIndex, int shopIndex) {
    final shop = shopTypes[shopTypeIndex]['shops'][shopIndex];
    final nameController = TextEditingController(text: shop['name']);
    final locationController = TextEditingController(text: shop['location']);
    final contactController = TextEditingController(text: shop['contact']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Shop"),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String updatedName = nameController.text;
                String updatedLocation = locationController.text;
                String updatedContact = contactController.text;

                // Update Firebase
                databaseRef.child('shopTypes')
                    .child(shopTypeIndex.toString())
                    .child('shops')
                    .child(shopIndex.toString())
                    .update({
                  'name': updatedName,
                  'location': updatedLocation,
                  'contact': updatedContact,
                }).then((_) {
                  setState(() {
                    shopTypes[shopTypeIndex]['shops'][shopIndex]['name'] = updatedName;
                    shopTypes[shopTypeIndex]['shops'][shopIndex]['location'] = updatedLocation;
                    shopTypes[shopTypeIndex]['shops'][shopIndex]['contact'] = updatedContact;
                  });
                  Navigator.pop(context);
                });
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Delete Shop
  void deleteShop(int shopTypeIndex, int shopIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Shop"),
          content: Text("Are you sure you want to delete this shop?"),
          actions: [
            TextButton(
              onPressed: () {
                // Remove shop from Firebase
                databaseRef.child('shopTypes')
                    .child(shopTypeIndex.toString())
                    .child('shops')
                    .child(shopIndex.toString())
                    .remove().then((_) {
                  setState(() {
                    shopTypes[shopTypeIndex]['shops'].removeAt(shopIndex);
                  });
                  Navigator.pop(context);
                });
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
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
        title: Text('View Shop Types'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: shopTypes.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loader while data is being fetched
            : ListView.builder(
                itemCount: shopTypes.length,
                itemBuilder: (context, index) {
                  var shopType = shopTypes[index];
                  var shops = shopType['shops'] as List;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(shopType['name'] ?? 'No Name'),
                      subtitle: Text(shopType['description'] ?? 'No Description'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteShopType(index),
                      ),
                      children: [
                        ...shops.map<Widget>((shop) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(shop['name'] ?? 'No Shop Name'),
                              subtitle: Text(shop['location'] ?? 'No Location'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      editShop(index, shops.indexOf(shop));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteShop(index, shops.indexOf(shop));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
