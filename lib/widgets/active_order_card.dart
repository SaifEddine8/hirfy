import 'package:flutter/material.dart';
import 'package:hirfy/screens/craftsman_order_details_screen.dart';

class ActiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  final String currentUserId;
  final VoidCallback? onActionPressed; 

  const ActiveOrderCard({
    Key? key,
    required this.orderData,
    required this.orderId,
    required this.currentUserId,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isStarted = orderData['is_started'] ?? false;
    final bool craftsmanConfirmed = orderData['craftsman_confirmed'] ?? false;

    String buttonText = 'البدء بالعمل';
    Color buttonColor = Colors.blue;
    IconData buttonIcon = Icons.play_arrow_rounded;

    if (craftsmanConfirmed) {
      buttonText = 'بانتظار تأكيد العميل والدفع...';
      buttonColor = Colors.grey;
      buttonIcon = Icons.hourglass_top_rounded;
    } else if (isStarted) {
      buttonText = 'إتمام العمل واستلام الدفع';
      buttonColor = Colors.green;
      buttonIcon = Icons.check_circle_outline;
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CraftsmanOrderDetailsScreen(
            orderId: orderId,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
                      color: craftsmanConfirmed
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      orderData['status'] ?? 'قيد التنفيذ',
                      style: TextStyle(
                        color: craftsmanConfirmed ? Colors.orange : Colors.blue,
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
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onActionPressed,
                  icon: Icon(buttonIcon, color: Colors.white),
                  label: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}