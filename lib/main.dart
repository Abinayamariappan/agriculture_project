import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'weather_provider.dart';
import 'database_helper.dart'; // Import Database Helper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseHelper.instance.database;
    await _addAdminCredentials();

    print("🚀 All systems initialized successfully!");
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print("❌ Initialization Error: $e");
    print("🔍 Stack Trace: $stackTrace");
  }
}


// ✅ Insert Admin Credentials (Runs Once)
Future<void> _addAdminCredentials() async {
  const String adminEmail = "admin@gmail.com";
  const String adminPassword = "admin123";

  bool adminExists = await DatabaseHelper.instance.doesAdminExist(adminEmail);
  if (!adminExists) {
    await DatabaseHelper.instance.insertAdmin(adminEmail, adminPassword);
    print("✅ Admin account added: $adminEmail");
  } else {
    print("ℹ️ Admin already exists in the database.");
  }
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
