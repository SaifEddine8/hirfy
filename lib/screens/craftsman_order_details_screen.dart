import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/widgets/price_input_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class CraftsmanOrderDetailsScreen extends StatelessWidget {
  final String orderId; 

  const CraftsmanOrderDetailsScreen({
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

  Future<void> _startWorkingOrder(BuildContext context, String craftsmanId, String clientId, String currentOrderId,{double? inspectedPrice}) async {
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance.collection('orders').doc(currentOrderId);
      final clientReqRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(clientId)
          .collection('my_requests')
          .doc(currentOrderId);
      final craftsmanRecRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(craftsmanId)
          .collection('received_orders')
          .doc(currentOrderId);

      final updateData = {
        'is_started': true,
        'status': 'جاري العمل',
        
      };
      if (inspectedPrice != null) {
        updateData['price'] = inspectedPrice;
      }

      batch.update(orderRef, updateData);
      batch.update(clientReqRef, updateData);
      batch.update(craftsmanRecRef, updateData);

      await batch.commit();

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم بدء العمل بنجاح!'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _craftsmanCompleteOrder(
      BuildContext context, String craftsmanId, String clientId, String currentOrderId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance.collection('orders').doc(currentOrderId);
      final clientReqRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(clientId)
          .collection('my_requests')
          .doc(currentOrderId);
      final craftsmanRecRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(craftsmanId)
          .collection('received_orders')
          .doc(currentOrderId);

      final updateData = {
        'craftsman_confirmed': true,
        'completed_by_craftsman_at': FieldValue.serverTimestamp(),
        'status': 'بانتظار تأكيد العميل',
      };

      batch.update(orderRef, updateData);
      batch.update(clientReqRef, updateData);
      batch.update(craftsmanRecRef, updateData);

      await batch.commit();

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم تسجيل إتمام العمل واستلام الدفع بنجاح!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
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
          .collection('received_orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب والعميل')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب والعميل')),
            body: const Center(child: Text('الطلب غير موجود أو تم حذفه')),
          );
        }

        final orderData = snapshot.data!.data() as Map<String, dynamic>;
        
        final clientName = orderData['clientName'] ?? 'مستخدم';
        final clientPhone = orderData['clientPhone'] ?? '';
        final location = orderData['location'] ?? 'غير متوفر';
        final notes = orderData['notes'] ?? '';
        final status = orderData['status'] ?? 'قيد التنفيذ';
        
        final String priceType = orderData['priceType'] ?? '';
        final dynamic priceValue = orderData['price'];
        final bool isStarted = orderData['is_started'] ?? false;
        final String buttonText = isStarted ? 'إتمام العمل واستلام الدفع' : 'البدء بالعمل';
        final Color buttonColor = isStarted ? Colors.green : Colors.blue;
        final IconData buttonIcon = isStarted ? Icons.check_circle_outline : Icons.play_arrow_rounded;
        final String clientId = orderData['clientId'] ?? '';

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('تفاصيل الطلب والعميل'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          const Icon(Icons.engineering, color: Colors.white, size: 32),
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
                      const Text(
                        'العميل الكريم',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clientName,
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
                  'معلومات التواصل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

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
                              const Text('رقم الهاتف', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                clientPhone.isNotEmpty ? clientPhone : 'لا يوجد رقم',
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
                  'تفاصيل الموقع والملاحظات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

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
                                  const Text('موقع العمل', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                                  const Text('ملاحظات العميل', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    notes.isNotEmpty ? notes : 'لا توجد ملاحظات إضافية لهذا الطلب.',
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
                                        ? ' $priceValue دينار ($priceType)'
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
                        onPressed: clientPhone.isNotEmpty
                            ? () => _makePhoneCall(clientPhone, context)
                            : null,
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text('اتصال هاتفي', style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: clientPhone.isNotEmpty
                            ? () => _openWhatsApp(clientPhone, context)
                            : null,
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text('مراسلة واتساب', style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
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
                  onPressed: () {
                    if (!isStarted) {
                      
                      if (priceType == 'يُحدد بعد المعاينة') {
                        showDialog(
                          context: context,
                          builder: (context) => PriceInputDialog(
                            onSubmit: (double enteredPrice) {
                              _startWorkingOrder(
                                context, 
                                currentUser.uid, 
                                clientId, 
                                orderId, 
                                inspectedPrice: enteredPrice,
                              );
                            },
                          ),
                        );
                      } else {
                        _startWorkingOrder(context, currentUser.uid, clientId, orderId);
                      }
                    } else {
                      _craftsmanCompleteOrder(context, currentUser.uid, clientId, orderId);
                    }
                  },
                  icon: Icon(buttonIcon, color: Colors.white),
                  label: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
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