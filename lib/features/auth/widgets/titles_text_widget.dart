import 'package:flutter/material.dart';

class TitlesTextWidget extends StatelessWidget {
  final String label;
  final double fontSize;
  const TitlesTextWidget({super.key, required this.label, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold));
  }
}
