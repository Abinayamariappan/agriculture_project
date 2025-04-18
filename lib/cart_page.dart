import 'package:flutter/material.dart';
import 'billing_page.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  int totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    if (currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to view your cart")),
      );
      setState(() {
        cartItems = [];
        totalAmount = 0;
      });
      return;
    }

    final items = await DatabaseHelper().getCartItemsForUser(currentUserId);

    setState(() {
      // Ensure the list is mutable
      cartItems = List<Map<String, dynamic>>.from(items);
      totalAmount = _calculateTotal();
    });
  }

  Future<void> updateQuantity(int index, int change) async {
    int currentQuantity = cartItems[index]['quantity'];
    int newQuantity = currentQuantity + change;
    int maxQuantity = cartItems[index]['totalKg'] ?? 999999; // Fallback large value if totalKg missing

    if (newQuantity <= 0) {
      await removeItem(index);
      return;
    }

    if (newQuantity > maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maximum available quantity is ${maxQuantity} kg")),
      );
      return;
    }

    setState(() {
      cartItems[index] = Map<String, dynamic>.from(cartItems[index]);
      cartItems[index]['quantity'] = newQuantity;
      totalAmount = _calculateTotal(); // Recalculate after update
    });

    int result = await DatabaseHelper().updateCartItemQuantity(
      cartItems[index]['id'],
      newQuantity,
    );

    if (result <= 0) {
      setState(() {
        cartItems[index]['quantity'] = currentQuantity; // Rollback on failure
        totalAmount = _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  Future<void> removeItem(int index) async {
    final removedItem = cartItems[index];

    setState(() {
      cartItems.removeAt(index);
      totalAmount = _calculateTotal();
    });

    final result = await DatabaseHelper().removeFromCart(removedItem['id']);

    if (result <= 0) {
      setState(() {
        cartItems.insert(index, removedItem);
        totalAmount = _calculateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item")),
      );
    }
  }

  int _calculateTotal() {
    return cartItems.fold(0, (sum, item) =>
    sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Text(
          'Your cart is empty.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var item = cartItems[index];
                return Card(
                  margin:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹${item['price']} x ${item['quantity']} = ₹${(item['price'] as num) * (item['quantity'] as num)}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _quantityButton(Icons.remove,
                                    () => updateQuantity(index, -1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Text('${item['quantity']}',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            _quantityButton(Icons.add,
                                    () => updateQuantity(index, 1)),
                            IconButton(
                              icon:
                              Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹$totalAmount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BillingPage()),
                      ).then((_) => _loadCartItems());
                    },
                    child: Text(
                      'Proceed to Billing',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
