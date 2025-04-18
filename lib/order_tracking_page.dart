import 'package:flutter/material.dart';
import 'database_helper.dart';

class OrderTrackingPage extends StatefulWidget {
  @override
  _OrderTrackingPageState createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final dbOrders = await DatabaseHelper.instance.getOrders();
    setState(() {
      orders = dbOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Tracking")),
      body: orders.isEmpty
          ? Center(child: Text("No orders available")) // Show message when no orders
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Order ID: ${order['id']}"),
              subtitle: Text("Status: ${order['order_status']}"),
              trailing: Icon(
                order['order_status'] == "Delivered" ? Icons.check_circle : Icons.local_shipping,
                color: order['order_status'] == "Delivered" ? Colors.green : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}
