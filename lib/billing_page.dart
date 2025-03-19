import 'package:flutter/material.dart';
import 'order_success_page.dart';

class BillingPage extends StatefulWidget {
  final int totalAmount;

  // Constructor with key
  BillingPage({Key? key, required this.totalAmount}) : super(key: key);

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  String selectedPaymentMethod = 'Credit/Debit Card';

  void processMockPayment() {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Processing Payment...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: CircularProgressIndicator()), // Centered loader
              SizedBox(height: 10),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Billing & Payment')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ₹${widget.totalAmount}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            buildPaymentOption('Credit/Debit Card'),
            buildPaymentOption('UPI'),
            buildPaymentOption('Cash on Delivery'),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: processMockPayment,
                child: Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentOption(String method) {
    return ListTile(
      title: Text(method),
      leading: Radio(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value.toString();
          });
        },
      ),
    );
  }
}
