import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/models/notification_model.dart';
import 'package:hirfy/models/order_model.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/widgets/order_bottom_sheet.dart';

class WorkDetailsScreen extends StatelessWidget {
  final WorkModel work;

  const WorkDetailsScreen({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // خلفية ناعمة وحديثة جداً
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // 🌟 1. SliverAppBar مع صورة واسعة وتدرجات بصرية فائقة النقاء
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: ConstantColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    work.imageUrl.isNotEmpty
                        ? Image.network(
                            work.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image, size: 80, color: Colors.grey.shade400),
                          ),
                    // تدرج لوني مزدوج دقيق لضمان وضوح الأيقونات في أعلى الشاشة وأسفلها
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent, Colors.black54],
                          stops: [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('usersCollection')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('favorite')
                      .doc(work.serviceId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final bool isFavorite = snapshot.hasData && snapshot.data!.exists;
                    final currentWork = work.copyWith(isFav: isFavorite);
                    return Container(
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () async {
                          await toggleFav(currentWork, context);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            // 🌟 2. المحتوى الداخلي المنظم بأسلوب بطاقات تفاعلية فاخرة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط التصنيف وحالة التوافر بتصميم كبسولات أنيقة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: ConstantColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            work.category,
                            style: TextStyle(
                              color: ConstantColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: work.isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: work.isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                work.isAvailable ? 'متاح حالياً' : 'غير متاح',
                                style: TextStyle(
                                  color: work.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // عنوان الخدمة البارز
                    Text(
                      work.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 بطاقة السعر والموقع بتصميم عصري مميز
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.payments_rounded, color: Colors.green, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                work.priceType == 'يُحدد بعد المعاينة'
                                    ? 'يُحدد بعد المعاينة'
                                    : '${work.price} دينار',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                work.priceType,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded, color: Colors.grey.shade600, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  work.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // قسم تفاصيل الخدمة
                    const Text(
                      'تفاصيل الخدمة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        work.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🌟 كرت معلومات الحرفي العصري
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: ConstantColors.primary.withOpacity(0.12),
                            child: Icon(Icons.person, color: ConstantColors.primary, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  work.craftsmanName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: ConstantColors.primary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'حرفي معتمد وموثوق',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🌟 زر الطلب السفلي الفخم والعصري
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey.shade300,
              backgroundColor: ConstantColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: work.isAvailable
                ? () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => OrderBottomSheet(
                        work: work,
                        onSubmit: (location, phone, notes) {
                          _submitOrderToFirebase(
                            context: context,
                            location: location,
                            notes: notes,
                            phone: phone,
                          );
                        },
                      ),
                    );
                  }
                : null,
            icon: work.isAvailable
                ? const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 22)
                : const SizedBox.shrink(),
            label: Text(
              work.isAvailable ? 'تقديم طلب لهذه الخدمة' : 'الخدمة غير متاحة حالياً',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> toggleFav(WorkModel work, BuildContext context) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(uid)
        .collection('favorite')
        .doc(work.serviceId);
    try {
      if (work.isFav) {
        await favRef.delete();
      } else {
        await favRef.set(work.toMap());
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث المفضلة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitOrderToFirebase({
    required String location,
    required String phone,
    required String notes,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc();
      OrderModel newOrder = OrderModel(
        orderId: docRef.id,
        serviceId: work.serviceId,
        craftsmanId: work.craftsmanId,
        craftsmanName: work.craftsmanName,
        craftsmanPhone: work.craftsmanPhone,
        clientId: user.uid,
        clientName: user.displayName ?? 'مستخدم',
        clientPhone: phone,
        location: location,
        notes: notes,
        status: 'قيد الانتظار',
        createdAt: DateTime.now(),
        serviceName: work.title,
        price: work.priceType == 'يُحدد بعد المعاينة' ? null : work.price,
        priceType: work.priceType,
      );
      final notifRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(work.craftsmanId)
          .collection('notifications')
          .doc();
      NotificationModel newNotification = NotificationModel(
        id: notifRef.id,
        title: 'طلب خدمة جديد ',
        body: 'الزبون: ${user.displayName ?? 'مستخدم'}\n'
            'الخدمة المطلوبة: ${work.title}\n'
            'اضغط لعرض التفاصيل وتأكيد الطلب.',
        type: 'new_order',
        relatedId: docRef.id,
        isRead: false,
        createdAt: null,
      );
      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.set(docRef, newOrder.toMap());

      final clientReqRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(user.uid)
          .collection('my_requests')
          .doc(docRef.id);
      batch.set(clientReqRef, newOrder.toMap());

      final craftsmanRecRef = FirebaseFirestore.instance
          .collection('usersCollection')
          .doc(work.craftsmanId)
          .collection('received_orders')
          .doc(docRef.id);
      batch.set(craftsmanRecRef, newOrder.toMap());

      batch.set(notifRef, newNotification.toMap());
      await batch.commit();

      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تقديم الطلب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تقديم الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}