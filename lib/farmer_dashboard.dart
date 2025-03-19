import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';
import 'weather_provider.dart';
import 'crop_details.dart';
import 'fertilizer_page.dart';
import 'seeds_page.dart';
import 'pesticide_page.dart';
import 'drip_irrigation_page.dart';
import 'manage_farmland_page.dart';
import 'farmer_sales_page.dart';
import 'farming_jobs_page.dart';
import 'plant_disease_page.dart';
import 'soil_type_page.dart';
import 'govt_schemes_page.dart';
import 'profile_page.dart';
import 'farmer_login.dart';
import 'package:geocoding/geocoding.dart';


class FarmerDashboard extends StatefulWidget {
  final String farmerId;
  final String name;
  final String phone;

  const FarmerDashboard({
    super.key,
    required this.farmerId,
    required this.name,
    required this.phone,
  });

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  String currentLocation = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    _getCurrentLocation();// Automatically fetch location
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          currentLocation = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = "Location permission denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = "Location permission permanently denied. Please enable it in settings.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String district = place.subAdministrativeArea ?? "Unknown District";
        String state = place.administrativeArea ?? "Unknown State";

        setState(() {
          currentLocation = "$district, $state";
        });

        Provider.of<WeatherProvider>(context, listen: false).loadWeather(district);
      } else {
        setState(() {
          currentLocation = "Location not found.";
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = "Error retrieving location: $e";
      });
      print("Location Error: $e");
    }
  }

  // Method to trigger the location and weather reload when the user clicks the refresh button
  Future<void> _reloadLocationAndWeather() async {
    await _getCurrentLocation(); // Fetch the location again
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerLogin()),
      );
    }
  }

  String _getWeatherBackground(String weatherCondition) {
    if (weatherCondition.contains("Rain")) return 'assets/Rainy.jpg';
    if (weatherCondition.contains("Cloud")) return 'assets/cloudy.jpg';
    if (weatherCondition.contains("Clear")) return 'assets/sunny.jpg';
    return 'assets/farmer_dashboard_bg.jpg';
  }

  Widget _getWeatherIcon(String weatherCondition) {
    IconData icon;
    if (weatherCondition.contains("Rain")) {
      icon = WeatherIcons.rain;
    } else if (weatherCondition.contains("Cloud")) {
      icon = WeatherIcons.cloudy;
    } else if (weatherCondition.contains("Clear")) {
      icon = WeatherIcons.day_sunny;
    } else {
      icon = WeatherIcons.day_sunny_overcast;
    }
    return Icon(icon, size: 50, color: Colors.white);
  }

  Widget _buildWeatherBar() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 1)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _getWeatherIcon(weatherProvider.weatherCondition),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weatherProvider.weatherData.isNotEmpty
                          ? weatherProvider.weatherData
                          : "❗ Weather data unavailable.",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text("📍 $currentLocation", style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _reloadLocationAndWeather,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardButton(String title, Color color, IconData icon, Widget page) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
          splashColor: color.withOpacity(0.5), // Splash effect color
          highlightColor: color.withOpacity(0.3), // Highlight color on tap
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6), // Glowing effect color
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color on top of the glow
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // Function to generate a color based on the first letter of the name
  Color _getColorFromLetter(String letter) {
    int value = letter.codeUnitAt(0);
    return Color((value * 0xFFFFFF ~/ 255) | 0xFF000000);  // Generate a color based on the letter
  }

  // Updated Profile icon with dynamic background color
  Widget _getProfileIcon() {
    String firstLetter = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'F';

    // Generate a color based on the first letter of the farmer's name
    Color backgroundColor = _getColorFromLetter(firstLetter);

    return InkWell(
      onTap: () {
        // Handle the onTap event (navigate to the profile page)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              farmerId: widget.farmerId,
              name: widget.name,
              phone: widget.phone,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(30),
      splashColor: Colors.white.withOpacity(0.3), // Ripple effect color
      child: CircleAvatar(
        backgroundColor: backgroundColor,  // Set dynamic background color
        radius: 20,
        child: Text(
          firstLetter,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }



  Widget _buildWelcomeText() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
         child: Center(
            child: Text(
              'Welcome, ${widget.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22, // Slightly larger font for better visibility
                fontWeight: FontWeight.w600, // Use a medium weight for a professional look
                color: Colors.white,
                letterSpacing: 1.2, // Adds slight space between letters for a clean look
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.5), // Soft shadow for better contrast
                    offset: Offset(2.0, 2.0), // Slight shadow offset
                  ),
                ],
              ),
            ),
         ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 4,
        actions: [
          IconButton(
            icon: _getProfileIcon(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    farmerId: widget.farmerId,
                    name: widget.name,
                    phone: widget.phone,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                return Image.asset(
                  _getWeatherBackground(weatherProvider.weatherCondition),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                );
              },
            ),
          ),
          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildWeatherBar(),
                _buildWelcomeText(),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: GridView.count(
                    shrinkWrap: true, // Prevents unbounded height issues
                    physics: NeverScrollableScrollPhysics(), // Disables internal GridView scrolling
                    crossAxisCount: (screenWidth > 900) ? 4 : (screenWidth > 600) ? 3 : 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                        _buildDashboardButton("Crop Details", Colors.green, Icons.agriculture, CropDetailsPage()),
                        _buildDashboardButton("Fertilizers", Colors.orange, Icons.science, FertilizerPage()),
                        _buildDashboardButton("Seeds", Colors.blue, Icons.grass, SeedsPage()),
                        _buildDashboardButton("Pesticides", Colors.red, Icons.bug_report, PesticidePage()),
                        _buildDashboardButton("Drip Irrigation", Colors.purple, Icons.water_drop, DripIrrigationPage()),
                        _buildDashboardButton("Manage Farmland", Colors.brown, Icons.landscape, ManageFarmlandPage(farmerId: widget.farmerId)),
                        _buildDashboardButton("Farmer Sales", Colors.teal, Icons.store, FarmerSalesPage(farmerId: widget.farmerId)),
                        _buildDashboardButton("Farming Jobs", Colors.deepOrange, Icons.work, FarmingJobsPage()),
                        _buildDashboardButton("Plant Disease", Colors.cyan, Icons.local_florist, PlantDiseasePage()),
                        _buildDashboardButton("Soil Type", Colors.indigo, Icons.terrain, SoilTypePage()),
                        _buildDashboardButton("Government Schemes", Colors.green, Icons.account_balance, GovtSchemesPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
