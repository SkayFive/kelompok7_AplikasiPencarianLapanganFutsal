import 'package:flutter/material.dart';

class ProfileItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final dynamic value;
  final bool showEditIcon;
  final VoidCallback? onEditPressed;
  final Color iconColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSaved;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showEditIcon = false,
    this.onEditPressed,
    this.onChanged,
    this.onSaved,
    this.iconColor = Colors.blue,
  });

  @override
  State<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  // TODO: 1. Membuat variabel untuk edit mode
  bool isEditing = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.value ?? '';
  }

  @override
  void didUpdateWidget(covariant ProfileItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Variabel untuk Membuat tombol edit di keyboard bisa di tekan
  void finishEditing() {
    widget.onChanged?.call(controller.text);
    setState(() {
      isEditing = false;
    });
  }

  void saveValue() {
    widget.onSaved?.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label di atas (username, email, phone number)
          Text(
            widget.label,
            style: const TextStyle(fontSize: 15, color: Colors.blue),
          ),
          const SizedBox(height: 6),

          // Box Putih + shadow + isi row
          Container(
            width: double.infinity,
            // height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] :Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Row(
              children: [
                Icon(widget.icon, color: widget.iconColor, size: 22),
                // SizedBox(width: 12,),
                // const Text(':', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                const SizedBox(width: 16),

                //TODO: 2. Membuat textfield untuk edit mode
                Expanded(
                  child: isEditing
                      ? TextField(
                          controller: controller,
                          autofocus: true,
                          style: const TextStyle(fontSize: 16),
                          // textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            // contentPadding: EdgeInsets.zero
                          ),

                          // Membuat tombol centang di keyboard bisa di tekan setelah selesai edit
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            finishEditing();
                          },
                          onEditingComplete: () {
                            finishEditing();
                          },
                        )
                      : Text(
                          controller.text,
                          style: const TextStyle(
                            fontSize: 15,
                            // color: Colors.black87,
                          ),
                        ),
                ),

                // Icon Edit
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isEditing) {
                        widget.onSaved?.call(controller.text);
                        // save value
                        // kalau mau menyimpan di data  base tambhkan di sini
                      }
                      isEditing = !isEditing;
                    });
                  },
                  child: Icon(
                    isEditing ? Icons.check : Icons.edit_outlined,
                    color: widget.showEditIcon
                        ? widget.iconColor
                        : Colors.transparent,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}