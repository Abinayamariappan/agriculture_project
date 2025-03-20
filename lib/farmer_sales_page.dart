import 'package:flutter/material.dart';
import 'dart:io';
import 'database_helper.dart';

class FarmerSalesPage extends StatefulWidget {
  final String farmerId;

  const FarmerSalesPage({super.key, required this.farmerId});

  @override
  _FarmerSalesPageState createState() => _FarmerSalesPageState();
}

class _FarmerSalesPageState extends State<FarmerSalesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int farmerId = -1;
  String farmerName = "";
  String farmerPhone = "";
  List<Map<String, dynamic>> _products = [];
  String searchQuery = "";
  String filterBy = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    farmerId = int.tryParse(widget.farmerId) ?? -1;

    if (farmerId == -1) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Farmer ID")),
        );
        Navigator.pop(context);
      });
      return;
    }
    _loadFarmerDetails();
    _loadProducts();
  }

  Future<void> _loadFarmerDetails() async {
    final farmer = await DatabaseHelper.instance.getFarmerById(farmerId);
    if (farmer != null) {
      setState(() {
        farmerName = farmer['name'];
        farmerPhone = farmer['phone'];
      });
    }
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getProductsByFarmer(farmerId);
    setState(() {
      _products = products;
      isLoading = false;
    });
  }

  void _toggleAvailability(int index) async {
    setState(() {
      _products[index]['status'] = _products[index]['status'] == "Available" ? "Sold Out" : "Available";
    });
    await DatabaseHelper.instance.updateProductStatus(_products[index]['id'], _products[index]['status']);
  }

  Widget _buildProductList(String category) {
    List<Map<String, dynamic>> filteredProducts = _products.where((product) {
      bool matchesCategory = category == "All" || product['category'] == category;
      bool matchesSearch = searchQuery.isEmpty || product['name'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesFilter = filterBy == "All" || product['status'] == filterBy;
      return matchesCategory && matchesSearch && matchesFilter;
    }).toList();

    return filteredProducts.isEmpty
        ? const Center(child: Text("No products available", style: TextStyle(fontSize: 18)))
        : ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product['image'] != null && product['image'].isNotEmpty
              ? Image.file(File(product['image']), width: double.infinity, height: 150, fit: BoxFit.cover)
              : const Icon(Icons.image, size: 150, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${product['price']} | Min: ${product['min_kg']} kg | Total: ${product['total_kg']} kg"),
                Text("Description: ${product['description']}", maxLines: 2, overflow: TextOverflow.ellipsis),
                SwitchListTile(
                  title: const Text("Mark as Sold Out"),
                  value: product['status'] == "Sold Out",
                  onChanged: (value) => _toggleAvailability(_products.indexOf(product)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {}, // Implement edit functionality
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              DatabaseHelper.instance.deleteProduct(productId);
              _loadProducts();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          const SizedBox(width: 10), // Spacing

          // Filter Icon Button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }


  // Show Bottom Sheet for Filter
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("All"),
                leading: Radio(
                  value: "All",
                  groupValue: filterBy,
                  onChanged: (value) {
                    setState(() {
                      filterBy = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Available"),
                leading: Radio(
                  value: "Available",
                  groupValue: filterBy,
                  onChanged: (value) {
                    setState(() {
                      filterBy = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text("Sold Out"),
                leading: Radio(
                  value: "Sold Out",
                  groupValue: filterBy,
                  onChanged: (value) {
                    setState(() {
                      filterBy = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Sales Product"),  // Set the title
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Crop"),
            Tab(text: "Fertilizer"),
            Tab(text: "Seed"),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchAndFilterRow(),  // Add search bar and filter
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList("All"),
                _buildProductList("Crop"),
                _buildProductList("Fertilizer"),
                _buildProductList("Seed"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
