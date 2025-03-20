import 'package:flutter/material.dart';
import 'order_summary_page.dart';
import 'order_tracking_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'account_settings_page.dart';
import 'billing_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "Abinaya";
  String userPhone = "8838778182";

  List<Map<String, dynamic>> cartItems = [
    {'name': 'Wheat', 'price': 50, 'quantity': 2},
    {'name': 'Fertilizer', 'price': 150, 'quantity': 1},
    {'name': 'Seeds', 'price': 40, 'quantity': 3},
  ];

  double calculateTotal() {
    return cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the left
          children: [
            ClipOval(
              child: Image.asset(
                'assets/C.png', // Replace with your actual logo
                height: 40,  // Adjust size as needed
                width: 40,
                fit: BoxFit.cover, // Ensures circular cropping
              ),
            ),
            SizedBox(width: 10),
            Text(
              'UserDashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                builder: (context) => OrderSummaryPage(cartItems: cartItems, totalAmount: calculateTotal()),
              ),
            );
          }),
          _buildDashboardTile(context, 'Orders', Icons.shopping_bag, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrderTrackingPage()));
          }),
          _buildDashboardTile(context, 'Wishlist', Icons.favorite, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WishlistPage(
                  wishlist: [],
                  onRemove: (String productName) {
                    print("$productName removed from wishlist");
                  },
                ),
              ),
            );
          }),
          _buildDashboardTile(context, 'Cart', Icons.shopping_cart, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(cartItems: cartItems, onRemove: (item) {})));
          }),
          _buildDashboardTile(context, 'Account Settings', Icons.account_circle, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingsPage()));
          }),
          _buildDashboardTile(context, 'Proceed to Billing', Icons.payment, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BillingPage(totalAmount: calculateTotal().toInt())),
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
              child: Text(userName[0], style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Phone: $userPhone", style: TextStyle(fontSize: 14, color: Colors.grey)),
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
