import 'package:app_lapangan_futsal/models/tournament.dart';
import 'package:app_lapangan_futsal/widget/tournament_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lapangan_futsal/screen/add_event_screen.dart';

class TournamentScreen extends StatefulWidget {
  TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  // Fungsi pengecekan admin
  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          isAdmin = data['role'] == 'admin';
        });
      }
    }
  }
  // final List<Tournament> tournament = [
  //   Tournament(
  //     title: 'Roxwood Tournament',
  //     image: 'assets/tournament_empat.jpg',
  //     price: 'Rp 150.000',
  //     joined: 10,
  //     quota: 100,
  //     date: 'Monday, 3 Nov 2025',
  //     description: 'Turnamen futsal dengan atmosfer kompetitif dan seru.',
  //   ),

  //   Tournament(
  //     title: '2025 Tournament',
  //     image: 'assets/tournament_lima.jpg',
  //     price: 'Rp 100.000',
  //     joined: 20,
  //     quota: 100,
  //     date: 'Sunday, 2 Nov 2025',
  //     description: 'Bertanding dengan semangat, pemenangnya siapa?',
  //   ),

  //   Tournament(
  //     title: 'Tournament dunia',
  //     image: 'assets/tournament_satu.jpg',
  //     price: 'Rp 50.000',
  //     joined: 44,
  //     quota: 55,
  //     date: 'Saturday, 15 Nov 2025',
  //     description:
  //         'Tantangan futsal malam hari dengan atmosfer penuh adrenalin.',
  //   ),

  //   Tournament(
  //     title: 'Tournament laLiga',
  //     image: 'assets/tournament_dua.jpg',
  //     price: 'Rp 80.000',
  //     joined: 22,
  //     quota: 44,
  //     date: 'Friday, 21 Nov 2025',
  //     description: 'Ajang unjuk skill futsal antar mahasiswa se-kota.',
  //   ),

  //   Tournament(
  //     title: 'Tournament Champion Cup',
  //     image: 'assets/tournament_tiga.jpg',
  //     price: 'Rp 90.000',
  //     joined: 44,
  //     quota: 88,
  //     date: 'Friday, 7 Nov 2025',
  //     description: 'Satu lapangan, banyak ambisi. Buktikan kemampuanmu!',
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event'), automaticallyImplyLeading: false),

      // backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tournaments')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Belum ada turnamen tersedia"));
            }

            // Ubah data Firestore menjadi list Tournament
            final tournamentDocs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tournamentDocs.length,
              itemBuilder: (context, index) {
                final doc = tournamentDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                // Mapping data Firestore ke Model Tournament
                final item = Tournament(
                  title: data['title'] ?? '',
                  image: data['image'] ?? '',
                  price: data['price'] ?? '',
                  joined: data['joined'] ?? 0,
                  quota: data['quota'] ?? 0,
                  date: data['date'] ?? '',
                  description: data['description'] ?? '',
                );
                return TournamentCard(
                  item: item,
                  isAdmin: isAdmin,
                  tournamentId: doc.id,
                );
              },
            );
          },
        ),
      ),

      // Tombol Tambah hanya muncul jika isAdmin == true
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTournamentScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}
