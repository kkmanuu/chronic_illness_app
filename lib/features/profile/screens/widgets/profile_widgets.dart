import 'dart:io';
import 'package:chronic_illness_app/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:intl/intl.dart';

Widget buildAvatar(
  BuildContext context,
  File? selectedImage,
  String? profileImageUrl,
  VoidCallback pickProfileImage,
) {
  Widget avatarContent;
  if (selectedImage != null) {
    avatarContent = ClipOval(
      child: Image.file(
        selectedImage,
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildInitialAvatar(context),
      ),
    );
  } else if (profileImageUrl != null) {
    avatarContent = ClipOval(
      child: Image.network(
        profileImageUrl,
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildInitialAvatar(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return buildInitialAvatar(context);
        },
      ),
    );
  } else {
    avatarContent = buildInitialAvatar(context);
  }

  return GestureDetector(
    onTap: pickProfileImage,
    child: Container(
      decoration: BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ).let((shadow) => BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [shadow],
          )),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
              child: avatarContent,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildInitialAvatar(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  return Text(
    authProvider.user!.username[0].toUpperCase(),
    style: const TextStyle(
      fontSize: 32,
      color: Color(0xFF4CAF50),
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildProfileCard(
  BuildContext context, {
  String? title,
  IconData? icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    ),
  );
}

Widget buildSettingsTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
  Widget? trailing,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.grey.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey[600], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded, color: Colors.grey[400])
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    ),
  );
}

Widget buildTransactionTile(
  BuildContext context, {
  required String amount,
  required String date,
  required String status,
  required bool isSuccess,
  required bool isPending,
  String? receipt,
}) {
  IconData statusIcon;
  Color statusColor;
  String statusText;

  if (isSuccess) {
    statusIcon = Icons.check_circle;
    statusColor = const Color(0xFF4CAF50);
    statusText = 'Successful';
  } else if (isPending) {
    statusIcon = Icons.hourglass_empty;
    statusColor = Colors.orange;
    statusText = 'Processing';
  } else {
    statusIcon = Icons.error_outline;
    statusColor = Colors.red;
    statusText = 'Failed';
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: statusColor.withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'KES $amount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (receipt != null && receipt.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Receipt: $receipt',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileInfo(
  BuildContext context,
  AuthProvider authProvider,
  StateSetter setState,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('Name', authProvider.user!.username),
      const SizedBox(height: 16),
      _buildInfoRow('Email', authProvider.user!.email ?? 'Not set'),
      const SizedBox(height: 16),
      _buildInfoRow('Member Since', DateFormat('MMMM yyyy').format(
        authProvider.user!.createdAt ?? DateTime.now())),
      const SizedBox(height: 16),
      _buildInfoRow('Account Type', authProvider.user!.role == 'premium' 
          ? 'Premium Member' 
          : 'Free Member'),
      if (authProvider.user!.role == 'premium' && authProvider.user!.premiumExpiry != null) ...[
        const SizedBox(height: 16),
        _buildInfoRow('Premium Expires', DateFormat('MMM dd, yyyy').format(
          authProvider.user!.premiumExpiry!.toDate())),
      ],
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              // Assuming _isEditingProfile is managed in the parent state
            });
          },
          icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            side: const BorderSide(color: Color(0xFF4CAF50)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    ],
  );
}

Widget _buildInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Widget buildEditProfileForm(
  BuildContext context,
  AuthProvider authProvider,
  bool isEditingProfile,
  StateSetter parentSetState,
) {
  final nameController = TextEditingController(text: authProvider.user!.username);
  final emailController = TextEditingController(text: authProvider.user!.email ?? '');
  bool notificationsEnabled = authProvider.user!.notificationsEnabled;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    parentSetState(() {
                      // Assuming _isEditingProfile is managed in the parent state
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Name cannot be empty'),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await authProvider.updateProfile(
                        nameController.text.trim(),
                        notificationsEnabled,
                      );

                      parentSetState(() {
                        // Assuming _isEditingProfile is managed in the parent state
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Profile updated successfully'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF4CAF50),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Error updating profile: $e')),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}