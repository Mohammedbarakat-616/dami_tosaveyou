import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blood_request.dart';
import '../providers/blood_request_provider.dart';

class EditRequestScreen extends StatefulWidget {
  final BloodRequest request;

  const EditRequestScreen({Key? key, required this.request}) : super(key: key);

  @override
  _EditRequestScreenState createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late String _selectedBloodType;
  late String _selectedUrgency;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.request.description);
    _locationController = TextEditingController(text: widget.request.location);
    _selectedBloodType = widget.request.bloodType;
    _selectedUrgency = widget.request.urgency;
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final updatedRequest = widget.request.copyWith(
        bloodType: _selectedBloodType,
        urgency: _selectedUrgency,
        location: _locationController.text,
        description: _descriptionController.text,
      );
      try {
        await context.read<BloodRequestProvider>().updateRequest(updatedRequest);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الطلب بنجاح')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحديث الطلب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الطلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات الطلب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedBloodType,
                        decoration: const InputDecoration(
                          labelText: 'فصيلة الدم المطلوبة',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
                        ].map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء اختيار فصيلة الدم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedUrgency,
                        decoration: const InputDecoration(
                          labelText: 'مستوى الاستعجال',
                          border: OutlineInputBorder(),
                        ),
                        items: ['عادي', 'مستعجل', 'حرج'].map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgency = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى اختيار درجة الاستعجال';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الموقع والتفاصيل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'الموقع',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الموقع';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'تفاصيل إضافية',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال التفاصيل';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('تحديث الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
