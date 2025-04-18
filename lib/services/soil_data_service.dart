import 'dart:convert';
import 'dart:math' show sqrt, sin, cos, atan2, pi;
import 'package:flutter/services.dart' show rootBundle;

class SoilDataService {
  // Singleton pattern
  static final SoilDataService _instance = SoilDataService._internal();
  factory SoilDataService() => _instance;
  SoilDataService._internal();

  Map<String, dynamic>? _soilData;

  // Load JSON data from assets
  Future<void> loadSoilData() async {
    if (_soilData != null) return; // Already loaded

    try {
      final jsonString = await rootBundle.loadString('assets/data/tamil_nadu_soil_data.json');
      _soilData = json.decode(jsonString);
    } catch (e) {
      print("Error loading soil data: $e");
      throw Exception("Failed to load soil data");
    }
  }

  // Get the list of available districts
  List<String> getDistrictsList() {
    if (_soilData == null) return [];
    return (_soilData!['districts'] as Map<String, dynamic>).keys.toList();
  }

  // Get soil data for a specific district
  Map<String, dynamic>? getSoilDataForDistrict(String district) {
    if (_soilData == null) return null;
    return _soilData!['districts'][district] as Map<String, dynamic>?;
  }

  // Get district coordinates
  Map<String, double>? getDistrictCoordinates(String district) {
    if (_soilData == null) return null;
    final districtData = _soilData!['districts'][district];
    if (districtData == null) return null;

    final coordinates = districtData['coordinates'] as Map<String, dynamic>?;
    if (coordinates == null) return null;

    return {
      'lat': coordinates['lat'],
      'lon': coordinates['lon'],
    };
  }

  // Find nearest district based on coordinates
  String? findNearestDistrict(double lat, double lon) {
    if (_soilData == null) return null;

    String? nearestDistrict;
    double minDistance = double.infinity;

    final districts = _soilData!['districts'] as Map<String, dynamic>;
    districts.forEach((district, data) {
      final coords = data['coordinates'] as Map<String, dynamic>;
      final districtLat = coords['lat'] as double;
      final districtLon = coords['lon'] as double;

      final distance = _calculateDistance(lat, lon, districtLat, districtLon);

      if (distance < minDistance) {
        minDistance = distance;
        nearestDistrict = district;
      }
    });

    return nearestDistrict;
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}