import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blood_request_provider.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailsScreen({super.key, required this.requestId});

  @override
  _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestProvider = context.read<BloodRequestProvider>();
      requestProvider.fetchRequestById(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = context.watch<BloodRequestProvider>();
    final request = requestProvider.requests
        .firstWhere((req) => req.id == widget.requestId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('فصيلة الدم', request.bloodType),
            _buildDetailItem('الموقع', request.location),
            _buildDetailItem('الحالة', request.status),
            _buildDetailItem('تاريخ الطلب', request.createdAt.toString()),
            // إضافة المزيد من التفاصيل حسب الحاجة
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
