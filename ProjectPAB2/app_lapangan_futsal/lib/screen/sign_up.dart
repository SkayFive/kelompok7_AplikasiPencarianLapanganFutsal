import 'package:app_lapangan_futsal/service/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String _errortext = '';
  bool _obscurePassword = true; // <- tambahkan jika ingin menambah icon mata
  bool rememberMe =
      false; // <- Tambahkan jika ingin membuat cheklist remember me

  //Key untuk validasiForm
  // final _formKey = GlobalKey<FormState>();

  // Fungsi Sign Up
  Future<void> _signup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset error text
    setState(() {
      _errortext = '';
    });

    //Validasi Kosong
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errortext = 'Semua Form wajib diisi';
      });
      return;
    }

    //Validasi Password
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?"{}|<>]'))) {
      setState(() {
        _errortext =
            'Minimal 8 karakter, kombinasi huruf besar, kecil, angka & simbol';
      });
      return;
    }

    try {
      // 1. Mendaftarkan user ke Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Menyimpan data tambahan (Username) ke Cloud Firestore
      // Menggunakan UID dari Firebase Auth sebagai Document ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': username,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Menampilkan pesan sukses
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));

        // Navigasi ke Dalam login
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik dari Firebase
      setState(() {
        if (e.code == 'weak-password') {
          _errortext = 'Password terlalu lemah.';
        } else if (e.code == 'email-already-in-use') {
          _errortext = 'Akun dengan email ini sudah terdaftar.';
        } else if (e.code == 'invalid-email') {
          _errortext = 'Format email tidak valid.';
        } else {
          _errortext = e.message ?? 'Terjadi kesalahan pada sistem.';
        }
      });
    } catch (e) {
      // Menangani error umum lainnya
      setState(() {
        _errortext = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 35),

                    // Membuat Teks Login rata Kiri
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Create an Account",
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
                      controller: _usernameController,
                      // Mengubah Warna Cursor Saat form diklik
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        // labelText: "Username",
                        hintText: 'Username',
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

                    // Form Email
                    TextFormField(
                      controller: _emailController,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        // labelText: "Email",
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
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
                        // labelText: "Password",
                        hintText: 'Password',
                        // errorText: _errortext.isNotEmpty ? _errortext : null,
                        hintStyle: TextStyle(color: Colors.grey),
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
                        Text(
                          "Remember Me",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),

                    //Tombol sign_up
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
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
                              SnackBar(content: Text("Login Googke Berhasil")),
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
                            text: "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signin');
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
