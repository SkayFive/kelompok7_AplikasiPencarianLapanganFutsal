import 'package:flutter/material.dart';
import 'package:app_lapangan_futsal/widget/profile_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String? imagePath;
  final Uint8List? webImage;

  const ProfilePage({
    super.key,
    required this.username,
    required this.email,
    this.imagePath,
    this.webImage,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //TODO: 1. Deklarasi variabel
  String username = '';
  String email = '';
  String phoneNumber = '';
  File? _profileImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  // Mendapatkan instance user yang sedang login
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Set nilai awal dari parameter
    username = widget.username;
    email = widget.email;

    if (widget.webImage != null) {
      _webImage = widget.webImage;
    } else if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      _profileImage = File(widget.imagePath!);
    }

    // tarik data dari firestore saat halaman dimuat
    _loadUserData();
  }

  // Membuat Action ketika icon edit ditekan
  Future<void> editField({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) async {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text); // Simpan text baru ke state
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // fungsi untuk mengambil inisial dari username
  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      return name.length > 1
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
  }

  // Tarik data profile dari cloud firestore
  Future<void> _loadUserData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Menggunakan 'users' huruf kecil
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            username = data['username'] ?? widget.username;
            email = data['email'] ?? widget.email;
            phoneNumber = data['phone'] ?? '';

            String? imagePath = data['profile_image_local_path'];
            if (imagePath != null && imagePath.isNotEmpty) {
              _profileImage = File(imagePath);
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    }
  }

  //Fungsi untuk memilih Foto
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      if (kIsWeb) {
        var bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _profileImage = null;
        });
      } else {
        setState(() {
          _profileImage = File(image.path);
          _webImage = null;
        });
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Pengaturan Profile',
              style: TextStyle(color: isDarkMode ? Colors.blue : Colors.white),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(width: double.infinity),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // TODO: 2. Membuat profile Header Yang berisi foto profile
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: isDarkMode
                                  ? Colors.blue.shade50
                                  : Colors.grey[200],
                              backgroundImage: _webImage != null
                                  ? MemoryImage(_webImage!) as ImageProvider
                                  : (_profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null),
                              child:
                                  (_webImage == null && _profileImage == null)
                                  ? Text(
                                      _getInitials(username),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: _showImageSourcePicker,
                            icon: Icon(
                              Icons.camera_alt,
                              size: 28,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TODO: 3. Membuat informasi profile
                  const SizedBox(height: 16),

                  ProfileItem(
                    icon: Icons.person,
                    label: 'Username',
                    value: username,
                    showEditIcon: true,
                    iconColor: Colors.blue.shade300,
                    // Memanggil fungsi dialog edit saat ditekan
                    onSaved: (newValue) {
                      setState(() {
                        username = newValue;
                      });
                    },
                    // onEditPressed: () {
                    //   editField(
                    //     title: 'Username',
                    //     currentValue: username,
                    //     onSave: (newValue) {
                    //       setState(() {
                    //         username = newValue;
                    //       });
                    //     },
                    //   );
                    // },
                  ),

                  const SizedBox(height: 4),
                  ProfileItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: email,
                    showEditIcon: true,
                    iconColor: Colors.blue.shade300,
                    onEditPressed: () {
                      editField(
                        title: 'Email',
                        currentValue: email,
                        onSave: (newValue) {
                          setState(() {
                            email = newValue;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 6),
                  ProfileItem(
                    icon: Icons.phone,
                    label: 'Contact',
                    value: phoneNumber,
                    showEditIcon: true,
                    iconColor: Colors.blue.shade300,
                    onEditPressed: () {
                      editField(
                        title: 'Contact',
                        currentValue: phoneNumber,
                        onSave: (newValue) {
                          setState(() {
                            phoneNumber = newValue;
                          });
                        },
                      );
                    },
                  ),

                  // TODO: 4. Membuat tombol Save Changes
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (currentUser != null) {
                          try {
                            // Gunakan 'users'
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser!.uid)
                                .update({
                                  'username': username,
                                  'email': email,
                                  'phone': phoneNumber,
                                  if (!kIsWeb && _profileImage != null)
                                    'profile_image_local_path':
                                        _profileImage!.path,
                                });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile berhasil diperbarui'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, {
                                'phone': phoneNumber,
                                'username': username,
                                'email': email,
                                'image': _profileImage?.path,
                                'webImage': _webImage,
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal Menyimpan: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// Membuat Action ketika icon edit ditekan diletakan di bawah todo 1
  // Future<void> editField({
  //   required String title,
  //   required String currentValue,
  //   required Function(String) onSave,
  // }) async {
  //   TextEditingController controller = TextEditingController(
  //     text: currentValue,
  //   );

  //   await showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: Text("Edit $title"),
  //       content: TextField(
  //         controller: controller,
  //         // decoration: InputDecoration(
  //         //   labelText: title,
  //         //   border: OutlineInputBorder(),
  //         // ),
  //       ),
  //       // Tombol Save dan Cancel
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel"),
  //         ),

  //         ElevatedButton(
  //           onPressed: () {
  //             onSave(controller.text);
  //             Navigator.pop(context);
  //           },
  //           child: const Text("Save"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
