import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/features/profile/screens/widgets/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget buildAvatar(
  BuildContext context,
  String? profileImageUrl,
  VoidCallback pickProfileImage,
) {
  return GestureDetector(
    onTap: pickProfileImage,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
              child: ClipOval(
                child: profileImageUrl != null
                    ? Image.network(
                        '$profileImageUrl?cache=${DateTime.now().millisecondsSinceEpoch}', // Cache-busting
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => buildInitialAvatar(context),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                            strokeWidth: 2,
                          );
                        },
                      )
                    : buildInitialAvatar(context),
              ),
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
  VoidCallback onEditPressed,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('Name', authProvider.user!.username),
      const SizedBox(height: 20),
      _buildInfoRow('Email', authProvider.user!.email ?? 'Not set'),
      const SizedBox(height: 20),
      _buildInfoRow('Member Since', DateFormat('MMMM yyyy').format(
        authProvider.user!.createdAt ?? DateTime.now())),
      const SizedBox(height: 20),
      _buildInfoRow('Account Type', authProvider.user!.role == 'premium' 
          ? 'Premium Member' 
          : 'Free Member'),
      if (authProvider.user!.role == 'premium' && authProvider.user!.premiumExpiry != null) ...[
        const SizedBox(height: 20),
        _buildInfoRow('Premium Expires', DateFormat('MMM dd, yyyy').format(
          authProvider.user!.premiumExpiry!.toDate())),
      ],
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onEditPressed,
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
  VoidCallback onCancel,
) {
  return ProfileForm(
    initialName: authProvider.user!.username,
    initialNotificationsEnabled: authProvider.user!.notificationsEnabled,
    onSave: (name, notificationsEnabled) async {
      try {
        await authProvider.updateProfile(
          name,
          notificationsEnabled,
          profileImageUrl: authProvider.user!.profileImageUrl, // Preserve existing profileImageUrl
        );
        onCancel(); // Close edit mode
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
    setStateCallback: onCancel,
  );
}
