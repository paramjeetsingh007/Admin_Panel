import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddShopTypePage extends StatefulWidget {
  @override
  _AddShopTypePageState createState() => _AddShopTypePageState();
}

class _AddShopTypePageState extends State<AddShopTypePage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Controllers for dynamic input
  final TextEditingController shopTypeNameController = TextEditingController();
  final TextEditingController shopTypeDescriptionController = TextEditingController();
  final TextEditingController shopIdController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopLocationController = TextEditingController();
  final TextEditingController shopContactController = TextEditingController();
  final TextEditingController popularItemsController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productImageController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when the widget is destroyed
    shopTypeNameController.dispose();
    shopTypeDescriptionController.dispose();
    shopIdController.dispose();
    shopNameController.dispose();
    shopLocationController.dispose();
    shopContactController.dispose();
    popularItemsController.dispose();
    productIdController.dispose();
    productNameController.dispose();
    productPriceController.dispose();
    productImageController.dispose();
    super.dispose();
  }

  void addShopTypeData() {
    // Validate the input
    if (shopTypeNameController.text.isEmpty ||
        shopTypeDescriptionController.text.isEmpty ||
        shopIdController.text.isEmpty ||
        shopNameController.text.isEmpty ||
        productNameController.text.isEmpty ||
        productPriceController.text.isEmpty ||
        double.tryParse(productPriceController.text) == null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields correctly')));
      return;
    }

    // Create shop type data
    var shopType = {
      'name': shopTypeNameController.text,
      'description': shopTypeDescriptionController.text,
      'shops': {
        shopIdController.text: {
          'name': shopNameController.text,
          'location': shopLocationController.text,
          'contact': shopContactController.text,
          'popularItems': popularItemsController.text.split(","),
          'editDetails': true,
          'products': {
            productIdController.text: {
              'name': productNameController.text,
              'price': double.parse(productPriceController.text),
              'imageURL': productImageController.text,
            },
          },
        },
      },
    };

    // Convert shop type to JSON and save to Firebase
    databaseRef.child('shopTypes').push().set(shopType).then((_) {
      print('Shop type successfully added to Firebase!');
      Navigator.pop(context); // Go back to the Dashboard after adding the shop type
    }).catchError((error) {
      print('Failed to add data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shop Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: shopTypeNameController,
                decoration: InputDecoration(labelText: 'Shop Type Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: shopTypeDescriptionController,
                decoration: InputDecoration(labelText: 'Shop Type Description'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: shopIdController,
                decoration: InputDecoration(labelText: 'Shop ID'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: shopNameController,
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: shopLocationController,
                decoration: InputDecoration(labelText: 'Shop Location'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: shopContactController,
                decoration: InputDecoration(labelText: 'Shop Contact'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: popularItemsController,
                decoration: InputDecoration(labelText: 'Popular Items (comma separated)'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: productIdController,
                decoration: InputDecoration(labelText: 'Product ID'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: productImageController,
                decoration: InputDecoration(labelText: 'Product Image URL'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: addShopTypeData,
                child: Text('Add Shop Type'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
