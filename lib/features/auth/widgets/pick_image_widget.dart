import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImageWidget extends StatelessWidget {
  final XFile? pickedImage;
  final VoidCallback function;
  const PickImageWidget({super.key, this.pickedImage, required this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: pickedImage != null ? FileImage(File(pickedImage!.path)) : null,
        child: pickedImage == null ? const Icon(Icons.add_photo_alternate, size: 50) : null,
      ),
    );
  }
}
