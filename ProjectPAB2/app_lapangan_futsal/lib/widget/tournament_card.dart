import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_lapangan_futsal/models/tournament.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lapangan_futsal/screen/Register_Tournament_Screen.dart'; // Sesuaikan lokasi folder Anda
import 'package:app_lapangan_futsal/screen/admin_tournament_teams_screen.dart';

class TournamentCard extends StatelessWidget {
  final Tournament item;
  final bool isAdmin;
  final String tournamentId;

  const TournamentCard({
    super.key,
    required this.item,
    required this.isAdmin,
    required this.tournamentId,
  });

  // Fungsi hapus data firestore
  Future<void> _deleteTournament(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Turnamen'),
        content: const Text('Hapus Event Ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId)
            .delete();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.image.startsWith('assets/')
                          ? Image.asset(
                              item.image,
                              width: 130,
                              height: 170,
                              fit: BoxFit.cover,
                            )
                          : Image.memory(
                              base64Decode(item.image),
                              width: 130,
                              height: 170,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 130,
                                    height: 170,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                            ),
                    ),
                    const SizedBox(width: 12),

                    //Konten
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Chip judul
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),

                          //Harga
                          Text(
                            item.price,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),

                          //Peserta
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text("${item.joined}/${item.quota}"),
                            ],
                          ),
                          SizedBox(height: 4),

                          //Tanggal
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(item.date),
                            ],
                          ),
                          SizedBox(height: 6),

                          // Deskripsi
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                          // SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // Divider(color: Colors.grey.shade300),

                // logika Tombol Admin vs User
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isAdmin) ...[
                      // Tampilan admin tombol detail
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminTournamentTeamsScreen(
                                tournamentId: tournamentId,
                                tournamentTitle: item.title,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt, size: 18),
                        label: const Text('Detail Pendaftaran'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else ...[
                      // Tampilan User tombol daftar
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tournaments')
                            .doc(tournamentId)
                            .collection('pendaftar')
                            .doc(currentUserId)
                            .snapshots(),
                        builder: (context, subSnapshot) {
                          if (subSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          // kalau user sudah mendaftar
                          if (subSnapshot.hasData && subSnapshot.data!.exists) {
                            final regData =
                                subSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            String status = regData['status'] ?? 'menunggu';

                            if (status == 'berhasil') {
                              // tampilan1: saat Sudah di acc admin(berhasil)
                              return ElevatedButton.icon(
                                onPressed: null,
                                icon: Icon(Icons.verified, color: Colors.green),
                                label: const Text('Berhasil Mendaftar'),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor:
                                      Colors.green.shade100,
                                  disabledForegroundColor:
                                      Colors.green.shade800,
                                ),
                              );
                            } else {
                              // Tampilan 2 user : Saat status nya  masih Menunggu
                              return ElevatedButton.icon(
                                onPressed: null, // Disabled
                                icon: const Icon(
                                  Icons.hourglass_empty,
                                  color: Colors.orange,
                                ),
                                label: const Text('Status: Menunggu'),
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor:
                                      Colors.orange.shade100,
                                  disabledForegroundColor:
                                      Colors.orange.shade800,
                                ),
                              );
                            }
                          }

                          // kalau User belum mendaftar
                          return ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterTournamentScreen(
                                    tournamentId: tournamentId,
                                    tournamentTitle: item.title,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.sports_soccer, size: 18),
                            label: const Text('Daftar Turnamen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Tombol Hapus (Muncul hanya jika admin)
          if (isAdmin)
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTournament(context),
              ),
            ),
        ],
      ),
    );
  }
}
