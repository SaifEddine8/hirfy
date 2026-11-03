import 'package:flutter/material.dart';

class ReceivedOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  final String currentUserId;
  final Function(bool isAccepted) onActionPressed;

  const ReceivedOrderCard({
    Key? key,
    required this.orderData,
    required this.orderId,
    required this.currentUserId,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderData['clientName'] ?? 'مستخدم',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'قيد الانتظار',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الموقع: ${orderData['location'] ?? 'غير متوفر'}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'الهاتف: ${orderData['clientPhone'] ?? 'غير متوفر'}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (orderData['notes'] != null &&
                orderData['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_alt_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الملاحظات: ${orderData['notes']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onActionPressed(false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('رفض',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onActionPressed(true), 
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('قبول',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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