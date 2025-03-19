import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  final List<Map<String, String>> wishlist;
  final Function(String) onRemove;

  WishlistPage({required this.wishlist, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wishlist")),
      body: wishlist.isEmpty
          ? Center(child: Text("Your wishlist is empty!"))
          : ListView.builder(
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          String productName = wishlist[index]['name']!;
          String productImage = wishlist[index]['image']!;
          String productPrice = wishlist[index]['price']!;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(productImage, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(productPrice, style: TextStyle(color: Colors.green)),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  onRemove(productName); // Call Remove Function
                  Navigator.pop(context); // Go back after removing
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
