import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/blood_request_provider.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class RequestFilterScreen extends StatefulWidget {
  const RequestFilterScreen({Key? key}) : super(key: key);

  @override
  _RequestFilterScreenState createState() => _RequestFilterScreenState();
}

class _RequestFilterScreenState extends State<RequestFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التبرع'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'عادي'),
            Tab(text: 'مستعجل'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestList(context, 'عادي'),
          _buildRequestList(context, 'مستعجل'),
        ],
      ),
    );
  }

  Widget _buildRequestList(BuildContext context, String urgency) {
    return Consumer<BloodRequestProvider>(
      builder: (context, provider, child) {
        final requests = provider.requests
            .where((request) => request.urgency == urgency)
            .toList();
        if (requests.isEmpty) {
          return const Center(
            child: Text('لا توجد طلبات'),
          );
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(request.bloodType),
                subtitle: Text(request.location),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final dbHelper = DatabaseHelper.instance;
                    final userData =
                        await dbHelper.getUserById(request.createdBy);
                    if (userData != null) {
                      final user = User.fromMap(userData);
                      await _contactUser(user.phone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تعذر العثور على رقم الهاتف')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تبرع الآن'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _contactUser(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (!await launchUrl(launchUri)) {
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
      );
    }
  }
}
