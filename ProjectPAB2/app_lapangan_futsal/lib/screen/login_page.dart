import 'package:app_lapangan_futsal/service/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errortext = '';
  // bool _isSignedIn = false;
  bool _obscurePassword = true; // <- tambahkan jika ingin menambah icon mata
  bool rememberMe =
      false; // <- Tambahkan jika ingin membuat cheklist remember me

  // Fungsi Sign In menggunakan Firebase
  Future<void> _signin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _errortext = ''; // Reset error text
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errortext = 'Email dan password tidak boleh kosong';
      });
      return;
    }

    try {
      // Login menggunakan Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan preferensi Remember Me jika diperlukan (opsional)
      // Catatan: Firebase secara otomatis menyimpan sesi login secara default
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('rememberMe', true);
      }

      // Navigasi jika widget masih aktif
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/mainscreen');
      }
    } on FirebaseAuthException catch (e) {
      // Tangkap pesan error dari Firebase
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          _errortext = 'Akun belum terdaftar atau kredensial salah.';
        } else if (e.code == 'wrong-password') {
          _errortext = 'Password salah.';
        } else if (e.code == 'invalid-email') {
          _errortext = 'Format email tidak valid.';
        } else {
          _errortext = e.message ?? 'Terjadi kesalahan sistem.';
        }
      });
    } catch (e) {
      setState(() {
        _errortext = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna teks berdasarkan tema saat ini (kalau mode gelap akan jadi putih dan kalau putih akan jadi hitam)
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              //Mengatur Ukuran Box
              child: Form(
                // key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo-futsal-3.png",
                        height: 130,
                      ),
                    ),
                    SizedBox(height: 35),

                    // Membuat Teks Login rata Kiri
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tampilkan Error Text di atas form jika ada
                    if (_errortext.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errortext,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    //Form Username
                    TextFormField(
                      controller: _emailController,
                      // Mengubah Warna Cursor Saat form diklik
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        // Membuat Warna Teks Tidak berubah saat Form fi Klik
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // Ubah Warna form ketika di klik
                        focusedBorder: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                        // Membuat warna form menjadi biru
                        enabledBorder: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.person_outline_outlined),
                      ),
                    ),
                    SizedBox(height: 25),

                    //Form Password
                    TextFormField(
                      controller: _passwordController,
                      // Membuat warna cursor Menjadi warna biru saatt form di klik
                      cursorColor: Colors.blue,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        // errorText: _errortext.isNotEmpty ? _errortext : null,
                        // Membuat warna teks tidak berubah saat di klik
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Membuat warna form berubah saat diklik
                        focusedBorder: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                        // Membuat warna form menjadi biru
                        enabledBorder: OutlineInputBorder(
                          // Membuat sudut menjadi melengkung
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.lock_outlined),

                        //Tambahkan Icon Mata
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Membuat chekbox Remember me
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          activeColor: Colors.blue, // Warna saat centang aktif
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        Text("Remember Me", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 25),

                    //Tombol Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),

                    // Membuat garis lurus dengan teks Or di tengah nya
                    Row(
                      children: [
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Or", style: TextStyle(fontSize: 16)),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 25),

                    // Menambah Logo Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final user = await AuthService.signInWithGoogle();
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login Berhasil")),
                            );
                            // Arahkan ke halaman Home
                            Navigator.pushReplacementNamed(
                              context,
                              '/mainscreen',
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/logo-google.png", height: 24),
                            SizedBox(width: 10),
                            Text(
                              "Sign In whit Google",
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                // color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 35),

                    RichText(
                      text: TextSpan(
                        text: "Forgot Password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                    SizedBox(height: 35),

                    //Tombol Register
                    RichText(
                      text: TextSpan(
                        text: "Don't have a account? ",
                        style: TextStyle(fontSize: 16, color: textColor),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signup');
                              }, // Aksi ketika teks di tekan
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
