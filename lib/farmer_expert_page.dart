import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Ensure this package is installed

class FarmerExpertPage extends StatelessWidget {
  final List<Map<String, String>> experts = [
    {
      'name': 'Dr. Ravi Kumar',
      'specialization': 'Crop Management',
      'phone': '+919876543210',
      'email': 'ravi.kumar@agrihelp.com',
      'whatsapp': '+919876543210',
    },
    {
      'name': 'Dr. Anitha Sharma',
      'specialization': 'Soil & Fertilizers',
      'phone': '+919988776655',
      'email': 'anitha.sharma@agrihelp.com',
      'whatsapp': '+919988776655',
    },
    {
      'name': 'Dr. Mohan Das',
      'specialization': 'Plant Disease Specialist',
      'phone': '+918765432109',
      'email': 'mohan.das@agrihelp.com',
      'whatsapp': '+918765432109',
    },
    {
      'name': 'Dr. Suresh Menon',
      'specialization': 'Pest Control Expert',
      'phone': '+919812345678',
      'email': 'suresh.menon@agrihelp.com',
      'whatsapp': '+919812345678',
    },
    {
      'name': 'Dr. Kavitha Iyer',
      'specialization': 'Organic Farming',
      'phone': '+919876123456',
      'email': 'kavitha.iyer@agrihelp.com',
      'whatsapp': '+919876123456',
    },
    {
      'name': 'Dr. Arjun Reddy',
      'specialization': 'Irrigation Specialist',
      'phone': '+918901234567',
      'email': 'arjun.reddy@agrihelp.com',
      'whatsapp': '+918901234567',
    },
    {
      'name': 'Dr. Priya Natarajan',
      'specialization': 'Seed Technology',
      'phone': '+919845673210',
      'email': 'priya.natarajan@agrihelp.com',
      'whatsapp': '+919845673210',
    },
    {
      'name': 'Dr. Sanjay Verma',
      'specialization': 'Climate & Crop Forecasting',
      'phone': '+917894561230',
      'email': 'sanjay.verma@agrihelp.com',
      'whatsapp': '+917894561230',
    },
    {
      'name': 'Dr. Meera Joshi',
      'specialization': 'Horticulture Specialist',
      'phone': '+918912345678',
      'email': 'meera.joshi@agrihelp.com',
      'whatsapp': '+918912345678',
    },
    {
      'name': 'Dr. Rajesh Nair',
      'specialization': 'Agri-Economics',
      'phone': '+919934561278',
      'email': 'rajesh.nair@agrihelp.com',
      'whatsapp': '+919934561278',
    },
  ];

  FarmerExpertPage({super.key});

  // ✅ Launch Phone Call
  void _launchPhoneCall(BuildContext context, String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make a phone call.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching phone: $e')),
      );
    }
  }

  // ✅ Launch WhatsApp Chat (fixed to properly handle international format)
  void _launchWhatsApp(BuildContext context, String phone) async {
    // Remove any non-digit characters from the phone number
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Make sure we have a clean number to work with
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number for WhatsApp.')),
      );
      return;
    }

    final Uri uri = Uri.parse("https://wa.me/$cleanPhone");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open WhatsApp.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching WhatsApp: $e')),
      );
    }
  }

  // ✅ Launch Email (fixed Uri construction)
  void _launchEmail(BuildContext context, String email) async {
    final String emailUri = 'mailto:$email?subject=Agri%20Support&body=Hello,%20I%20need%20help%20with...';
    final Uri uri = Uri.parse(emailUri);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send an email.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching email: $e')),
      );
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
                        onPressed: () => _launchPhoneCall(context, expert['phone']!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () => _launchEmail(context, expert['email']!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.teal),
                        onPressed: () => _launchWhatsApp(context, expert['whatsapp']!),
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