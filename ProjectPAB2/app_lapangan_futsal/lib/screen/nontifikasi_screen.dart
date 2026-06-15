import 'package:flutter/material.dart';

class NotificationDemo extends StatelessWidget {
  const NotificationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Notification Items
            const NotificationCard(
              title: "FutsalFinder",
              description:
                  "Lapangan futsal favoritmu siap dipakai! Pesan sekarang dan nikmati permainan tanpa antrean.",
              imageUrl: "assets/futsal_lima.jpg",
            ),
            const NotificationCard(
              title: "Cleaning Bed",
              description:
                  "Jaga skill futsalmu tetap tajam! Pesan lapangan sekarang dan main dengan teman-temanmu kapan saja.",
              imageUrl: "assets/futsal_empat.jpg",
            ),
            const NotificationCard(
              title: "Cleaning Bed",
              description:
                  "Mau main futsal sore ini? Cek ketersediaan lapangan terbaru dan booking mudah lewat aplikasi kami!",
              imageUrl: "assets/futsal_satu.jpg",
            ),

            const SizedBox(height: 20),

            // Selengkapnya Button
            GestureDetector(
              onTap: () => print("Selengkapnya clicked"),
              child: const Text(
                "Selengkapnya",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Description
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    // style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika gambar gagal dimuat
                    return Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
