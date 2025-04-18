import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'order_summary_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'account_settings_page.dart';
import 'billing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "";
  String userPhone = "";
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadCartItems();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userPhone = prefs.getString('userPhone') ?? '';
    });
  }

  Future<void> loadCartItems() async {
    final db = await openDatabase('app_database.db');
    List<Map<String, dynamic>> items = await db.query('cart');
    setState(() {
      cartItems = items;
    });
  }

  double calculateTotal() {
    return cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/C.png',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Text('User Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          _buildProfileSection(),
          SizedBox(height: 10),
          _buildDashboardTile(context, 'Order Summary', Icons.receipt_long, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderSummaryPage(),
              ),
            );
          }),
          _buildDashboardTile(context, 'Wishlist', Icons.favorite, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WishlistPage(),
              ),
            );
          }),
          _buildDashboardTile(context, 'Cart', Icons.shopping_cart, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
          }),
          _buildDashboardTile(context, 'Account Settings', Icons.account_circle, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage()));
          }),
          _buildDashboardTile(context, 'Proceed to Billing', Icons.payment, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BillingPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Text(userName.isNotEmpty ? userName[0] : '?', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.isNotEmpty ? userName : 'Loading...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Phone: ${userPhone.isNotEmpty ? userPhone : 'Loading...'}", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.green),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
