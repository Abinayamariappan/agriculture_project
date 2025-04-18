import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../services/soil_data_service.dart';

class SoilTypePage extends StatefulWidget {
  @override
  _SoilTypePageState createState() => _SoilTypePageState();
}

class _SoilTypePageState extends State<SoilTypePage> {
  final SoilDataService _soilService = SoilDataService();

  String? _soilType;
  String? _suggestedCrops;
  double? _pH;
  double? _organicMatter;
  double? _nitrogen;
  double? _phosphorus;
  double? _potassium;
  bool _loading = false;
  String? _errorMessage;
  bool _isDataLoaded = false;

  String? _selectedDistrict;
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _soilService.loadSoilData();
      _districts = _soilService.getDistrictsList();
      setState(() {
        _isDataLoaded = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load soil data: ${e.toString()}";
        _loading = false;
      });
    }
  }

  Future<void> _fetchSoilData({double? lat, double? lon}) async {
    if (!_isDataLoaded) {
      await _loadData();
      if (!_isDataLoaded) return; // If still not loaded, exit
    }

    setState(() {
      _loading = true;
      _soilType = null;
      _suggestedCrops = null;
      _errorMessage = null;
    });

    try {
      String? targetDistrict;

      if (_selectedDistrict != null) {
        targetDistrict = _selectedDistrict;
      } else if (lat != null && lon != null) {
        // Find nearest district based on coordinates
        targetDistrict = _soilService.findNearestDistrict(lat, lon);
      } else {
        // Get user's location if no coordinates provided
        final location = Location();

        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            setState(() {
              _errorMessage = "Location service is disabled";
              _loading = false;
            });
            return;
          }
        }

        PermissionStatus permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          if (permissionGranted != PermissionStatus.granted) {
            setState(() {
              _errorMessage = "Location permission denied";
              _loading = false;
            });
            return;
          }
        }

        final userLocation = await location.getLocation();
        targetDistrict = _soilService.findNearestDistrict(
            userLocation.latitude!, userLocation.longitude!
        );
      }

      if (targetDistrict == null) {
        setState(() {
          _errorMessage = "Could not determine district location";
          _loading = false;
        });
        return;
      }

      // Get soil data for the district
      final soilData = _soilService.getSoilDataForDistrict(targetDistrict);
      if (soilData == null) {
        setState(() {
          _errorMessage = "No soil data available for $targetDistrict";
          _loading = false;
        });
        return;
      }

      setState(() {
        _selectedDistrict = targetDistrict;
        _soilType = soilData['soilType'];
        _pH = soilData['pH'];
        _organicMatter = soilData['organicMatter'];
        _nitrogen = soilData['nitrogen'].toDouble();
        _phosphorus = soilData['phosphorus'].toDouble();
        _potassium = soilData['potassium'].toDouble();
        _suggestedCrops = soilData['suggestedCrops'];
      });

      _showResultDialog();
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Soil Analysis: $_selectedDistrict"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Soil Type: $_soilType"),
            Text("pH: ${_pH?.toStringAsFixed(1)}"),
            Text("Organic Matter: ${_organicMatter?.toStringAsFixed(1)}%"),
            Text("Nitrogen: ${_nitrogen?.toInt()} kg/ha"),
            Text("Phosphorus: ${_phosphorus?.toInt()} kg/ha"),
            Text("Potassium: ${_potassium?.toInt()} kg/ha"),
            const SizedBox(height: 10),
            const Text("Suggested Crops:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_suggestedCrops ?? ""),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  TextStyle _titleStyle() =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo);
  TextStyle _detailStyle() => const TextStyle(fontSize: 16, color: Colors.black87);
  TextStyle _errorStyle() => const TextStyle(fontSize: 16, color: Colors.red);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Type Detection'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      isExpanded: true,
                      hint: const Text("Select District"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: _isDataLoaded ? (value) {
                        setState(() => _selectedDistrict = value);
                      } : null,
                      items: _districts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isDataLoaded ? () {
                              if (_selectedDistrict != null) {
                                _fetchSoilData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please select a district")),
                                );
                              }
                            } : null,
                            icon: const Icon(Icons.location_city),
                            label: const Text("Get Soil Information"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isDataLoaded ? () => _fetchSoilData() : null,
                            icon: const Icon(Icons.my_location),
                            label: const Text("Use My Current Location"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 10),
                    Text("Finding soil information..."),
                  ],
                ),
              )
            else if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: _errorStyle()),
                    ],
                  ),
                ),
              )
            else if (_soilType != null)
                Card(
                  elevation: 4,
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Soil Type: $_soilType",
                                style: _titleStyle(),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text("pH: ${_pH?.toStringAsFixed(1)}", style: _detailStyle()),
                        Text("Organic Matter: ${_organicMatter?.toStringAsFixed(1)}%", style: _detailStyle()),
                        Text("Nitrogen: ${_nitrogen?.toInt()} kg/ha", style: _detailStyle()),
                        Text("Phosphorus: ${_phosphorus?.toInt()} kg/ha", style: _detailStyle()),
                        Text("Potassium: ${_potassium?.toInt()} kg/ha", style: _detailStyle()),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.grass, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              "Suggested Crops:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(_suggestedCrops ?? "", style: _detailStyle()),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}