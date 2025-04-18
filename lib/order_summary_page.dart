import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'billing_page.dart';
import 'order_history_page.dart';

class OrderSummaryPage extends StatefulWidget {
  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  bool isLoading = true;
  int currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndCartData();
  }

  Future<void> _loadUserAndCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('currentUserId') ?? 0;

    // Pass currentUserId to the getCartItems method to filter by user
    final items = await DatabaseHelper.instance.getCartItems(currentUserId);

    double total = 0.0;
    for (var item in items) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    setState(() {
      cartItems = items;
      totalAmount = total;
      isLoading = false;
    });
  }


  Future<void> _placeOrder() async {
    String paymentMethod = "Cash on Delivery";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    int orderId = await DatabaseHelper.instance.insertOrder(
      totalAmount,
      paymentMethod,
      cartItems,
      userId: currentUserId,
    );

    if (orderId > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order Placed Successfully! Order ID: $orderId'),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BillingPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order Failed. Please Try Again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Summary"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(child: Text("Your cart is empty."))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("Quantity: ${item['quantity']}"),
                  trailing: Text("₹${item['price'] * item['quantity']}"),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: ₹$totalAmount",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _placeOrder,
                  child: Text("Proceed to Billing"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
