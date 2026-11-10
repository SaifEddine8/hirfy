import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/models/notification_model.dart';
import 'package:hirfy/widgets/active_order_card.dart';
import 'package:hirfy/widgets/price_input_dialog.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({Key? key}) : super(key: key);




  
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

  Future<void> _craftsmanCompleteOrder({
    required BuildContext context,
    required String orderId,
    required String clientId,
    required String craftsmanId,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);
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

      final updateData = {
        'craftsman_confirmed': true,
        'completed_by_craftsman_at': FieldValue.serverTimestamp(),
        'status': 'بانتظار تأكيد العميل',
      };

      batch.update(orderRef, updateData);
      batch.update(clientReqRef, updateData);
      batch.update(craftsmanRecRef, updateData);

       final notifRef = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(craftsmanId)
        .collection('notifications')
        .doc();
      NotificationModel completionNotification = NotificationModel(
        id: notifRef.id,
        title: 'تم إتمام العمل واستلام الدفع',
        body: 'قام الحرفي بتأكيد إتمام العمل واستلام الدفع، يرجى تأكيد ذلك.',
        type: 'order_completed_pending',
        relatedId: orderId,
        isRead: false,
        createdAt: null,
      );
    batch.set(notifRef, completionNotification.toMap());
    

      await batch.commit();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل إتمام العمل! بانتظار تأكيد العميل.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _autoCompleteExpiredOrder({
    required String orderId,
    required String clientId,
    required String craftsmanId,
  }) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);
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

      final updateData = {
        'status': 'مكتمل',
      };

      batch.update(orderRef, updateData);
      batch.update(clientReqRef, updateData);
      batch.update(craftsmanRecRef, updateData);

     
      await batch.commit();
      print('تم أرشفة الطلب $orderId تلقائياً لمرور أكثر من 48 ساعة.');
    } catch (e) {
      print('خطأ في الأرشفة التلقائية: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('يرجى تسجيل الدخول أولاً'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات النشطة'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usersCollection')
              .doc(currentUser.uid)
              .collection('received_orders')
              .where('status', whereIn: ['قيد التنفيذ', 'جاري العمل', 'بانتظار تأكيد العميل'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }
        
            final orders = snapshot.data?.docs ?? [];
        
            final activeOrders = orders.where((doc) {
              final orderData = doc.data() as Map<String, dynamic>;
              final orderStatus = orderData['status'];
        
              if (orderStatus == 'بانتظار تأكيد العميل') {
                final Timestamp? completedAt = orderData['completed_by_craftsman_at'];
                if (completedAt != null) {
                  final DateTime completionTime = completedAt.toDate();
                  final Duration difference = DateTime.now().difference(completionTime);
                  
                  if (difference.inHours >= 48) {
                    return false; 
                  }
                }
              }
              return true;
            }).toList();
        
            if (orders.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد طلبات قيد التنفيذ حالياً',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
        
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>;
                final orderId = orders[index].id;
                final bool isStarted = orderData['is_started'] ?? false;
                final bool craftsmanConfirmed = orderData['craftsman_confirmed'] ?? false;
                final String priceType = orderData['priceType'] ?? 'يُحدد بعد المعاينة';
                final String clientId = orderData['clientId'] ?? '';
                return ActiveOrderCard(
                  orderData: orderData,
                  orderId: orderId,
                  currentUserId: currentUser.uid,
                  onActionPressed: craftsmanConfirmed
                      ? null 
                      : () {
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
                            _craftsmanCompleteOrder(
                              context: context,
                              orderId: orderId,
                              clientId: orderData['clientId'],
                              craftsmanId: currentUser.uid,
                            );
                          }
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}