import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/widgets/rating_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const ClientOrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إجراء المكالمة')),
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
  String cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

  if (cleanedPhone.startsWith('0')) {
    cleanedPhone = '962${cleanedPhone.substring(1)}';
  }

  final Uri launchUri = Uri.parse('https://wa.me/$cleanedPhone');

  try {
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تعذر فتح تطبيق الواتساب: $e')),
    );
  }
}

  Future<void> _clientCompleteOrder({
  required BuildContext context,
  required String clientId,
  required String craftsmanId,
  required String orderId,
  required String workId, 
  required double rating,
  required String review,
}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
    final clientReqRef = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(clientId)
        .collection('my_requests')
        .doc(orderId);
    final craftsmanRecRef = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(craftsmanId)
        .collection('received_orders')
        .doc(orderId);

    final orderUpdateData = {
      'is_completed': true,
      'status': 'مكتمل',
      'client_rating': rating,
      'client_review': review,
      'completed_at': FieldValue.serverTimestamp(),
    };

    batch.update(orderRef, orderUpdateData);
    batch.update(clientReqRef, orderUpdateData);
    batch.update(craftsmanRecRef, orderUpdateData);

    if (workId.isNotEmpty) {
      double currentRating=0.0;
      int currentRateCount=0;
      double newRating ; 
      int newRateCount; 
      final workRef = FirebaseFirestore.instance.collection('work').doc(workId);
      final workSnapshot = await workRef.get();
      if(workSnapshot.exists && workSnapshot.data() !=null)
      {
        currentRating = (workSnapshot.data()!['rating'] ?? 0.0).toDouble();
        
        currentRateCount = (workSnapshot.data()!['rateCount'] ?? 0).toInt();
        if(currentRateCount==0)
        {
          newRating=rating;
          newRateCount=1;
        }
        else
        {
          newRateCount=currentRateCount+1;
          newRating=(currentRating+rating)/currentRateCount;
          
        }
        batch.update(workRef, {
        'rating': newRating,  
        'rateCount': newRateCount,
      });
      }
     
    }

    await batch.commit();

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('تم إتمام الطلب وتقييم الخدمة بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء إتمام الطلب: $e'), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(currentUser.uid)
          .collection('my_requests')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب والحرفي')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب والحرفي')),
            body: const Center(child: Text('الطلب غير موجود أو تم حذفه')),
          );
        }

        final orderData = snapshot.data!.data() as Map<String, dynamic>;

        final craftsmanName = orderData['craftsmanName'] ?? 'حرفي مهني';
        final craftsmanPhone = orderData['craftsmanPhone'] ?? '';
        final serviceName = orderData['serviceName'] ?? 'خدمة عامة';
        final location = orderData['location'] ?? 'غير متوفر';
        final notes = orderData['notes'] ?? '';
        final status = orderData['status'] ?? 'قيد التنفيذ';
        final craftsmanId = orderData['craftsmanId'] ?? '';
        final bool isCompleted = status == 'مكتمل';
        final String priceType = orderData['priceType'] ?? '';
        final dynamic priceValue = orderData['price'];
        final String serviceId = orderData['serviceId'] ?? '';

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('تفاصيل الطلب والحرفي'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. بطاقة العنوان والحالة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.handyman, color: Colors.white, size: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'الحرفي',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        craftsmanName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'معلومات التواصل مع الحرفي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // 2. رقم هاتف الحرفي
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('رقم الحرفي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                craftsmanPhone.isNotEmpty ? craftsmanPhone : 'لا يوجد رقم',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'تفاصيل موقعك وملاحظاتك',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // 3. الموقع والملاحظات
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الموقع', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    location,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note_alt, color: Colors.orangeAccent, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الملاحظات', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    notes.isNotEmpty ? notes : 'لا توجد ملاحظات إضافية.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: notes.isNotEmpty ? Colors.black87 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.payments_rounded, color: Colors.green, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('السعر ونوع الاحتساب', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    priceValue != null
                                        ? '$priceValue دينار ($priceType)'
                                        : 'يُحدد بعد المعاينة (لم يُحدد بعد)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: priceValue != null ? Colors.green.shade700 : Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: craftsmanPhone.isNotEmpty
                            ? () => _makePhoneCall(craftsmanPhone, context)
                            : null,
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text('اتصال', style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: craftsmanPhone.isNotEmpty
                            ? () => _openWhatsApp(craftsmanPhone, context)
                            : null,
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text('واتساب', style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

         
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (status == 'بانتظار تأكيد العميل' && !isCompleted)
                      ? () async {
                        showModalBottomSheet(context: context,
                         isScrollControlled: true,
                         shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                         builder: (context)=>RatingBottomSheet(onSubmitRating: (double rating, String review) {
                          _clientCompleteOrder(
                            workId:serviceId ,
                context: context,
                clientId: currentUser.uid,
                craftsmanId: craftsmanId,
                orderId: orderId, 
                rating: rating,
                review: review,
                          );
                         } ));
                        
                          }
                      : null, 
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isCompleted 
                        ? 'تم تأكيد وإغلاق الطلب' 
                        : (status == 'بانتظار تأكيد العميل' 
                            ? 'تأكيد استلام العمل والدفع' 
                            : 'بانتظار إتمام العمل من الحرفي'), 
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (status == 'بانتظار تأكيد العميل' && !isCompleted)
                        ? Colors.green.shade700
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withOpacity(0.8),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}