import 'package:flutter/material.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  OrderSummaryPage({required this.cartItems, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: Column(
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
                Text("Total: ₹$totalAmount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the payment/billing page
                    Navigator.pushNamed(context, '/billing', arguments: totalAmount);
                  },
                  child: Text("Proceed to Payment"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
