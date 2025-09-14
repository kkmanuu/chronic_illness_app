import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final String userId;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const UserTile({
    super.key,
    required this.user,
    required this.userId,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    // Safely handle isActive, default to false if null
    bool isActive = user['isActive'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user['username'] ?? 'Unknown'),
        subtitle: Text(user['email'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                isActive ? Icons.block : Icons.check_circle,
                color: isActive ? Colors.red : Colors.green,
              ),
              onPressed: onToggleActive,
            ),
          ],
        ),
      ),
    );
  }
}