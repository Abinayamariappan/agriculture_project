import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  String _weatherData = "Fetching Weather...";
  String _weatherCondition = "Clear"; // ✅ Default value

  final WeatherService _weatherService = WeatherService();

  String get weatherData => _weatherData;
  String get weatherCondition => _weatherCondition;

  Future<void> loadWeather(String city) async {
    final Map<String, dynamic> weatherResponse = await _weatherService.fetchWeather(city);

    if (weatherResponse.containsKey("error")) { // ✅ Handle API failure
      _weatherData = weatherResponse["error"];
      _weatherCondition = "Unknown";
    } else {
      _weatherData = "${weatherResponse["temperature"]}°C, ${weatherResponse["description"]}";
      _weatherCondition = weatherResponse["condition"] ?? "Clear"; // ✅ Prevents empty values
    }

    notifyListeners(); // ✅ This updates the UI
  }
}
