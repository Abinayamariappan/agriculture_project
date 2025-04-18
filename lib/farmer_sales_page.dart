import 'package:flutter/material.dart';
import 'database_helper.dart';

class FarmerSalesPage extends StatefulWidget {
  final int? farmerId; // Accept farmerId

  const FarmerSalesPage({super.key, this.farmerId});

  @override
  _FarmerSalesPageState createState() => _FarmerSalesPageState();
}


class _FarmerSalesPageState extends State<FarmerSalesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _products = [];
  String searchQuery = "";
  String filterBy = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.farmerId == null) {
      // Handle the case where farmerId is null
      print("❌ farmerId is null");
      return;
    }

    try {
      final crops = await DatabaseHelper.instance.getAllCrops(widget.farmerId!);
      final fertilizers = await DatabaseHelper.instance.getAllFertilizers(widget.farmerId!);
      final seeds = await DatabaseHelper.instance.getAllSeeds(widget.farmerId!);

      final allProducts = [
        ...crops.map((c) => {
          'id': c['id'],
          'name': c['name'],
          'price': c['price'],
          'min_kg': c['min_kg'],
          'total_kg': c['total_kg'],
          'description': c['description'],
          'image': c['image'],
          'status': c['status'],
          'category': 'Crop',
        }),
        ...fertilizers.map((f) => {
          'id': f['id'],
          'name': f['name'],
          'price': f['price'],
          'min_kg': f['min_kg'],
          'total_kg': f['total_kg'],
          'description': f['description'],
          'image': f['image'],
          'status': f['status'],
          'category': 'Fertilizer',
        }),
        ...seeds.map((s) => {
          'id': s['id'],
          'name': s['name'],
          'price': s['price'],
          'min_kg': s['min_kg'],
          'total_kg': s['total_kg'],
          'description': s['description'],
          'image': s['image'],
          'status': s['status'],
          'category': 'Seed',
        }),
      ];

      setState(() {
        _products = allProducts.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  void _toggleAvailability(int productId, String category) async {
    final index = _products.indexWhere((p) => p['id'] == productId && p['category'] == category);
    if (index != -1) {
      final currentStatus = _products[index]['status'];
      final newStatus = currentStatus.toString().toLowerCase() == "available" ? "Sold Out" : "Available";
      await DatabaseHelper.instance.updateItemStatus(category, productId, newStatus);
      setState(() {
        _products[index]['status'] = newStatus;
      });
    }
  }



  void _deleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final index = _products.indexWhere((p) => p['id'] == productId);
              final category = _products[index]['category'];
              await DatabaseHelper.instance.deleteItem(category, productId);
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String category) {
    List<Map<String, dynamic>> filtered = _products.where((product) {
      bool matchCategory = category == "All" || product['category'] == category;
      bool matchSearch = searchQuery.isEmpty || product['name'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchStatus = filterBy == "All" || product['status'].toString().toLowerCase() == filterBy.toLowerCase();
      return matchCategory && matchSearch && matchStatus;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No products found", style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildProductCard(filtered[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          product['image'] != null && product['image'].isNotEmpty
              ? ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.memory(
              product['image'],
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
              : Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Icon(Icons.image, size: 80, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  product['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                // Price and Weight
                Text(
                  "₹${product['price']} | Min: ${product['min_kg']}kg | Total: ${product['total_kg']}kg",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  "Description: ${product['description']}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                // Status + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status
                    Row(
                      children: [
                        const Text(
                          "Status: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          product['status'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: product['status'] == "Sold Out" ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        Tooltip(
                          message: product['status'] == "Sold Out" ? "Mark as Available" : "Mark as Sold Out",
                          child: IconButton(
                            icon: Icon(
                              product['status'] == "Sold Out" ? Icons.remove_shopping_cart : Icons.shopping_cart,
                              color: product['status'] == "Sold Out" ? Colors.red : Colors.green,
                            ),
                            onPressed: () => _toggleAvailability(product['id'], product['category']),
                          ),
                        ),
                        Tooltip(
                          message: "Delete Product",
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product['id']),
                          ),
                        ),
                      ],
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

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search by name",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.green),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption("All"),
            _buildFilterOption("Available"),
            _buildFilterOption("Sold Out"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value) {
    return RadioListTile(
      value: value,
      groupValue: filterBy,
      title: Text(value),
      onChanged: (val) {
        setState(() => filterBy = val.toString());
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Product Sales"),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
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
}