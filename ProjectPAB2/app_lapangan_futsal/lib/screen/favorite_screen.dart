import 'package:app_lapangan_futsal/models/lapangan.dart';
import 'package:app_lapangan_futsal/widget/field_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  List<futsalField> favoriteFields = [];
  bool isLoading = true;

  // Fungsi mengambil data lapangan favorit dari Firestore
  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Jika user belum login, kosongkan list dan hentikan fungsi
      if (user == null) {
        setState(() {
          favoriteFields = [];
          isLoading = false;
        });
        return;
      }

      // Query ke Firestore: Cari dokumen lapangan yang UID usernya ada di dalam list 'likedBy'
      final snapshot = await FirebaseFirestore.instance
          .collection('lapangan')
          .where('likedBy', arrayContains: user.uid)
          .get();

      // Mapping data mentah dari Firestore menjadi List<futsalField>
      final loadedFields = snapshot.docs.map((doc) {
        final data = doc.data();

        return futsalField(
          id: doc.id, // Ambil ID dokumen asli
          name: data['name'] ?? 'Tanpa Nama',
          address: data['address'] ?? 'Alamat tidak diketahui',
          location: data['location'] ?? 'Lokasi tidak diketahui',
          image: data['image'] ?? 'assets/lapangan1.jpg',
          distance: data['distance'] ?? '0 km',
          rating: (data['rating'] ?? 0.0).toDouble(),
          reviews: data['reviews'] ?? 0,
          price: data['price'] ?? 'Rp 0',
          openHour: data['openHour'] ?? 'Buka: -',
          phone: data['phone'] ?? 'Tidak ada nomor',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          likedBy: data['likedBy'] != null
              ? List<String>.from(data['likedBy'])
              : [],
          facilitas: data['facilitas'] != null
              ? List<String>.from(data['facilitas'])
              : [],
        );
      }).toList();

      setState(() {
        favoriteFields = loadedFields;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data favorit: $e");
    } finally {
      // Pastikan loading berhenti meskipun berhasil atau gagal
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Favorite',
          style: TextStyle(color:isDarkMode ? Colors.blue : Colors.white),
        ),
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteFields.isEmpty
          ? const Center(child: Text('Belum Ada lapangan yang di suka'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteFields.length,
              itemBuilder: (context, index) {
                final field = favoriteFields[index];
                return FieldCard(
                  field: field,
                  // Callback ketika status favorite berubah
                  onFavoriteChanged: () {
                    loadFavorites(); // reload favoriteFields secara realtime
                  },
                );
              },
            ),
    );
  }
}
