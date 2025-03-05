import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // لتخصيص الخطوط
import 'package:provider/provider.dart'; // لإدارة الحالة
import 'package:shared_preferences/shared_preferences.dart'; // لحفظ البيانات المحلية
import 'providers/user_provider.dart';
import 'providers/blood_request_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/help_screen.dart';
import 'screens/my_requests_screen.dart'; // Add this line
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تهيئة Flutter
  final prefs = await SharedPreferences
      .getInstance(); //يتحقق من SharedPreferences لمعرفة إذا كان المستخدم مسجلًا.
  final isLoggedIn =
      prefs.getBool('isLoggedIn') ?? false; // التحقق من تسجيل الدخول

  // تهيئة الإشعارات
  final notificationProvider = NotificationProvider();
  await notificationProvider.requestPermission();

  // تهيئة قاعدة البيانات
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // قائمة المزودات
        ChangeNotifierProvider(
            create: (_) =>
                UserProvider()), //يُنشئ كائنًا من النموذج (مثل UserProvider) ويسمح للواجهات الاستماع إلى تغييراته.
        ChangeNotifierProvider(create: (_) => BloodRequestProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn), // التطبيق الرئيسي
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // حالة تسجيل الدخول

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دمي لإنقاذك',
      theme: ThemeData(
        // إعداد الثيم (ThemeData) التطبيق
        primaryColor: const Color(0xFFFF4D4D), // اللون الأحمر الرئيسي
        colorScheme: ColorScheme.fromSeed(
          //لإنشاء مخطط ألوان ديناميكي
          seedColor: const Color(0xFFFF4D4D), // توليد ألوان متناسقة
          primary: const Color(0xFFFF4D4D),
          secondary: Colors.white, //يحدد اللون الثانوي وهو الأبيض هنا
          background: Colors.white,
        ),
        textTheme: GoogleFonts.cairoTextTheme(
          //  ال cairo تطبيق خط عربي
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFF4D4D), // لون خلفية AppBar
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.cairo(
            // خط عناوين عربي
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // تشغيل SplashScreen أولًا
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/create-request': (context) => const CreateRequestScreen(),
        '/help': (context) => const HelpScreen(),
        '/my-requests': (context) => const MyRequestsScreen(), // Add this line
      },
    );
  }
}
