import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_team_detail_screen.dart';

class AdminTournamentTeamsScreen extends StatelessWidget {
  final String tournamentId;
  final String tournamentTitle;

  const AdminTournamentTeamsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pendaftar: $tournamentTitle')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId)
            .collection('pendaftar')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada tim yang mendaftar.'));
          }
          final pendaftaDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendaftaDocs.length,
            itemBuilder: (context, index) {
              final doc = pendaftaDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              String namaTim = data['nama_tim'] ?? 'Tanpa Nama Tim';
              String status = data['status'] ?? "menunggu";
              int totalPemain = data['total_pemain'] ?? 5;

              Color statusColor = status == 'berhasil'
                  ? Colors.green
                  : Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.shield, color: Colors.blue),
                  ),
                  title: Text(
                    namaTim,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Total Pemain: $totalPemain Orang'),
                      const SizedBox(height: 6),
                      // Badge Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminTeamDetailScreen(
                          tournamentId: tournamentId,
                          userId: doc.id,
                          registrationData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
