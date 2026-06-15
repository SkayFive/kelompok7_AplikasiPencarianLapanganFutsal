import 'dart:convert';
import 'package:app_lapangan_futsal/models/lapangan.dart';
import 'package:app_lapangan_futsal/screen/detail_screen.dart';
import 'package:flutter/material.dart';

class FieldCard extends StatelessWidget {
  final futsalField field;
  final VoidCallback? onFavoriteChanged;

  final bool isAdmin;
  final VoidCallback? onDelete;

  const FieldCard({
    super.key,
    required this.field,
    this.onFavoriteChanged,
    this.isAdmin = false,
    this.onDelete,
  });

  // Fungsi pembantu untuk memuat gambar agar kode tetap rapi
  Widget _buildFieldImage() {
    try {
      // 1. Cek apakah ini gambar bawaan dari aset lokal
      if (field.image.startsWith('assets/')) {
        return Image.asset(
          field.image,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
      // 2. Cek apakah ini gambar dari link internet (misal URL lama dari Storage)
      else if (field.image.startsWith('http')) {
        return Image.network(
          field.image,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
        );
      }
      // 3. Jika bukan keduanya, maka asumsikan ini adalah teks Base64
      else {
        return Image.memory(
          base64Decode(field.image),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
        );
      }
    } catch (e) {
      // Tangkap error jika teks bukan Base64 yang valid
      return _buildErrorImage();
    }
  }

  // Widget pengganti jika gambar gagal dimuat/error
  Widget _buildErrorImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Navigasi ke DetailScreen dengan callback
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              field: field,
              onFavoriteChanged: onFavoriteChanged,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 50),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // --- Panggil fungsi gambar yang baru ---
              _buildFieldImage(),

              // ---------------------------------------------
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${field.location} | ${field.distance}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // logika titik tiga
              if (isAdmin)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'delete') {
                          if (onDelete != null) {
                            onDelete!();
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus Lapangan',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
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