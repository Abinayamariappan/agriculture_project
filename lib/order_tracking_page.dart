import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  final List<Map<String, String>> orders = [
    {"orderId": "12345", "status": "Shipped"},
    {"orderId": "67890", "status": "Out for Delivery"},
    {"orderId": "11121", "status": "Delivered"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Tracking")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Order ID: ${order['orderId']}"),
              subtitle: Text("Status: ${order['status']}"),
              trailing: Icon(
                order['status'] == "Delivered" ? Icons.check_circle : Icons.local_shipping,
                color: order['status'] == "Delivered" ? Colors.green : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}
