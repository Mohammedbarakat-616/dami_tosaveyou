import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_request_provider.dart';
import '../providers/user_provider.dart';
import '../models/blood_request.dart';
import 'request_details_screen.dart';
import 'package:dami_tosaveyou/screens/edit_request_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  _MyRequestsScreenState createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final userProvider = context.read<UserProvider>();
        final bloodRequestProvider = context.read<BloodRequestProvider>();
        bloodRequestProvider.fetchUserRequests(userProvider.user!.id);
      } catch (e) {
        print('Error fetching user requests: $e');
      }
    });
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الانتظار':
        return Colors.orange;
      case 'ملغى':
        return Colors.red;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<BloodRequestProvider>(
        builder: (context, bloodRequestProvider, child) {
          final requests = bloodRequestProvider.userRequests;
          return Container(
            padding: const EdgeInsets.all(16),
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'لا توجد طلبات لعرضها',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => _navigateToDetails(context, request),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bloodtype,
                                  size: 32,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            request.bloodType,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          _buildStatusChip(
                                              context, request.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        request.location,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        request.description,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              // Navigate to edit screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditRequestScreen(
                                                          request: request),
                                                ),
                                              ).then((_) {
                                                setState(() {
                                                  final userProvider = context
                                                      .read<UserProvider>();
                                                  final bloodRequestProvider =
                                                      context.read<
                                                          BloodRequestProvider>();
                                                  bloodRequestProvider
                                                      .fetchUserRequests(
                                                          userProvider
                                                              .user!.id);
                                                });
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title:
                                                      const Text('تأكيد الحذف'),
                                                  content: const Text(
                                                      'هل أنت متأكد من رغبتك في حذف هذا الطلب؟'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, false),
                                                      child:
                                                          const Text('إلغاء'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, true),
                                                      child:
                                                          const Text('تأكيد'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                await context
                                                    .read<
                                                        BloodRequestProvider>()
                                                    .deleteRequest(request.id);
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    return Chip(
      backgroundColor: _getStatusColor(status, context).withOpacity(0.2),
      label: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status, context),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _getStatusColor(status, context)),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, BloodRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailsScreen(requestId: request.id),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تصفية الطلبات'),
        content: const Text('إضافة خيارات التصفية هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // تنفيذ عملية التصفية
              Navigator.of(ctx).pop();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
