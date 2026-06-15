import 'package:flutter/material.dart';

class HubungiKamiScreen extends StatelessWidget {
  const HubungiKamiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Hubungi Kami', style: TextStyle(color: Colors.white)),
        // backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue,
        elevation: 0,
        // iconTheme: IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 22),
                SizedBox(width: 10),
                Text(
                  '144-3334-11',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            Row(
              children: [
                Icon(Icons.email_outlined, size: 22),
                SizedBox(width: 10),
                Text(
                  'futsalfinder@gmail.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
