import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlist = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Fetch userId from SharedPreferences
  _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('currentUserId');// Fetch the saved userId
    });
    if (userId != null) {
      loadWishlist(userId!); // Load wishlist after userId is available
    }
  }

  // Load wishlist items for the current user
  void loadWishlist(int userId) async {
    List<Map<String, dynamic>> items = await DatabaseHelper.instance.getWishlist(userId);
    setState(() {
      wishlist = items;
    });
  }

  // Remove item from the wishlist
  void removeFromWishlist(int userId, String name) async {
    await DatabaseHelper.instance.removeFromWishlist(userId, name);
    loadWishlist(userId); // Refresh wishlist after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: wishlist.isEmpty
          ? Center(child: Text("Your wishlist is empty!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)))
          : ListView.separated(
        itemCount: wishlist.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300, height: 1),
        itemBuilder: (context, index) {
          String productName = wishlist[index]['name'];
          Uint8List productImage = wishlist[index]['image']; // BLOB as Uint8List
          String productPrice = wishlist[index]['price'];

          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  productImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                productName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                productPrice,
                style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'remove') {
                    removeFromWishlist(userId!, productName);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Text('Remove from wishlist', style: TextStyle(color: Colors.red)),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
