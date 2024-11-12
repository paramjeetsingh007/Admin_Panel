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
      print("Data fetched: ${event.snapshot.value}"); // Debug log
      if (event.snapshot.exists) {
        var fetchedData = event.snapshot.value;

        // Check if data is not null and is of type List
        if (fetchedData is List) {
          setState(() {
            // Map each shop type object to a list of shop types with a default ID
            shopTypes = fetchedData.asMap().entries.map((entry) {
              var index = entry.key;
              var shopType = entry.value;

              return {
                'id': index, // Use the index as an ID
                'name': shopType['name'] ?? 'No Name',
                'description': shopType['description'] ?? 'No Description',
                'shops': shopType['shops'] ?? [], // Shops under this shop type
              };
            }).toList();
          });
          print("Shop types: $shopTypes"); // Debug log
        } else {
          setState(() {
            shopTypes = [];
          });
          print("Fetched data is not in expected format."); // Debug log
        }
      } else {
        setState(() {
          shopTypes = [];
        });
        print("No data available under 'shopTypes'."); // Debug log
      }
    }).catchError((error) {
      print('Failed to fetch data: $error');
      setState(() {
        shopTypes = [];
      });
    });
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
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: shopTypes.length,
                itemBuilder: (context, index) {
                  var shopType = shopTypes[index];
                  var shopTypeId = shopType['id'];
                  var shops = shopType['shops'] as List;

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(shopType['name'] ?? 'No Name'),
                      subtitle: Text(shopType['description'] ?? 'No Description'),
                      children: shops.isEmpty
                          ? [Text('No shops available')]
                          : shops.map<Widget>((shop) {
                              var products = shop['products'] ?? [];
                              var popularItems = shop['popularItems'] ?? [];

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ExpansionTile(
                                  title: Text(shop['name'] ?? 'No Shop Name'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Location: ${shop['location'] ?? 'No Location'}'),
                                      Text('Contact: ${shop['contact'] ?? 'N/A'}'),
                                      Text('Popular Items: ${popularItems.join(', ')}'),
                                    ],
                                  ),
                                  children: products.isEmpty
                                      ? [Text('No products available')]
                                      : products.map<Widget>((product) {
                                          return ListTile(
                                            leading: Image.network(
                                              product['imageURL'] ?? '',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                            title: Text(product['name'] ?? 'No Product Name'),
                                            subtitle: Text(
                                              '${product['description'] ?? ''}\nPrice: \$${product['price'] ?? 'N/A'}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          );
                                        }).toList(),
                                ),
                              );
                            }).toList(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}