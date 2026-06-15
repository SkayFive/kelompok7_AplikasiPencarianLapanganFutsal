import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lapangan_futsal/models/user.dart';

class UserService {
  // Mengambil data  User yang login
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final isSignedIn = prefs.getBool('isSignedIn') ?? false;
    if (!isSignedIn) return null;

    return UserModel(
      username: prefs.getString('username') ?? 'User',
      email: prefs.getString('email') ?? '_',
      phone: prefs.getString('phone') ?? '_',
    );
  }

  //LogOut
  static Future<void> LogOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);
  }
}