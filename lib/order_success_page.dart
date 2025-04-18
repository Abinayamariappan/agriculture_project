import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user_navigation_bar.dart';
import 'order_history_page.dart';  // Assuming you want to navigate here
import 'package:shared_preferences/shared_preferences.dart';

class OrderSuccessPage extends StatefulWidget {
  final int orderId;

  OrderSuccessPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderSuccessPageState createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  void initState() {
    super.initState();
    clearCart(); // Clear cart when page loads
  }

  Future<void> clearCart() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'agriculture.db'),
    );
    final db = await database;

    // Get current user ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    if (currentUserId != 0) {
      await db.delete('cart', where: 'user_id = ?', whereArgs: [currentUserId]);
    }

    // Update order status to 'Completed'
    await updateOrderStatus(widget.orderId);
  }

  Future<void> updateOrderStatus(int orderId) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'agriculture.db'),
    );
    final db = await database;

    await db.update(
      'orders',
      {'order_status': 'Completed'},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Successful'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Order ID: ${widget.orderId}',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.local_shipping),
              label: Text('Go to Order History'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()), // Navigate to OrderHistoryPage
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
