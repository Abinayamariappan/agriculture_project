import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Import Provider package
import 'package:path_provider/path_provider.dart'; // Ensure SQLite storage works
import 'package:sqflite/sqflite.dart';  // Import SQLite
import 'splash_screen.dart';
import 'database_helper.dart';  // Import your DB helper file
import 'weather_provider.dart';  // Import your WeatherProvider file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Required for async operations

  // ✅ Debugging: Check database path
  final dbPath = await getDatabasesPath();
  print("📌 Database Path: $dbPath");

  // ✅ Debugging: Ensure database initializes properly
  final db = await DatabaseHelper.instance.database;
  print("📌 Database Initialized Successfully: $db");

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
