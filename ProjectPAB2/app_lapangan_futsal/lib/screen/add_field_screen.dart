import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; <-- HAPUS INI

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _priceController = TextEditingController();
  final _openHourController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facilitasController = TextEditingController();

  String? _base64Image; // Ubah menjadi String untuk menyimpan Base64
  Position? _currentPosition;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // 1. Fungsi pick, Compress, and Convert Image ke Base64 (Logika ZooJourney)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      // Ubah gambar jadi format bytes lalu ke teks Base64
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  // Fungsi mendapatkan titik koordinat GPS
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isLoading = true;
    });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap aktifkan GPS / Lokasi perangkat Anda.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen, atur di pengaturan HP.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lokasi berhasil didapatkan!')),
    );
  }

  // 2. Fungsi menyimpan data langsung ke Firestore tanpa Storage
  Future<void> _saveField() async {
    if (!_formKey.currentState!.validate()) return;
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih foto lapangan!')),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap dapatkan lokasi (GPS) terlebih dahulu!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> fasilitasArray = _facilitasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Langsung simpan ke Firestore, sangat cepat!
      await FirebaseFirestore.instance.collection('lapangan').add({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'location': _locationController.text.trim(),
        'distance': _distanceController.text.trim(),
        'price': _priceController.text.trim(),
        'openHour': _openHourController.text.trim(),
        'phone': _phoneController.text.trim(),
        'facilitas': fasilitasArray,
        'image': _base64Image, // Kirim teks Base64 langsung
        'rating': 0.0,
        'reviews': 0,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _distanceController.dispose();
    _priceController.dispose();
    _openHourController.dispose();
    _phoneController.dispose();
    _facilitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Lapangan')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan data...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gambar menggunakan Image.memory
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850] :Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _base64Image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(
                                    _base64Image!,
                                  ), // Decode untuk ditampilkan
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    'Tap untuk tambah foto',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lokasi GPS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] :Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentPosition != null
                                  ? 'Lat: ${_currentPosition!.latitude}\nLng: ${_currentPosition!.longitude}'
                                  : 'Lokasi GPS belum didapatkan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Ambil Lokasi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Nama Lapangan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _addressController,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Alamat Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _locationController,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Area (Contoh: Ilir Timur)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: _distanceController,
                    //         decoration: InputDecoration(
                    //           hintText: 'Jarak (Misal: 2.5 km)',
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //             borderSide: BorderSide(color: Colors.blue),
                    //           ),
                    //         ),
                    //         validator: (value) =>
                    //             value!.isEmpty ? 'Wajib diisi' : null,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),

                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: _priceController,
                    //         decoration: const InputDecoration(
                    //           labelText: 'Harga/Jam (Misal: Rp 150.000)',
                    //           border: OutlineInputBorder(),
                    //         ),
                    //         validator: (value) =>
                    //             value!.isEmpty ? 'Wajib diisi' : null,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Harga/Jam (Misal: Rp 150.000)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _openHourController,
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              hintText: 'Jam Buka (Misal: 08:00 - 23:00)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'No. Telepon',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _facilitasController,
                      cursorColor: Colors.blue,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Fasilitas (Pisahkan dengan koma)',
                        hintText: 'Contoh: Toilet, Parkir Luas, Kantin...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      onPressed: _saveField,
                      child: const Text(
                        'Simpan Lapangan',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }
}
