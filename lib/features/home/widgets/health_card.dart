import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? timestamp;
  final Widget? icon;
  final Color? backgroundColor;

  const HealthCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: ListTile(
        leading: icon,
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(
          subtitle + (timestamp != null ? '\n${timestamp!.toString().substring(0, 16)}' : ''),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
