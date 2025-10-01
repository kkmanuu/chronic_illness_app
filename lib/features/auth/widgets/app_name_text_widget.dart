import 'package:flutter/material.dart';

class AppNameTextWidget extends StatelessWidget {
  final double fontSize;
  const AppNameTextWidget({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Chronic Illness App',  // Update with actual app name
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
