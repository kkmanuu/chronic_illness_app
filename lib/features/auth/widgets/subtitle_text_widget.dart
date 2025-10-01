import 'package:flutter/material.dart';

class SubtitleTextWidget extends StatelessWidget {
  final String label;
  final double fontSize;
  final FontStyle fontStyle;
  final TextDecoration textDecoration;
  const SubtitleTextWidget({
    super.key,
    required this.label,
    this.fontSize = 14,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize,
        fontStyle: fontStyle,
        decoration: textDecoration,
      ),
    );
  }
}
