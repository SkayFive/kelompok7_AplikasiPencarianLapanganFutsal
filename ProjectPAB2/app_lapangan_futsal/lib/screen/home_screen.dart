import 'package:app_lapangan_futsal/models/lapangan.dart';
import 'package:app_lapangan_futsal/screen/nontifikasi_screen.dart';
import 'package:app_lapangan_futsal/widget/field_card.dart';
import 'package:app_lapangan_futsal/screen/add_field_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_lapangan_futsal/screen/favorite_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<FavoriteScreenState> favoriteKey;
  const HomeScreen({super.key, required this.favoriteKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Variabel untuk menyimpan query pencarian
  String searchQuery = '';
  // Variabel untuk mengecek apakah user adalah admin
  bool isAdmin = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  // Fungsi untuk mengecek email yang sedang login
  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Tarik dokumen user yang sedang login dari koleksi 'users'
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userName = data['username'] ?? 'User';
          });

          // Cek apakah field 'role' ada dan bernilai 'admin'
          if (data['role'] == 'admin') {
            setState(() {
              isAdmin = true;
            });
          } else {
            setState(() {
              isAdmin = false;
            });
          }
        }
      } catch (e) {
        debugPrint("Gagal mengecek role admin: $e");
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi pembantu untuk memformat tanggal hari ini
  String _getFormattedDate() {
    final DateTime now = DateTime.now();
    // Menghasilkan format seperti "Fri, 11 March"
    return DateFormat('EEE, d MMMM').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(),
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),

                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseAuth.instance.currentUser != null
                            ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          // Default nama jika sedang loading atau data kosong
                          String displayName = 'User';

                          // Jika data berhasil ditarik dari database
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            displayName = data['username'] ?? 'User';
                          }

                          return Text(
                            'Hallo $displayName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationDemo()),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              //Search
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Find the nearst field location',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  // fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Title
              Text(
                'Last field viewed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              //List Lapangan
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('lapangan')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Terjadi kesalahan data.'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final location = (data['location'] ?? '')
                          .toString()
                          .toLowerCase();

                      return name.contains(searchQuery) ||
                          location.contains(searchQuery);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Lapangan tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final currentDoc = filteredDocs[index];
                        final data = currentDoc.data() as Map<String, dynamic>;

                        final field = futsalField(
                          id: currentDoc.id,
                          name: data['name'] ?? 'Tanpa Nama',
                          address: data['address'] ?? 'Alamat tidak diketahui',
                          location:
                              data['location'] ?? 'Lokasi tidak diketahui',
                          image:
                              data['image'] ??
                              'assets/lapangan1.jpg', // Gunakan gambar default/placeholder jika kosong
                          distance: data['distance'] ?? '0 km',

                          // Pastikan tipe data angka di-convert dengan benar
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

                          // pastikan bentuk nya list
                          facilitas: data['facilitas'] != null
                              ? List<String>.from(data['facilitas'])
                              : [],
                        );

                        return FieldCard(
                          field: field,
                          isAdmin: isAdmin,
                          onDelete: () async {
                            // konfirmasi dialog
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Lapangan'),
                                content: Text('Hapus ${field.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            // Klau admin menekan tombol hapus
                            if (confirm == true) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('lapangan')
                                    .doc(field.id)
                                    .delete();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Lapangan berhasil dihapus',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menghapus: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          onFavoriteChanged: () {
                            widget.favoriteKey.currentState?.loadFavorites();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddFieldScreen()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}
