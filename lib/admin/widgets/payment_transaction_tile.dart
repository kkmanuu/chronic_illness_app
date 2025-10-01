import 'package:chronic_illness_app/core/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentTransactionTile extends StatelessWidget {
  final PaymentModel payment;
  final String username;
  final bool isActiveSubscription;
  final bool isBlocked;
  final VoidCallback onToggleBlock;

  const PaymentTransactionTile({
    super.key,
    required this.payment,
    required this.username,
    required this.isActiveSubscription,
    required this.isBlocked,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    payment.id.isNotEmpty ? 'Transaction ID: ${payment.id}' : 'User: $username',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Icon(
                  payment.status == 'SUCCESS' ? Icons.check_circle : Icons.error,
                  color: payment.status == 'SUCCESS' ? Colors.green : Colors.red,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Phone: ${payment.phoneNumber}', style: TextStyle(color: Colors.grey.shade700)),
            Text('Username: $username', style: TextStyle(color: Colors.grey.shade700)),
            Text('Amount: \$${payment.amount}', style: TextStyle(color: Colors.grey.shade700)),
            Text('Status: ${payment.status}', style: TextStyle(color: Colors.grey.shade700)),
            if (payment.mpesaReceiptNumber != null)
              Text('M-Pesa Receipt: ${payment.mpesaReceiptNumber}', style: TextStyle(color: Colors.grey.shade700)),
            if (payment.checkoutRequestId != null)
              Text('Checkout ID: ${payment.checkoutRequestId}', style: TextStyle(color: Colors.grey.shade700)),
            Text('Date: ${dateFormat.format(payment.createdAt)}', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
              'Subscription Status: ${payment.subscriptionStatus ?? 'Inactive'}',
              style: TextStyle(
                color: isActiveSubscription ? Colors.green.shade600 : Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (payment.subscriptionStartDate != null)
              Text(
                'Start Date: ${dateFormat.format(payment.subscriptionStartDate!)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            if (payment.subscriptionExpiryDate != null)
              Text(
                'Expiry Date: ${dateFormat.format(payment.subscriptionExpiryDate!)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            Text(
              'User Status: ${isBlocked ? 'Blocked' : 'Active'}',
              style: TextStyle(
                color: isBlocked ? Colors.red.shade600 : Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onToggleBlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBlocked ? Colors.green.shade600 : Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    isBlocked ? 'Unblock User' : 'Block User',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
