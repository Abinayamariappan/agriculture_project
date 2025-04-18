import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;
  final String productImage;
  final String productPrice;
  final String productDescription;
  final String? productCategory; // Optional
  final String? productLocation; // Optional

  ProductDetailPage({
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
    this.productCategory,
    this.productLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(productImage, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Price: ₹$productPrice", style: TextStyle(fontSize: 18, color: Colors.green)),
                  if (productCategory != null && productCategory!.isNotEmpty)
                    Text("Category: $productCategory", style: TextStyle(fontSize: 16)),
                  if (productLocation != null && productLocation!.isNotEmpty)
                    Text("Location: $productLocation", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  Text(productDescription, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Home"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
