import 'package:flutter/material.dart';

class ClientRequestCard extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final VoidCallback onTap;

  const ClientRequestCard({
    Key? key,
    required this.requestData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serviceName = requestData['serviceName'] ?? 'خدمة عامة';
    final craftsmanName = requestData['craftsmanName'] ?? 'حرفي مهني';
    final craftsmanPhone = requestData['craftsmanPhone'] ?? 'غير متوفر';
    final location = requestData['location'] ?? 'غير متوفر';
    final status = requestData['status'] ?? 'قيد التنفيذ';

    Color badgeColor = Colors.blue;
    if (status == 'بانتظار تأكيد العميل') {
      badgeColor = Colors.orange;
    } else if (status == 'مكتمل') {
      badgeColor = Colors.green;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
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
                    Expanded(
                      child: Text(
                        craftsmanName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: badgeColor,
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
                    const Icon(Icons.handyman_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'الخدمة: $serviceName',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
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
                      'الهاتف: $craftsmanPhone',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
      
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الموقع: $location',
                        style: const TextStyle(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}