import 'package:dami_tosaveyou/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; //الملف الذي يدير بيانات المستخدم.
import '../models/user.dart'; //نموذج بيانات المستخدم

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //حالة الشاشة
  final _formKey = GlobalKey<FormState>(); //مفتاح النموذج
  final _emailController = TextEditingController(); //متحكم بالبريد الإلكتروني
  final _passwordController = TextEditingController(); //متحكم بكلمة المرور
  final _nameController = TextEditingController(); //متحكم بالاسم
  final _phoneController = TextEditingController(); //متحكم برقم الهاتف
  bool _isLogin =
      true; //متغير لتحديد إذا كان المستخدم يحاول تسجيل الدخول أم إنشاء حساب جديد
  String _selectedBloodType = 'A+';
  String _selectedRole = 'متبرع';

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
  final List<String> _roles = ['متبرع', 'محتاج'];

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // التحقق من صحة النموذج

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // حفظ حالة تسجيل الدخول

    final dbHelper = DatabaseHelper.instance; // الحصول على مساعد قاعدة البيانات
    final userId = _emailController.text; // استخدام البريد كمعرف فريد للمستخدم
    try {
      await dbHelper.saveUser(
        // حفظ بيانات المستخدم
        userId,
        _nameController.text,
        _emailController.text,
        _selectedRole,
        _selectedBloodType,
        0.0, // default latitude
        0.0, // default longitude
        _phoneController.text,
      );

      final userProvider =
          context.read<UserProvider>(); // الحصول على مزود بيانات المستخدم
      final user = User(
        // إنشاء كائن مستخدم
        id: userId,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        bloodType: _selectedBloodType,
        lastDonationDate: '',
        phone: _phoneController.text,
      );
      await userProvider.setUser(user); // حفظ بيانات المستخدم في مزود البيانات

      if (!mounted) return; // التحقق من أن الشاشة لا تزال موجودة
      Navigator.of(context).pushReplacement(
        // الانتقال إلى الشاشة الرئيسية
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print('Error during authentication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        // عرض رسالة خطأ
        const SnackBar(content: Text('حدث خطأ أثناء عملية المصادقة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          // السماح بالتمرير عندما يكون النص أطول من الشاشة
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.favorite,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب', // عنوان الشاشة
                  style:
                      Theme.of(context).textTheme.headlineMedium, // نمط العنوان
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      // حقل الإدخال
                      labelText: 'الاسم',
                      border: OutlineInputBorder(), // نمط الحدود
                    ),
                    validator: (value) {
                      if (!_isLogin && (value == null || value.isEmpty)) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // التحقق من صحة البريد الإلكتروني
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController, // متحكم كلمة المرور
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // إخفاء النص
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_isLogin && (value == null || value.isEmpty)) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // قائمة منسدلة
                    value: _selectedBloodType, // القيمة المحددة
                    decoration: const InputDecoration(
                      labelText: 'فصيلة الدم',
                      border: OutlineInputBorder(),
                    ),
                    items: _bloodTypes // القيم المتاحة
                        .map((type) => DropdownMenuItem(
                              // تحويل القيم إلى عناصر منسدلة
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // التغيير عند تحديد قيمة
                      setState(() {
                        // تحديث الحالة
                        _selectedBloodType = value!; // تحديد القيمة
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار فصيلة الدم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'الدور',
                      border: OutlineInputBorder(),
                    ),
                    items: _roles
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار الدور';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
                ),
                TextButton(
                  onPressed:
                      _switchAuthMode, // التبديل بين تسجيل الدخول وإنشاء حساب
                  child: Text(
                    _isLogin ? 'إنشاء حساب جديد' : 'لديك حساب بالفعل؟ سجل دخول',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
