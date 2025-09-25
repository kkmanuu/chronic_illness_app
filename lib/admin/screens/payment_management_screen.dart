import 'package:chronic_illness_app/admin/widgets/payment_transaction_tile.dart';
import 'package:chronic_illness_app/core/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  _PaymentManagementScreenState createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Function to block or unblock a user
  Future<void> _toggleUserBlock(String uid, bool currentBlockStatus) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data()!['role'] == 'admin') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User not found or is an admin'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }

      final newBlockStatus = !currentBlockStatus;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'isBlocked': newBlockStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newBlockStatus ? 'User blocked successfully' : 'User unblocked successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user status: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by username, phone, or ID',
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isNotEqualTo: 'admin')
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: TextStyle(color: Colors.red.shade600, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }
              if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              final users = userSnapshot.data!.docs.where((user) {
                final data = user.data() as Map<String, dynamic>;
                final username = (data['username'] ?? '').toString().toLowerCase();
                final phone = (data['phoneNumber']?.toString() ?? '').toLowerCase();
                final userId = user.id.toLowerCase();
                return username.contains(_searchQuery) || phone.contains(_searchQuery) || userId.contains(_searchQuery);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userData = user.data() as Map<String, dynamic>;
                  final uid = user.id;
                  final username = userData['username'] ?? 'Unknown';
                  final phoneNumber = userData['phoneNumber']?.toString() ?? '';
                  final isBlocked = userData['isBlocked'] ?? false;
                  final role = userData['role'] ?? 'user';

                  PaymentModel? payment;
                  final lastPayment = userData['lastPayment'] as Map<String, dynamic>?;
                  if (lastPayment != null) {
                    payment = PaymentModel.fromMap({
                      ...lastPayment,
                      'premiumExpiry': userData['premiumExpiry'],
                      'premiumUpdatedAt': userData['premiumUpdatedAt'],
                      'role': role,
                    }, docId: lastPayment['merchantRequestId'] ?? '');
                  } else {
                    payment = PaymentModel(
                      id: '',
                      phoneNumber: phoneNumber,
                      amount: '0',
                      status: 'No Payment',
                      transactionDesc: 'No transaction yet',
                      createdAt: DateTime.now(),
                      subscriptionStatus: 'Inactive',
                    );
                  }

                  final isActiveSubscription = payment.subscriptionStatus == 'Active' &&
                      payment.subscriptionExpiryDate != null &&
                      payment.subscriptionExpiryDate!.isAfter(DateTime.now());

                  return PaymentTransactionTile(
                    payment: payment,
                    username: username,
                    isActiveSubscription: isActiveSubscription,
                    isBlocked: isBlocked,
                    onToggleBlock: () => _toggleUserBlock(uid, isBlocked),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
