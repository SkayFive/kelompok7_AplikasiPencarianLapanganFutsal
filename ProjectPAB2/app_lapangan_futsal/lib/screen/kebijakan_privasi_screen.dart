import 'package:flutter/material.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(color: Colors.white),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
        // iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Align(
              alignment: Alignment.center,
              child: Text(
                'KEBIJAKAN PRIVASI FUTSALFINDER',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'FutsalFinder adalah aplikasi yang membantu pengguna '
              'menemukan dan melihat informasi lapangan futsal di sekitar mereka. '
              'Kami berkomitmen untuk melindungi privasi dan keamanan data pengguna. '
              'Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, '
              'menggunakan, dan melindungi informasi Anda saat menggunakan aplikasi FutsalFinder.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 16),

            Text(
              '1. Informasi yang Kami Kumpulkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Untuk mendukung fitur aplikasi, kami dapat mengumpulkan informasi berikut:',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 8),

            BulletText(
              text:
                  'Informasi Pribadi: Nama, email, dan nomor telepon yang digunakan saat membuat akun.',
            ),
            BulletText(
              text:
                  'Informasi Lokasi: Data lokasi pengguna untuk menampilkan lapangan futsal terdekat.',
            ),
            BulletText(
              text:
                  'Informasi Teknis: Jenis perangkat, sistem operasi, alamat IP, dan log aktivitas aplikasi.',
            ),

            SizedBox(height: 16),
            Text(
              '2. Penggunaan Informasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletText(
              text:
                  'Menyediakan fitur pencarian lapangan futsal berdasarkan lokasi.',
            ),
            BulletText(
              text:
                  'Menampilkan informasi lapangan futsal yang relevan dan akurat.',
            ),
            BulletText(
              text:
                  'Meningkatkan performa dan pengalaman pengguna dalam aplikasi.',
            ),
            BulletText(
              text: 'Memenuhi ketentuan hukum dan peraturan yang berlaku.',
            ),

            SizedBox(height: 16),
            Text(
              '3. Perlindungan Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletText(
              text:
                  'Kami menggunakan langkah-langkah keamanan teknis dan organisasi untuk melindungi data pengguna.',
            ),
            BulletText(
              text:
                  'Data sensitif dilindungi dengan sistem keamanan yang sesuai.',
            ),
            BulletText(
              text:
                  'Akses terhadap data dibatasi hanya untuk pihak yang berwenang.',
            ),

            SizedBox(height: 16),
            Text(
              '4. Berbagi Informasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletText(
              text:
                  'Kami tidak menjual atau menyewakan informasi pribadi pengguna kepada pihak ketiga.',
            ),
            BulletText(
              text: 'Informasi hanya dibagikan jika diwajibkan oleh hukum.',
            ),

            SizedBox(height: 16),
            Text(
              '5. Perubahan Kebijakan Privasi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kebijakan Privasi ini dapat diperbarui sewaktu-waktu. '
              'Perubahan akan diinformasikan melalui aplikasi.',
              style: TextStyle(height: 1.5),
            ),

            SizedBox(height: 16),
            Text('6. Kontak', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini, '
              'silakan hubungi tim FutsalFinder melalui aplikasi.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;

  const BulletText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
