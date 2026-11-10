import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirfy/models/notification_model.dart';
// تأكد من استيراد الموديل الخاص بك بالمسار الصحيح
// import 'path_to_model/notification_model.dart'; 

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: const Center(
          child: Text('يرجى تسجيل الدخول لعرض الإشعارات', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usersCollection')
            .doc(currentUser.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ في تحميل الإشعارات: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد إشعارات حالياً',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs.map((doc) {
            return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final bool isUnread = !notif.isRead;

              return ListTile(
                tileColor: isUnread ? Colors.blue.shade50.withOpacity(0.4) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: _getIconColor(notif.type).withOpacity(0.1),
                  child: Icon(
                    _getNotificationIcon(notif.type),
                    color: _getIconColor(notif.type),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Directionality(
                    // فرض الاتجاه من اليمين لليسار يمنع تداخل الحروف الإنجليزية والأسماء مع العربي نهائياً
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.body,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 6),
                        if (notif.createdAt != null)
                          Text(
                            _formatTimestamp(notif.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  if (isUnread) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('usersCollection')
                          .doc(currentUser.uid)
                          .collection('notifications')
                          .doc(notif.id)
                          .update({'isRead': true});
                    } catch (e) {
                      print('خطأ في تحديث حالة الإشعار: $e');
                    }
                  }
              
                  _handleNotificationNavigation(context, notif.type, notif.relatedId);
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_order':
        return Icons.handyman_rounded;
      case 'order_accepted':
        return Icons.check_circle_rounded;
      case 'order_rejected':
      case 'order_cancelled':
        return Icons.cancel_rounded;
      case 'new_review':
        return Icons.star_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_order':
        return Colors.blue;
      case 'order_accepted':
        return Colors.green;
      case 'order_rejected':
      case 'order_cancelled':
        return Colors.red;
      case 'new_review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleNotificationNavigation(BuildContext context, String type, String relatedId) {
    if (relatedId.isEmpty) return;
    print('Navigating to screen for type: $type with relatedId: $relatedId');
  }
}