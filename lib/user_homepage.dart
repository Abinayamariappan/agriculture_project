import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.shopping_cart),
                label: Text("Add to Cart"),
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
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Image.asset('assets/C.png', height: 40), // Circular Logo
            SizedBox(width: 8),
            Text("A2C", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // App Name
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.person), onPressed: () { /* Navigate to Profile */ }),
          IconButton(icon: Icon(Icons.favorite), onPressed: () { /* Navigate to Wishlist */ }),
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () { /* Navigate to Cart */ }),
          IconButton(icon: Icon(Icons.delivery_dining), onPressed: () { /* Navigate to Delivery Tracking */ }),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar with Filter Icon
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
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {
                              // Add filter functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Carousel Slider
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
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Replaces 'primary'
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.local_hospital),
                        label: Text("Crop Doctor"),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Replaces 'primary'
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.work),
                        label: Text("Jobs"),
                      ),
                    ),
                  ),
                ],
              ),
            ),


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
            // Categories List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryItem(icon: Icons.agriculture, label: "Crops"),
                  CategoryItem(icon: Icons.grass, label: "Fertilizers"),
                  CategoryItem(icon: Icons.local_florist, label: "Seeds"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("All Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // Product List
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(product['image']!, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}

// Category Widget
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.green, child: Icon(icon, color: Colors.white)),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
