import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'database_helper.dart';
import 'models/product_model.dart';
import 'user_login_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'soil_type_page.dart';
import 'customer_jobs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_registration_page.dart';
import 'account_settings_page.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allFetchedProducts = [];
  final List<String> carouselImages = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.jpg',
  ];

  late Future<List<Product>> futureProducts;
  String selectedCategory = 'All';


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    futureProducts = _fetchProducts('All');
    _searchController.addListener(_onSearchChanged);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _changeCategory(String category) {
    print("Selected category: $category");  // Keep this for debug
    setState(() {
      selectedCategory = category;
      futureProducts = _fetchProducts(category); // <-- No toLowerCase
    });
  }

  Future<List<Product>> _fetchProducts(String category) async {
    print("Fetching products for category: $category");
    List<Map<String, dynamic>> rawProducts;

    if (category == 'All') {
      rawProducts = await DatabaseHelper.instance.getAllAvailableProducts();
    } else {
      rawProducts = await DatabaseHelper.instance.getAvailableProductsByCategory(category);
    }

    List<Product> fetched = rawProducts.map((map) => Product.fromMap(map)).toList();
    setState(() {
      _allFetchedProducts = fetched;
      _filteredProducts = fetched;
    });

    return fetched;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allFetchedProducts
          .where((product) =>
      product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query))
          .toList();
    });

  }


  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? currentUserId = prefs.getInt('currentUserId');

    if (currentUserId == null || currentUserId == 0) {
      _showLoginRegisterDialog();
    }
  }

  void _showLoginRegisterDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt('currentUserId') ?? 0;

    // If the user is logged in, don't show the login/register dialog
    if (currentUserId != 0) {
      return; // User is already logged in, exit the function
    }

    // Otherwise, show the login/register dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Welcome to A2C"),
        content: Text("Please login or register to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserLoginPage()),
              );
            },
            child: Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserRegistrationPage()),
              );
            },
            child: Text("Register"),
          ),
        ],
      ),
    );
  }

  void showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(product.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(product.image!, height: 200, fit: BoxFit.cover),
                ),
                SizedBox(height: 10),
                Text(product.description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("Price: ₹${product.price}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    int userId = prefs.getInt('currentUserId') ?? 0;

                    Map<String, dynamic> cartItem = {
                      'name': product.name,
                      'image': product.image,
                      'price': product.price,
                      'quantity': 1,
                      'userId': userId, // ✅ Associate with user
                    };
                    await DatabaseHelper().addToCart(cartItem);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.name} added to cart!")),
                    );
                  },

                  icon: Icon(Icons.shopping_cart),
                  label: Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Image.asset('assets/C.png', height: 40),
            SizedBox(width: 8),
            Text("A2C", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettingsPage()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Clear SharedPreferences to log out the user
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // This clears all saved data

              // Navigate back to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserLoginPage()),
              );
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: carouselImages.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(image, fit: BoxFit.cover, width: 1000),
                );
              }).toList(),
            ),
            // Buttons
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SoilTypePage()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Soil Type", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerJobsPage()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Jobs", style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Categories
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: Text('View All')),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryItem(
                    icon: Icons.eco,
                    label: "All",
                    isSelected: selectedCategory == 'All',
                    onTap: () => _changeCategory('All'),
                  ),
                  CategoryItem(
                    icon: Icons.agriculture,
                    label: "Crop", // ✅ singular
                    isSelected: selectedCategory == 'Crop',
                    onTap: () => _changeCategory('Crop'),
                  ),
                  CategoryItem(
                    icon: Icons.grass,
                    label: "Fertilizer", // ✅ singular
                    isSelected: selectedCategory == 'Fertilizer',
                    onTap: () => _changeCategory('Fertilizer'),
                  ),
                  CategoryItem(
                    icon: Icons.local_florist,
                    label: "Seed", // ✅ singular
                    isSelected: selectedCategory == 'Seed',
                    onTap: () => _changeCategory('Seed'),
                  ),
                ],
              ),
            ),

            // Products
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("All Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No available products"));
                }

                List<Product> products = _searchController.text.isEmpty ? snapshot.data! : _filteredProducts;
                return GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return GestureDetector(
                      onTap: () => showProductDetails(context, product),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.memory(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("₹${product.price}", style: TextStyle(color: Colors.green)),
                                  if (product.category.isNotEmpty)
                                    Text("Category: ${product.category}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                  if (product.description.isNotEmpty)
                                    Text("Desc: ${product.description}", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite_border, color: Colors.red),
                                        onPressed: () async {
                                          await DatabaseHelper().addToWishlist(
                                            product.name,
                                            product.image!,
                                            product.price.toString(),
                                          );

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("${product.name} added to wishlist!")),
                                          );
                                        },

                                      ),
                                      IconButton(
                                        icon: Icon(Icons.shopping_cart, color: Colors.green),
                                        onPressed: () async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          int userId = prefs.getInt('currentUserId') ?? 0;

                                          Map<String, dynamic> cartItem = {
                                            'name': product.name,
                                            'image': product.image,
                                            'price': product.price,
                                            'quantity': 1,
                                            'userId': userId, // ✅ Associate with user
                                          };
                                          await DatabaseHelper().addToCart(cartItem);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("${product.name} added to cart!")),
                                          );
                                        },

                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSelected ? Colors.orange : Colors.green,
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.orange : Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}
