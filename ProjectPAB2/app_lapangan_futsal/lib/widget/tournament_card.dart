import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_lapangan_futsal/models/tournament.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.image.startsWith('assets/')
                      ? Image.asset(
                          item.image,
                          width: 145,
                          height: 185,
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          base64Decode(item.image),
                          width: 145,
                          height: 185,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 145,
                                height: 185,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                ),
                SizedBox(width: 12),

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
                          const Icon(Icons.people, size: 16, color: Colors.red),
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
                      SizedBox(width: 20),
                    ],
                  ),
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
