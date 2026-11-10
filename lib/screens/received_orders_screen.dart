import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/models/notification_model.dart';
import 'package:hirfy/widgets/received_orders_card.dart';

class ReceivedOrdersScreen extends StatelessWidget {
  const ReceivedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('الرجاء تسجيل الدخول لعرض الطلبات الواردة'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الواردة'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usersCollection')
            .doc(currentUser.uid)
            .collection('received_orders')
            .where('status', isEqualTo: 'قيد الانتظار') 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات واردة حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data();
              final orderId = orders[index].id;

              return ReceivedOrderCard(
                orderData: orderData,
                orderId: orderId,
                currentUserId: currentUser.uid,
                onActionPressed: (isAccepted) {
                  _handleOrderAction(
                    context: context,
                    orderId: orderId,
                    clientId: orderData['clientId'],
                    craftsmanId: currentUser.uid,
                    isAccepted: isAccepted,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
  Future<void> _handleOrderAction({
    required BuildContext context,
    required String orderId,
    required String clientId,
    required String craftsmanId,
    required bool isAccepted,
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

      if (isAccepted) {
        final updateData = {'status': 'قيد التنفيذ'};
        batch.update(orderRef, updateData);
        batch.update(clientReqRef, updateData);
        batch.update(craftsmanRecRef, updateData);
      } else {
        batch.delete(orderRef);
        batch.delete(clientReqRef);
        batch.delete(craftsmanRecRef);
      }
      final notifRef = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(clientId)
        .collection('notifications')
        .doc();
      NotificationModel actionNotification = NotificationModel(
      id: notifRef.id,
      title: isAccepted ? 'تم قبول طلبك ' : 'اعتذار عن الطلب ',
      body: isAccepted 
          ? 'وافق الحرفي على طلبك، وهو الآن قيد التنفيذ.' 
          : 'نأسف، لقد اعتذر الحرفي عن تنفيذ طلبك.',
      type: isAccepted ? 'order_accepted' : 'order_rejected', 
      relatedId: orderId,
      isRead: false,
      createdAt: null, 
    );
    batch.set(notifRef, actionNotification.toMap());
      await batch.commit();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(isAccepted ? 'تم قبول الطلب بنجاح!' : 'تم رفض الطلب وحذفه.'),
          backgroundColor: isAccepted ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  
  }
  }
  

  