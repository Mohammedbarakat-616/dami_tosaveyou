import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHelpSection(
            context,
            'شروط التبرع بالدم',
            [
              'العمر بين 18 و65 سنة',
              'الوزن أكثر من 50 كجم',
              'خالي من الأمراض المعدية',
              'مستوى الهيموجلوبين طبيعي',
              'عدم تناول أدوية مضادة للتخثر',
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            context,
            'قبل التبرع',
            [
              'النوم جيداً ليلة التبرع',
              'تناول وجبة خفيفة قبل التبرع',
              'شرب الكثير من الماء',
              'تجنب التدخين قبل التبرع بساعتين',
              'إحضار بطاقة الهوية',
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            context,
            'بعد التبرع',
            [
              'الراحة لمدة 10-15 دقيقة',
              'تناول المشروبات والأطعمة المقدمة',
              'تجنب المجهود البدني ليوم كامل',
              'شرب الكثير من السوائل',
              'تناول وجبة غنية بالحديد',
            ],
          ),
          const SizedBox(height: 16),
          _buildHelpSection(
            context,
            'معلومات هامة',
            [
              'يمكن التبرع كل 3 أشهر',
              'كمية الدم المتبرع بها 450 مل',
              'مدة التبرع 30-45 دقيقة',
              'يتم فحص الدم قبل التبرع',
              'التبرع بالدم آمن تماماً',
            ],
          ),
          const SizedBox(height: 24),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
      BuildContext context, String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تواصل معنا',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('الخط الساخن'),
              subtitle: const Text('777777777'),
              onTap: () => _makePhoneCall('777777777'),
            ),
            ListTile(
              leading: Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('البريد الإلكتروني'),
              subtitle: const Text('support@blooddonation.com'),
              onTap: () => _sendEmail('support@blooddonation.com'),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              title: const Text('واتساب'),
              subtitle: const Text('123456789'),
              onTap: () => _openWhatsApp('123456789'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (!await launchUrl(launchUri)) {
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      // Handle the exception, e.g., show a dialog or a snackbar
      print('Error: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (!await launchUrl(emailUri)) {
        throw Exception('Could not launch $emailUri');
      }
    } catch (e) {
      // Handle the exception, e.g., show a dialog or a snackbar
      print('Error: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber',
    );
    try {
      if (!await launchUrl(whatsappUri)) {
        throw Exception('Could not launch $whatsappUri');
      }
    } catch (e) {
      // Handle the exception, e.g., show a dialog or a snackbar
      print('Error: $e');
    }
  }
}
