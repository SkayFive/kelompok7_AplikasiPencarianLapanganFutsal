import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_lapangan_futsal/screen/hubungi_kami_screen.dart';
import 'package:app_lapangan_futsal/screen/kebijakan_privasi_screen.dart';
import 'package:app_lapangan_futsal/screen/login_page.dart';
import 'package:app_lapangan_futsal/screen/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lapangan_futsal/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  String phoneNumber = '';
  bool isLoading = true;
  bool isLoggedIn = false;
  File? profileImage;
  Uint8List? webProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // fungsi untuk mengambil inisial nama
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0].toUpperCase());
    } else {
      return name.length > 1
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
  }

  // Menarik data dari Firebase Auth dan Firestore
  Future<void> _loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      isLoggedIn = true;
      email = currentUser.email ?? '';

      try {
        // Ambil data dari Cloud Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // jadikan nama akun google sebagai nilai awal
        username = currentUser.displayName ?? 'PenggunaBaru';

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Hanya timpa username jika di Firestore datanya ada
          if (data['username'] != null &&
              data['username'].toString().trim().isNotEmpty) {
            username = data['username'];
          }

          String? imagePath = data['profile_image_local_path'];
          if (imagePath != null && imagePath.isNotEmpty) {
            if (kIsWeb) {
              profileImage = File(imagePath);
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    } else {
      isLoggedIn = false;
      username = '';
      email = '';
      phoneNumber = '';
      profileImage = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Bagian ProfileHeader
  Widget _profileHeader() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      children: [
        CircleAvatar(
          key: UniqueKey(),
          radius: 35,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: webProfileImage != null
              ? MemoryImage(webProfileImage!) as ImageProvider
              : (profileImage != null ? FileImage(profileImage!) : null),
          child: (webProfileImage == null && profileImage == null)
              ? (isLoggedIn && username.isNotEmpty
                    ? Text(
                        _getInitials(username),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      )
                    : Icon(Icons.person, size: 40, color: Colors.blue.shade700))
              : null,
        ),
        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoggedIn ? username : 'Guest',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),

              Text(
                isLoggedIn ? email : 'Login untuk melanjutkan',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              // SizedBox(height: 4),
              if (phoneNumber.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Menu Item
  Widget _menuItem({
    required IconData icon,
    required String title,
    required onTap,
    Color iconColor = Colors.blue,
    // VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Fungsi Logout menggunakan Firebase Auth
  // Future<void> _logout() async {
  //   await FirebaseAuth.instance.signOut();

  //   if (!mounted) return;
  //   Navigator.pushReplacementNamed(context, '/signin');
  // }

  // pop up Logout
  Future<void> _signOut() async {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    // konfirmasi sebelum logout
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: textColor)),
          ),

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: isDarkMode ? Colors.blue : Colors.white),
        ),
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              SizedBox(height: 16),
              Divider(),
              // _menuItem(icon: Icons.location_on_outlined, title: 'Ubah Lokasi'),
              // _menuItem(icon: Icons.favorite_border, title: 'favorite'),
              SizedBox(height: 4),
              Text(
                'Akun Anda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              _menuItem(
                icon: Icons.account_circle_outlined,
                title: 'Edit profile',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(
                        username: username,
                        email: email,
                        imagePath: profileImage?.path,
                        webImage: webProfileImage,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      username = result['username'] ?? username;
                      email = result['email'] ?? email;
                      phoneNumber = result['phone'] ?? phoneNumber;

                      if (result['webImage'] != null) {
                        webProfileImage = result['webImage'];
                        profileImage = null;
                      } else if (result['image'] != null) {
                        profileImage = File(result['image']);
                        webProfileImage = null;
                      }
                    });
                  }
                },
              ),
              // _menuItem(
              //   icon: Icons.lock_outline,
              //   title: 'Kata Sandi dan Keamanan',
              //   onTap: () {},
              // ),
              Divider(),
              SizedBox(height: 4),
              Text(
                'Info Lainnya',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              _menuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KebijakanPrivasiScreen()),
                  );
                },
              ),

              // Menu Mode Gelap
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentMode, child) {
                  final isDarkMode = currentMode == ThemeMode.dark;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.yellow.withOpacity(0.2)
                            : Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
                        color: isDarkMode ? Colors.yellow : Colors.purple,
                      ),
                    ),
                    title: const Text('Mode Gelap'),
                    trailing: Switch(
                      value: isDarkMode,
                      activeColor: Colors.blue.shade600,
                      onChanged: (value) async {
                        // 1. Ubah tema aplikasi secara langsung
                        themeNotifier.value = value
                            ? ThemeMode.dark
                            : ThemeMode.light;
                        // 2. Simpan pilihan ke SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isDark', value);
                      },
                    ),
                  );
                },
              ),

              _menuItem(
                icon: Icons.support_agent_outlined,
                title: 'Hubungi Kami',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HubungiKamiScreen()),
                  );
                },
              ),
              Divider(),
              SizedBox(height: 60),

              //Logout button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoggedIn
                        ? _signOut
                        : () {
                            Navigator.pushNamed(context, '/signin');
                          },
                    child: Text(
                      isLoggedIn ? 'Logout' : 'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
