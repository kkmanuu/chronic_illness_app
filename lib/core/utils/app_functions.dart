import 'package:flutter/material.dart';

class MyAppFunctions {
  static Future<void> imagePickerDialog({
    required BuildContext context,
    required Future<void> Function() cameraFCT,
    required Future<void> Function() galleryFCT,
    required Future<void> Function() removeFCT,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(onTap: cameraFCT, title: const Text('Camera'), leading: const Icon(Icons.camera)),
                ListTile(onTap: galleryFCT, title: const Text('Gallery'), leading: const Icon(Icons.photo_library)),
                ListTile(onTap: removeFCT, title: const Text('Remove'), leading: const Icon(Icons.delete)),
              ],
            ),
          ),
        );
      },
    );
  }
}
