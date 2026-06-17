import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterTournamentScreen extends StatefulWidget {
  final String tournamentId;
  final String tournamentTitle;

  const RegisterTournamentScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentTitle,
  });

  @override
  State<RegisterTournamentScreen> createState() =>
      _RegisterTournamentScreenState();
}

class _RegisterTournamentScreenState extends State<RegisterTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _cadanganController = TextEditingController();

  int _pemainInti = 5;
  int _totalPemain = 5;

  File? _imageFile;
  Uint8List? _webImage;
  String _base64Image = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    _cadanganController.dispose();
    super.dispose();
  }

  // Fungsi menghitung total pemain setiap kali input cadangan berubah
  void _calculateTotal(String value) {
    int cadangan = int.tryParse(value) ?? 0;
    // Maksimal cadangan futsal biasanya 9 (total 14 pemain)
    if (cadangan > 9) {
      cadangan = 9;
      _cadanganController.text = '9';
      _cadanganController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cadanganController.text.length),
      );
    }
    setState(() {
      _totalPemain = _pemainInti + cadangan;
    });
  }

  // Fungsi Pilih Bukti Pembayaran
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      var bytes = await image.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
        if (kIsWeb) {
          _webImage = bytes;
        } else {
          _imageFile = File(image.path);
        }
      });
    }
  }

  // Fungsi Simpan FireStore
  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah bukti pembayaran!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Menyimpan ke Sub-collection 'pendaftar' di dalam dokumen turnamen
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentId)
            .collection('pendaftar')
            .doc(user.uid)
            .set({
              'nama_tim': _teamNameController.text,
              'pemain_inti': _pemainInti,
              'pemain_cadangan': int.tryParse(_cadanganController.text) ?? 0,
              'total_pemain': _totalPemain,
              'bukti_pembayaran': _base64Image,
              'status': 'menunggu', // Status awal, nanti akan diubah admin
              'timestamp': FieldValue.serverTimestamp(),
              'user_id': user.uid,
              'user_email': user.email,
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil mendaftar! Menunggu konfirmasi admin.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dafatr Tournament')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turnamen: ${widget.tournamentTitle}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Input nama Tim
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  hintText: 'Nama Team',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.shield),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tim wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Info Pemain Inti (Fixed)
              TextFormField(
                initialValue: '5',
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Pemain Inti (Wajib)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Input Pemain Cadangan
              TextFormField(
                controller: _cadanganController,
                keyboardType: TextInputType.number,
                onChanged: _calculateTotal,
                decoration: InputDecoration(
                  labelText: 'Jumlah Pemain Cadangan (Maks 9)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.people_outline),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    int? val = int.tryParse(value);
                    if (val == null || val < 0 || val > 9) {
                      return 'Masukkan angka valid (0 - 9)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Pemain
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Total Pemain yang didaftarkan: $_totalPemain',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upload Bukti Pembayaran
              const Text(
                'Bukti Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _base64Image.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Klik untuk unggah struk transfer',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : (kIsWeb
                            ? Image.memory(_webImage!, fit: BoxFit.contain)
                            : Image.file(_imageFile!, fit: BoxFit.contain)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitRegistration,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kirim Pendaftaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
