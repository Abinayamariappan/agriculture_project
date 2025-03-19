import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '6d457610a6657d3392772c0e295b242c'; // 🔹 Replace with OpenWeather API key
  static const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse('$apiUrl?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return {
          "temperature": data['main']['temp'], // ✅ Now a double, not a string
          "description": (data['weather'][0]['description']?.toString() ?? "Unknown").capitalize(),
          "condition": data['weather'][0]['main'], // ✅ E.g., "Rain", "Clear", "Clouds"
        };
      } else {
        return {"error": "⚠️ Unable to fetch weather data"};
      }
    } catch (e) {
      return {"error": "⚠️ Network error. Check your connection."};
    }
  }
}

// ✅ Safe Capitalization Extension (Handles Empty Strings)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
