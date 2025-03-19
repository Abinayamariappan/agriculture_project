import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'database_helper.dart';

class FarmerSalesPage extends StatefulWidget {
  final String farmerId;

  const FarmerSalesPage({super.key, required this.farmerId});

  @override
  _FarmerSalesPageState createState() => _FarmerSalesPageState();
}

class _FarmerSalesPageState extends State<FarmerSalesPage> with SingleTickerProviderStateMixin {
  late int farmerId;
  String farmerName = "";
  String farmerPhone = "";
  List<Map<String, dynamic>> _products = [];
  String searchQuery = "";
  String filterBy = "All";
  bool isLoading = true;
  late TabController _tabController;
  Timer? _debounce;

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

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
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

  Future<void> _deleteProduct(int productId) async {
    await DatabaseHelper.instance.deleteProduct(productId);
    _loadProducts();
  }

  void _toggleAvailability(int index) async {
    setState(() {
      _products[index]['status'] = _products[index]['status'] == "Available" ? "Sold Out" : "Available";
    });
    await DatabaseHelper.instance.updateProductStatus(_products[index]['id'], _products[index]['status']);
  }

  List<Map<String, dynamic>> _filteredProducts(String category) {
    return _products.where((product) =>
    (category == "All" || product['category'] == category) &&
        (filterBy == "All" || product['status'] == filterBy) &&
        product['name'].toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = value);
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildFilterOption("All"),
              _buildFilterOption("Available"),
              _buildFilterOption("Sold Out"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option, style: const TextStyle(fontSize: 16)),
      trailing: filterBy == option
          ? const Icon(Icons.check_circle, color: Colors.green) // Show checkmark if selected
          : null,
      onTap: () {
        setState(() => filterBy = option);
        Navigator.pop(context);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Sales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
          _buildSearchAndFilterRow(),
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

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: "Search Products",
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                  borderSide: BorderSide.none, // Remove default border
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light background color
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Padding inside the field
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green, size: 30),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
    );
  }


  Widget _buildProductList(String category) {
    final filteredProducts = _filteredProducts(category);
    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 5,
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.green),
              title: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("₹${product['price']} - ${product['status']}", style: TextStyle(color: Colors.grey[700])),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(product['id'])),
                ],
              ),
              onTap: () => _toggleAvailability(index),
            ),
          ),
        );
      },
    );
  }
}