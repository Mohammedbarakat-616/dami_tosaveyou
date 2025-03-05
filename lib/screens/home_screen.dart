import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // استيراد حزمة لفتح الروابط الاتصال و الرسائل البريد الإلكتروني
import '../providers/user_provider.dart';
import '../providers/blood_request_provider.dart'; // إضافة استيراد لمزود البيانات
import '../models/blood_request.dart'; // إضافة استيراد لنموذج BloodRequest
import '../database/database_helper.dart';
import 'auth_screen.dart';
import '../models/user.dart'; // إضافة استيراد لنموذج User
import 'request_filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // دالة تُستدعى عند تهيئة الحالة الأولية للشاشة
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //لتهيئة البيانات الأولية بعد تهيئة الشاشة
      try {
        _loadRequests(); //تحميل الطلبات
      } catch (e) {
        print('Error loading requests: $e');
      }
    });
  }

  Future<void> _loadRequests() async {
    // دالة لتحميل الطلبات
    await context
        .read<BloodRequestProvider>()
        .fetchRequests(); //استدعاء دالة لجلب الطلبات
  }

  Future<void> _contactUser(String phoneNumber) async {
    // دالة للتواصل مع المستخدم
    final Uri launchUri = Uri(
      // إنشاء رابط لفتح تطبيق الهاتف
      scheme: 'tel', // نوع الرابط
      path: phoneNumber, // رقم الهاتف
    );
    try {
      if (!await launchUrl(launchUri)) {
        // فتح التطبيق هاتف الاتصال
        throw Exception('Could not launch $launchUri');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        // إظهار رسالة تنبيه
        const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // زر تسجيل الخروج
              final confirmed = await showDialog<bool>(
                // عرض نافذة تأكيد الخروج
                context: context,
                builder: (ctx) => AlertDialog(
                  // إنشاء نافذة تأكيد الخروج
                  title: const Text('تأكيد الخروج'),
                  content: const Text(
                      'هل أنت متأكد من رغبتك في تسجيل الخروج؟'), // نص تأكيد الخروج
                  actions: [
                    TextButton(
                      // زر إلغاء
                      onPressed: () =>
                          Navigator.pop(ctx, false), // إغلاق النافذة
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      // زر تأكيد
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // إذا تم تأكيد الخروج
                await context.read<UserProvider>().logout(); // تسجيل الخروج
                if (!context.mounted)
                  return; // التحقق من أن الشاشة لا تزال موجودة
                Navigator.of(context).pushReplacement(
                  // الانتقال إلى شاشة تسجيل الدخول
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // إضافة ميزة السحب لأسفل لإعادة تحميل البيانات
        onRefresh: _loadRequests, // دالة تحميل الطلبات
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildEmergencyRequests(), // عرض الطلبات العاجلة
            const SizedBox(height: 20),
            _buildQuickActions(context), // عرض الخدمات السريعة
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // إضافة شريط التنقل السفلي
        currentIndex: 0,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RequestFilterScreen()),
              );
              break;
          }
        },
        items: const [
          // إضافة العناصر الثابتة لشريط التنقل
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'الطلبات',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyRequests() {
    // دالة لعرض الطلبات العاجلة
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طلبات عاجلة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: Consumer<BloodRequestProvider>(
            //يستخدم Consumer للوصول إلى الطلبات العاجلة من BloodRequestProvider.
            builder: (context, provider, child) {
              //
              final urgentRequests =
                  provider.getUrgentRequests(); // الحصول على الطلبات العاجلة
              if (urgentRequests.isEmpty) {
                return const Center(
                  child: Text('لا توجد طلبات عاجلة حالياً'),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: urgentRequests.length, //عدد الطلبات العاجلة
                itemBuilder: (context, index) {
                  // إنشاء بطاقة لكل طلب
                  final request = urgentRequests[index];
                  return _buildRequestCard(request); // إنشاء بطاقة الطلب
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bloodtype,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  request.bloodType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.location, // عرض الموقع
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // عرض النص بشكل مقتصر
            ),
            const Spacer(), //
            ElevatedButton(
              // زر التبرع
              onPressed: () async {
                final dbHelper = DatabaseHelper.instance; //
                final userData = await dbHelper.getUserById(
                    request.createdBy); // الحصول على بيانات المستخدم
                if (userData != null) {
                  final user = User.fromMap(userData); // إنشاء كائن مستخدم
                  await _contactUser(user.phone); // التواصل مع المستخدم
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // إظهار رسالة تنبيه
                    const SnackBar(content: Text('تعذر العثور على رقم الهاتف')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('تبرع الآن'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خدمات سريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, // عدد العناصر في الصف
          mainAxisSpacing: 16, // المسافة الرأسية بين العناصر
          crossAxisSpacing: 16, // المسافة الأفقية بين العناصر
          children: [
            _buildActionCard(
              context,
              'طلب تبرع',
              Icons.add_circle,
              () => Navigator.pushNamed(context, '/create-request'),
            ),
            _buildActionCard(
              context,
              'البحث عن متبرع',
              Icons.search,
              () => Navigator.pushNamed(context, '/search'),
            ),
            _buildActionCard(
              context,
              'طلباتي',
              Icons.list_alt,
              () => Navigator.pushNamed(context, '/my-requests'),
            ),
            _buildActionCard(
              context,
              'المساعدة',
              Icons.help,
              () => Navigator.pushNamed(context, '/help'),
            ),
          ],
        ), // إنشاء بطاقة لكل خدمة سريعة
      ],
    );
  }

  Widget _buildActionCard(
    // دالة لإنشاء بطاقة الخدمة السريعة
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
