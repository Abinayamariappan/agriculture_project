import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'user_login_page.dart';
import 'wishlist_page.dart';
import 'order_tracking_page.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final List<String> carouselImages = [
    'assets/carousel1.jpg',
    'assets/carousel2.jpg',
    'assets/carousel3.jpg',
  ];

  final List<Map<String, String>> productList = [
    {'name': 'Organic Tomatoes', 'image': 'assets/tomato.jpg', 'price': '₹50/kg', 'description': 'Fresh organic tomatoes directly from the farm.'},
    {'name': 'Fresh Carrots', 'image': 'assets/carrot.jpg', 'price': '₹30/kg', 'description': 'Crisp and sweet carrots perfect for cooking and salads.'},
    {'name': 'Natural Honey', 'image': 'assets/honey.jpg', 'price': '₹150/jar', 'description': 'Pure natural honey without any preservatives.'},
  ];

  ValueNotifier<List<String>> wishlist = ValueNotifier([]);
  ValueNotifier<int> cartCount = ValueNotifier(0);

  void toggleWishlist(String productName) {
    List<String> updatedWishlist = List.from(wishlist.value);
    if (updatedWishlist.contains(productName)) {
      updatedWishlist.remove(productName);
    } else {
      updatedWishlist.add(productName);
    }
    wishlist.value = updatedWishlist;
  }

  void addToCart() {
    cartCount.value++;
  }

  void showProductDetails(BuildContext context, Map<String, String> product) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  product['name']!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(product['image']!, height: 200, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              Text(product['description']!, style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(product['price']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => addToCart(),
                    icon: Icon(Icons.shopping_cart),
                    label: Text("Add to Cart"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => toggleWishlist(product['name']!),
                    icon: Icon(Icons.favorite),
                    label: Text("Wishlist"),
                  ),
                ],
              )
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
        backgroundColor: Colors.green,
        title: Text("A2C", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginPage())),
          ),
          ValueListenableBuilder(
            valueListenable: wishlist,
            builder: (context, value, child) => IconButton(
              icon: Icon(Icons.favorite, color: value.isNotEmpty ? Colors.red : Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    wishlist: productList.where((product) => wishlist.value.contains(product['name'])).toList(),
                    onRemove: (productName) => toggleWishlist(productName),
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: cartCount,
            builder: (context, value, child) => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {},
                ),
                if (value > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text('$value', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  )
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.local_shipping),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderTrackingPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(height: 200, autoPlay: true, enlargeCenterPage: true),
            items: carouselImages.map((image) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(image, fit: BoxFit.cover, width: 1000),
              );
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                var product = productList[index];
                return GestureDetector(
                  onTap: () => showProductDetails(context, product),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.asset(product['image']!, fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(product['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(product['price']!, style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
