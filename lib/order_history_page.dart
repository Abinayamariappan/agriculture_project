import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];
  Map<int, List<Map<String, dynamic>>> orderItems = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('currentUserId') ?? 0;

    final fetchedOrders = await DatabaseHelper.instance.getOrderHistory(userId); // 👈 Pass userId

    Map<int, List<Map<String, dynamic>>> fetchedItems = {};
    for (var order in fetchedOrders) {
      int orderId = order['id'];
      List<Map<String, dynamic>> items = await DatabaseHelper.instance.getOrderItems(orderId);
      fetchedItems[orderId] = items;
    }

    setState(() {
      orders = fetchedOrders;
      orderItems = fetchedItems;
      isLoading = false;
    });
  }

  // Method to update the order status to 'Completed'
  Future<void> markOrderAsCompleted(int orderId) async {
    await DatabaseHelper.instance.updateOrderStatus(orderId, 'Completed');
    _loadOrderHistory(); // Refresh the order list to show updated status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order marked as completed")),
    );
  }

  String _formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order History")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final items = orderItems[order['id']] ?? [];

          return Card(
            margin: EdgeInsets.all(10),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              title: Text("Order #${order['id']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total: ₹${order['total_amount']}"),
                  Text("Status: ${order['order_status']}"),
                  Text("Date: ${_formatDate(order['created_at'])}"),
                ],
              ),
              children: [
                ...items.map((item) => ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text("Quantity: ${item['quantity']}"),
                  trailing: Text("₹${item['price']}"),
                )),
                // Button to mark as completed if the order is still pending
                if (order['order_status'] == 'Pending')
                  ListTile(
                    title: ElevatedButton(
                      onPressed: () => markOrderAsCompleted(order['id']),
                      child: Text("Mark as Completed"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
