import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GiveRatingScreen extends StatefulWidget {
  final String fieldId;

  const GiveRatingScreen({super.key, required this.fieldId});

  @override
  State<GiveRatingScreen> createState() => _GiveRatingScreenState();
}

class _GiveRatingScreenState extends State<GiveRatingScreen> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beri Rating', style: TextStyle(color: Colors.white)),
        // iconTheme: IconThemeData(color: Colors.white),
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Comment
            Text(
              'Beri Komentar untuk lapangan ini?',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            TextField(
              controller: commentController,
              maxLength: 300,
              maxLines: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Tulis Komentar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16),

            //Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (selectedRating == 0 || commentController.text.isEmpty) {
                    return;
                  }
                  final user = FirebaseAuth.instance.currentUser;
                  String userName = 'Anonymous';
                  if (user != null) {
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    if (userDoc.exists) {
                      final data = userDoc.data() as Map<String, dynamic>;
                      userName = data['username'] ?? 'User';
                    }
                  }

                  // simpan ke firestore
                  await FirebaseFirestore.instance.collection('reviews').add({
                    'fieldId': widget
                        .fieldId, // Tambahkan parameter fieldId ke class ini
                    'userId': user?.uid,
                    'userName': userName,
                    'rating': selectedRating.toDouble(),
                    'comment': commentController.text,
                    'date': DateTime.now().toIso8601String(),
                  });
                  Navigator.pop(context);
                },
                child: Text('Kirim', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
