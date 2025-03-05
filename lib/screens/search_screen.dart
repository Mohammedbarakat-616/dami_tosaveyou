import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/blood_request_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedBloodType = 'الكل';
  final List<String> _bloodTypes = [
    'الكل',
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, String>> _donors = [];
  final _formKey = GlobalKey<FormState>();

  void _searchDonors() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bloodRequestProvider = context.read<BloodRequestProvider>();
        final donors = await bloodRequestProvider.searchDonors(
          bloodType: _selectedBloodType == 'الكل' ? null : _selectedBloodType,
          location: _locationController.text,
        );
        setState(() {
          _donors = donors;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم البحث بنجاح')),
        );
      } catch (e) {
        print('Error searching donors: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء البحث')),
        );
      }
    }
  }

  void _contactDonor(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن متبرعين'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'الموقع',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الموقع';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBloodType,
                    decoration: const InputDecoration(
                      labelText: 'فصيلة الدم',
                      border: OutlineInputBorder(),
                    ),
                    items: _bloodTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodType = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار فصيلة الدم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _searchDonors,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('بحث'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _donors.isEmpty
                  ? const Center(child: Text('لا توجد نتائج بحث'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _donors.length,
                      itemBuilder: (context, index) {
                        final donor = _donors[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                donor['bloodType']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(donor['name']!),
                            subtitle: Text('المسافة: ${donor['distance']}'),
                            trailing: ElevatedButton(
                              onPressed: () => _contactDonor(donor['phone']!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('تواصل'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
