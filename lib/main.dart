import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'firebase_options.dart'; // Auto-generated Firebase config
import 'splash_screen.dart';
import 'weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Required for async operations

  // ✅ Initialize Firebase
 // await Firebase.initializeApp(
  //  options: DefaultFirebaseOptions.currentPlatform,
  //);

  //print("📌 Firebase Initialized Successfully!");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()), // Add Provider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgriConnect',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
