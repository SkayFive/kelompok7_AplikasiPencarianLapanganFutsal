import 'package:app_lapangan_futsal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_lapangan_futsal/screen/first_page.dart';
import 'package:app_lapangan_futsal/screen/login_page.dart';
import 'package:app_lapangan_futsal/screen/main_screen.dart';
import 'package:app_lapangan_futsal/screen/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Variabel global untk mengontrol tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Ambil data tema yang tersimpan SharedPreferences saat aplikasi pertama dibuka
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;

  // set tema awal sesuai data yang tersimpan
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 3. Bungkus MaterialApp dengan ValueListenableBuilder
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          // Tema Terang
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            // Bagian Appbar
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            // Bagian Navbar
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.grey.shade600,
              unselectedItemColor: Colors.grey,
            ),
          ),

          // Tema hitam (dark Mode)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            // bagiam APpbar
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
            // bagian Navbar
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey.shade900,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey.shade600,
            ),
          ),
          // Tema sedang aktif
          themeMode: currentMode,

          // home:MainScreen(),
          initialRoute: '/',
          routes: {
            '/': (context) => const FirstPage(),
            '/mainscreen': (context) => const MainScreen(),
            '/signin': (context) => const LoginPage(),
            '/signup': (context) => const SignUp(),
          },
        );
      },
    );
  }
}
