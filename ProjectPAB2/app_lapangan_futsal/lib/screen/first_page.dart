import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  //Key untuk validasiForm
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Menentukan ukuran font dan padding berdasarkan lebar layar
    double fontSize = screenWidth * 0.05; // 5% dari lebar layar
    // double padding = screenWidth * 0.1;   // 10% dari lebar layar

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image-bg4.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, 
                  Colors.black.withOpacity(0.76),
                  Colors.black.withOpacity(0.96),
                  Colors.black.withOpacity(1.00)
                ],
                stops: [0.00, 0.35, 0.99, 1.00],
              ),
            ),
          ),

          // CONTENT
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 600 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(),

                          Text(
                            "Explore Courts. Create Moments",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 36 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            "Search courts instantly, compare location and facilities, "
                            "and explore ongoing events to make your game time easier "
                            "to plan and more enjoyable",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          RichText(
                            text: TextSpan(
                              text: "Already have an Account? ",
                              style: const TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/signin');
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}