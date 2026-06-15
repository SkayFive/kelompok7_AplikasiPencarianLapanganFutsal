import 'dart:convert';
import 'dart:async';
import 'package:app_lapangan_futsal/screen/detail_view_screen.dart';
import 'package:app_lapangan_futsal/screen/give_rating_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lapangan_futsal/models/lapangan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final futsalField field;
  final VoidCallback? onFavoriteChanged;

  const DetailScreen({super.key, required this.field, this.onFavoriteChanged});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  bool isSignedIn = false;
  String? currentUserUid;

  // Fungsi membuka google maps dengan koordinat akurat
  Future<void> _openGoogleMaps() async {
    final double lat = widget.field.latitude;
    final double lng = widget.field.longitude;

    // URL yang benar untuk mencari titik koordinat di Google Maps
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
    _loadFavoriteStatus();
  }

  // Menggunakan Firebase Auth untuk mengecek status login
  void _checkSignInStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isSignedIn = user != null;
      if (user != null) {
        currentUserUid = user.uid;
        // Cek apakah UID user ada di dalam daftar orang yang nge-like lapangan ini
        isFavorite = widget.field.likedBy.contains(user.uid);
      }
    });
  }

  // Memeriksa status Favorite secara lokal untuk sinkronisasi sekunder (opsional)
  void _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorite = prefs.getStringList('favorite') ?? [];

    // Jika user belum login, kita bisa tetap pakai data lokal
    if (!isSignedIn) {
      setState(() {
        isFavorite = favorite.contains(widget.field.name);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!isSignedIn || currentUserUid == null) {
      Navigator.pushNamed(context, '/signin');
      return;
    }

    // Ubah UI secara instan (Optimistic UI Update) agar terasa cepat di mata user
    setState(() {
      if (isFavorite) {
        widget.field.likedBy.remove(currentUserUid);
        isFavorite = false;
      } else {
        widget.field.likedBy.add(currentUserUid!);
        isFavorite = true;
      }
    });

    // Jalankan update ke Firebase di latar belakang
    final docRef = FirebaseFirestore.instance
        .collection('lapangan')
        .doc(widget.field.id);

    try {
      if (isFavorite) {
        // arrayUnion akan menambahkan data ke dalam list tanpa menduplikatnya
        await docRef.update({
          'likedBy': FieldValue.arrayUnion([currentUserUid]),
        });
      } else {
        // arrayRemove akan menghapus data spesifik dari list
        await docRef.update({
          'likedBy': FieldValue.arrayRemove([currentUserUid]),
        });
      }
    } catch (e) {
      debugPrint("Gagal update like: $e");
    }

    // Update juga ke SharedPreferences sebagai backup lokal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorite = prefs.getStringList('favorite') ?? [];
    if (isFavorite && !favorite.contains(widget.field.name)) {
      favorite.add(widget.field.name);
    } else if (!isFavorite && favorite.contains(widget.field.name)) {
      favorite.remove(widget.field.name);
    }
    await prefs.setStringList('favorite', favorite);

    widget.onFavoriteChanged?.call();
  }

  Widget _excellentPitchCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Excellent pitch',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailViewScreen(field: widget.field),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Detail Comment',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GiveRatingScreen(fieldId: widget.field.id),
                          ),
                        );
                        if (result != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailViewScreen(field: widget.field),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 243, 149, 8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 243, 149, 8),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Give a Rating',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // RIGHT
          Column(children: [_buildDynamicRating(), const SizedBox(height: 2)]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Pengecekan apakah gambar dari internet (Firebase) atau lokal (Assets)
                widget.field.image.startsWith('assets/')
                    ? Image.asset(
                        widget.field.image,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : widget.field.image.startsWith('http')
                    ? Image.network(
                        widget.field.image,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        base64Decode(widget.field.image),
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 260,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),

                // Back Button
                Positioned(
                  top: 16,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.35),
                    foregroundColor: Colors.black,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.blue,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Badge and Rating
                Transform.translate(
                  offset: const Offset(0, 180),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: _excellentPitchCard(),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.field.name,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Memapilkan total like
                      Row(
                        children: [
                          Text(
                            '${widget.field.likedBy.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode  ? Colors.white70 :Colors.grey.shade700,
                            ),
                          ),
                          IconButton(
                            iconSize: 30,
                            icon: Icon(
                              isSignedIn && isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isSignedIn && isFavorite
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () {
                              _toggleFavorite();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),

                  Text(
                    widget.field.address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 14),

                  // KOTAK KOORDINAT DAN TOMBOL MAPS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[850]
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: isDarkMode ? Border.all(color: Colors.blue.shade700) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alamat :',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lat ${widget.field.latitude}\nLng ${widget.field.longitude}',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Buka Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        widget.field.price,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 40),
                      const Icon(Icons.access_time_filled, color: Colors.red),
                      const SizedBox(width: 6),
                      Expanded(child: Text(widget.field.openHour)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(widget.field.phone),
                      const SizedBox(width: 34),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset('assets/logo-ig.png', height: 24),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          'assets/logo-tiktok.png',
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset('assets/logo-wa.png', height: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 20),

                  const Text(
                    'Description / Fasilitas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.field.facilitas
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $item'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tampilan Rtaing
  Widget _buildDynamicRating() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('fieldId', isEqualTo: widget.field.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildRatingDisplay(widget.field.rating, 0);
        }

        // hitung Rata-rata
        double total = 0;
        for (var doc in snapshot.data!.docs) {
          total += (doc.data() as Map<String, dynamic>)['rating'] ?? 0.0;
        }
        double average = total / snapshot.data!.docs.length;
        int count = snapshot.data!.docs.length;

        return _buildRatingDisplay(average, count);
      },
    );
  }

  Widget _buildRatingDisplay(double average, int count) {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Color.fromARGB(255, 243, 149, 8),
          size: 40,
        ),
        const SizedBox(width: 2),
        Text(
          average.toStringAsFixed(1),
          style: const TextStyle(
            // color: Color.fromARGB(255, 243, 149, 8),
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        const SizedBox(width: 6),
        // Text(
        //   '$count+',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ],
    );
  }
}
