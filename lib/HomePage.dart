import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_panel/DashboardPage.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> shopTypes = {}; // Store fetched shop types

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
  void initState() {
    super.initState();
    fetchShopTypes(); // Fetch data on init
  }

  void fetchShopTypes() {
    databaseRef.child('shopTypes').once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        setState(() {
          shopTypes = Map.from(event.snapshot.value as Map);
        });
      } else {
        setState(() {
          shopTypes = {};
        });
      }
    }).catchError((error) {
      print('Failed to fetch data: $error');
    });
  }

  void addShopTypeData() {
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

    databaseRef.child('shopTypes').push().set(shopType).then((_) {
      fetchShopTypes(); // Refresh data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }).catchError((error) {
      print('Failed to add data: $error');
    });
  }

  void deleteShopType(String shopTypeId) {
    databaseRef.child('shopTypes/$shopTypeId').remove().then((_) {
      fetchShopTypes(); // Refresh data after deletion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shop Type Deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete shop type')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shop Type Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // All the TextFields for input here...
              ElevatedButton(
                onPressed: addShopTypeData,
                child: Text('Add Data to Firebase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
