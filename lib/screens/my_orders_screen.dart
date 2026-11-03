import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/widgets/client_request_card.dart';
import 'package:hirfy/screens/client_order_details_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usersCollection')
            .doc(currentUser.uid)
            .collection('my_requests')
            .orderBy('createdAt', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات سابقة حالياً',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData = requests[index].data() as Map<String, dynamic>;
              final orderId = requests[index].id;

              return ClientRequestCard(
                requestData: requestData,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientOrderDetailsScreen(
                        orderId: orderId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}