
import 'package:flutter/material.dart';

class PaymentTransactionTile extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentTransactionTile({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Transaction ID: ${payment['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${payment['userId']}'),
            Text('Amount: \$${payment['amount'].toStringAsFixed(2)}'),
            Text('Status: ${payment['status']}'),
            Text('Date: ${payment['date']}'),
          ],
        ),
        trailing: Icon(
          payment['status'] == 'Completed' ? Icons.check_circle : Icons.error,
          color: payment['status'] == 'Completed' ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}