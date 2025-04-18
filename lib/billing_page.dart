import 'package:flutter/material.dart';
import 'order_success_page.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  String selectedPaymentMethod = 'Credit/Debit Card';
  int totalAmount = 0; // Initialize the total amount variable

  @override
  void initState() {
    super.initState();
    _updateTotalAmount(); // Fetch total amount when the page is loaded
  }

  // Recalculate the total amount from the cart items
  Future<void> _updateTotalAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;  // Fetch current user ID

    // Pass currentUserId to getCartItems method
    List<Map<String, dynamic>> cartItems = await DatabaseHelper.instance.getCartItems(currentUserId);

    int calculatedTotal = cartItems.fold(0, (sum, item) {
      return sum + ((item['price'] as num) * (item['quantity'] as num)).toInt();
    });
    setState(() {
      totalAmount = calculatedTotal; // Update the total amount
    });
  }


  void processMockPayment() async {
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
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 10),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );

    // ✅ Get the current user ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    if (currentUserId == 0) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in. Please log in to proceed.')),
      );
      return;
    }

    // ✅ Fetch cart items for the logged-in user from SQLite
    List<Map<String, dynamic>> cartItems = await DatabaseHelper.instance.getCartItems(currentUserId);

    if (cartItems.isEmpty) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty! Add items before proceeding.')),
      );
      return;
    }

    // ✅ Insert order with correct parameters, including userId
    try {
      int orderId = await DatabaseHelper.instance.insertOrder(
        totalAmount.toDouble(),
        selectedPaymentMethod,
        cartItems,  // Pass cartItems correctly
        userId: currentUserId, // Pass the userId here
      );

      if (orderId > 0) {
        await DatabaseHelper.instance.clearCartForUser(currentUserId); // 🧹 clear cart
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Close the loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderSuccessPage(orderId: orderId)),
          );
        });
      } else {
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placement failed. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
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
              'Total Amount: ₹$totalAmount', // Display updated total amount
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
