import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blood_request.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import 'package:dami_tosaveyou/database/database_helper.dart';
import '../providers/blood_request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({Key? key}) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>(); // مفتاح النموذج
  final _descriptionController = TextEditingController(); // متحكم بالوصف
  final _locationController = TextEditingController();
  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'عادي';

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  final List<String> _urgencyLevels = ['عادي', 'مستعجل', 'حرج'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Any initialization that might call setState
    });
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final user = context.read<UserProvider>().user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
        );
        return;
      }
      final request = BloodRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bloodType: _selectedBloodType,
        status: 'جديد',
        createdBy: user.id,
        createdAt: DateTime.now().toIso8601String(),
        location: _locationController.text,
        urgency: _selectedUrgency,
        description: _descriptionController.text,
      );
      try {
        await DatabaseHelper.instance.saveBloodRequest(request);
        await context.read<BloodRequestProvider>().addRequest(request);
        await context.read<BloodRequestProvider>().fetchUserRequests(user.id);
        // إرسال إشعار إذا كان الطلب عاجلاً
        if (_selectedUrgency == 'حرج') {
          await context
              .read<NotificationProvider>()
              .showUrgentRequestNotification(
                title: 'طلب دم عاجل',
                body:
                    'طلب عاجل لفصيلة دم ${_selectedBloodType} في ${_locationController.text}',
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الطلب بنجاح')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print('Error creating request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إنشاء الطلب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء طلب تبرع'),
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
                        items: _urgencyLevels
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level),
                                ))
                            .toList(),
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
                child: const Text('إنشاء الطلب'),
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
