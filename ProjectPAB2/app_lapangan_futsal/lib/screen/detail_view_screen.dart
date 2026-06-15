import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_lapangan_futsal/models/lapangan.dart';
import 'package:intl/intl.dart';

class DetailViewScreen extends StatefulWidget {
  final futsalField field;
  // fieldId penting agar StreamBuilder tahu review mana yang harus diambil
  const DetailViewScreen({super.key, required this.field});

  @override
  State<DetailViewScreen> createState() => _DetailViewScreenState();
}

class _DetailViewScreenState extends State<DetailViewScreen> {
  bool isAdmin = false;

  // initState
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() => isAdmin = doc.data()?['role'] == 'admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Komentar untuk Lapangan ini',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: () {
          final String id = widget.field.id;
          debugPrint(
            "Cek Debug: Mencari collection 'reviews' dengan fieldId: '$id'",
          );
          return FirebaseFirestore.instance
              .collection('reviews')
              .where('fieldId', isEqualTo: id)
              .orderBy('date', descending: true)
              .snapshots();
        }(),
        builder: (context, snapshot) {
          // 1. Cek Error
          if (snapshot.hasError) {
            debugPrint("Error Firebase: ${snapshot.error}");
            return Center(child: Text("Terjadi error: ${snapshot.error}"));
          }

          // 2. Cek Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Cek Data Kosong
          final reviews = snapshot.data?.docs ?? [];
          debugPrint("Jumlah Data Ditemukan: ${reviews.length}");

          if (reviews.isEmpty) {
            return const Center(
              child: Text("Belum ada ulasan untuk lapangan ini."),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ratingSummary(reviews),
                const SizedBox(height: 20),
                if (reviews.isEmpty)
                  const Text("Belum ada ulasan untuk lapangan ini."),
                ...reviews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Gunakan data dari Firestore
                  return _reviewItem(
                    name: data['userName'] ?? 'User',
                    date: data['date'] != null
                        ? DateFormat(
                            'd MMMM yyyy',
                          ).format(DateTime.parse(data['date']))
                        : '',
                    reviewDocId: doc.id,
                    ownerId: data['userId'] ?? '',
                    isAdmin: isAdmin,
                    rating: (data['rating'] ?? 0.0).toDouble(),
                    comment: data['comment'] ?? '',
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _ratingSummary(List<QueryDocumentSnapshot> reviews) {
    // Cek mode gelap atau terang
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    double average = 0;
    if (reviews.isNotEmpty) {
      double total = 0;
      for (var r in reviews) {
        total += (r.data() as Map<String, dynamic>)['rating'] ?? 0.0;
      }
      average = total / reviews.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDarkMode ? Border.all(color: Colors.blue.shade700) : null,
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Rata-rata Rating',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < average.round() ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget REVIEW ITEM
  Widget _reviewItem({
    required String name,
    required String date,
    required double rating,
    required String comment,
    required String reviewDocId, // Tambahkan ID dokumen review
    required String ownerId, // UID pemilik komentar
    required bool isAdmin, // Status admin user
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // Logika tampilan tombol hapus
    bool canDelete =
        isAdmin || (currentUser != null && currentUser.uid == ownerId);

    // Cek Mode gelap
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16), // pakai const
      padding: EdgeInsets.all(16), // pakai const
      decoration: BoxDecoration(
        // terapkan warna dinamis
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDarkMode ? Border.all(color: Colors.blue.shade700) : null,
        // Matikan kalau mode gelap
        boxShadow: isDarkMode
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isDarkMode
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.blue.shade100,
                child: Icon(Icons.person, color: Colors.blue),
              ),
              SizedBox(width: 12), // 🔧 DIUBAH: pakai const
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  // Tombol hapus
                  if (canDelete)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await FirebaseFirestore.instance
                              .collection('reviews')
                              .doc(reviewDocId)
                              .delete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus Komentar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ), // pakai const
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange.withOpacity(0.15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4), // 🔧 DIUBAH: pakai const
                        Text(
                          rating.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          Text(
            comment,
            textAlign: TextAlign.left,
            style: TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}