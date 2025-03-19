import 'package:flutter/material.dart';

class GovtSchemesPage extends StatelessWidget {
  final List<Map<String, String>> schemes = [
    {
      'title': 'PM-KISAN Scheme',
      'benefits': '₹6,000 per year for small & marginal farmers.',
      'eligibility': 'Farmers with up to 2 hectares of land.',
      'apply': 'https://pmkisan.gov.in'
    },
    {
      'title': 'Fasal Bima Yojana',
      'benefits': 'Crop insurance against natural disasters.',
      'eligibility': 'Farmers growing insured crops.',
      'apply': 'https://pmfby.gov.in'
    },
    {
      'title': 'Soil Health Card Scheme',
      'benefits': 'Free soil testing & crop recommendations.',
      'eligibility': 'All farmers are eligible.',
      'apply': 'https://soilhealth.dac.gov.in'
    },
    {
      'title': 'Kisan Credit Card (KCC)',
      'benefits': 'Loans at low interest for agricultural expenses.',
      'eligibility': 'All farmers engaged in crop cultivation.',
      'apply': 'https://www.nabard.org'
    },
    {
      'title': 'PM Kusum Yojana',
      'benefits': 'Subsidy for solar-powered irrigation pumps.',
      'eligibility': 'Farmers using electric/diesel pumps.',
      'apply': 'https://mnre.gov.in/solar/schemes'
    },
    {
      'title': 'National Agriculture Market (eNAM)',
      'benefits': 'Online platform for selling crops at better prices.',
      'eligibility': 'Registered farmers & traders.',
      'apply': 'https://www.enam.gov.in'
    },
    {
      'title': 'Rashtriya Krishi Vikas Yojana',
      'benefits': 'Funds for modern farming equipment & infrastructure.',
      'eligibility': 'Farmers & agricultural cooperatives.',
      'apply': 'https://rkvy.nic.in'
    },
    {
      'title': 'Paramparagat Krishi Vikas Yojana',
      'benefits': 'Support for organic farming and marketing.',
      'eligibility': 'Organic farmers & farmer groups.',
      'apply': 'https://pgsindia-ncof.gov.in'
    },
  ];

  GovtSchemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Schemes'), backgroundColor: Colors.purple),
      body: ListView.builder(
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("🌱 Benefits: ${scheme['benefits']}"),
                  Text("✔ Eligibility: ${scheme['eligibility']}"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    onPressed: () => _openSchemeWebsite(context, scheme['apply']!),
                    child: const Text("Apply Now", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSchemeWebsite(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Open this link in browser: $url")));
  }
}
