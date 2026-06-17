import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTeamDetailScreen extends StatefulWidget {
  final String tournamentId;
  final String userId;
  final Map<String, dynamic> registrationData;

  const AdminTeamDetailScreen({
    super.key,
    required this.tournamentId,
    required this.userId,
    required this.registrationData,
  });

  @override
  State<AdminTeamDetailScreen> createState() => _AdminTeamDetailScreenState();
}

class _AdminTeamDetailScreenState extends State<AdminTeamDetailScreen> {
  bool _isLoading = false;

  // Fungsi mengonfirmasi pendaftaran
  Future<void> _confirmRegistration() async {
    setState(() => _isLoading = true);
    try {
      // 1. Update status pendaftaran menjadi 'berhasil'
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(widget.tournamentId)
          .collection('pendaftar')
          .doc(widget.userId)
          .update({'status': 'berhasil'});

      // 2. Otomatis menambah jumlah tim yang bergabung ('joined') di dokumen turnamen utama
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(widget.tournamentId)
          .update({'joined': FieldValue.increment(1)});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil dikonfirmasi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke list pendaftar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal konfirmasi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.registrationData;
    String status = data['status'] ?? 'menunggu';

    return Scaffold(
      appBar: AppBar(title: Text(data['nama_tim'] ?? 'Detail Tim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Detail Anggota Tim
            const Text('Struktur Anggota Tim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pemain Inti:'),
                        Text('${data['pemain_inti'] ?? 5} Pemain', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pemain Cadangan:'),
                        Text('${data['pemain_cadangan'] ?? 0} Pemain', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Terdaftar:', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        Text('${data['total_pemain'] ?? 5} / 14 Maks', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email Pendaftar
            const Text('Kontak Penanggung Jawab', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${data['user_email'] ?? '-'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            // Bukti Pembayaran
            const Text('Foto Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: data['bukti_pembayaran'] != null && data['bukti_pembayaran'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.memory(
                        base64Decode(data['bukti_pembayaran']),
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Center(child: Text('Bukti pembayaran tidak ditemukan')),
            ),
            const SizedBox(height: 32),

            // Tombol Konfirmasi Pembayaran (Hanya muncul jika status masih 'menunggu')
            if (status == 'menunggu')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Konfirmasi & Terima Tim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _confirmRegistration,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Tim Ini Sudah Berhasil Terdaftar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}