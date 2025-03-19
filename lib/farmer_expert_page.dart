import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Ensure this package is installed

class FarmerExpertPage extends StatelessWidget {
  final List<Map<String, String>> experts = [
    {
      'name': 'Dr. Ravi Kumar',
      'specialization': 'Crop Management',
      'phone': '+919876543210',
      'email': 'ravi.kumar@agrihelp.com',
      'whatsapp': '9876543210',
    },
    {
      'name': 'Dr. Anitha Sharma',
      'specialization': 'Soil & Fertilizers',
      'phone': '+919988776655',
      'email': 'anitha.sharma@agrihelp.com',
      'whatsapp': '9988776655',
    },
    {
      'name': 'Dr. Mohan Das',
      'specialization': 'Plant Disease Specialist',
      'phone': '+918765432109',
      'email': 'mohan.das@agrihelp.com',
      'whatsapp': '8765432109',
    },
  ];

  FarmerExpertPage({super.key});

  // ✅ Launch Phone Call
  void _launchPhoneCall(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ✅ Launch WhatsApp Chat
  void _launchWhatsApp(String phone) async {
    final Uri uri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ✅ Launch Email
  void _launchEmail(String email) async {
    final Uri uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farmer Expert Support"), backgroundColor: Colors.green),
      body: ListView.builder(
        itemCount: experts.length,
        itemBuilder: (context, index) {
          final expert = experts[index];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("🌱 Specialization: ${expert['specialization']}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _launchPhoneCall(expert['phone']!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () => _launchEmail(expert['email']!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.teal),
                        onPressed: () => _launchWhatsApp(expert['whatsapp']!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
