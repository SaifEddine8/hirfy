import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
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
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
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
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent],
                        stops: [0.0, 0.4],
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
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async{
                      await toggleFav(currentWork,context);
                    },
                  );
                }
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ConstantColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: work.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: work.isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              work.isAvailable ? 'متاح حالياً' : 'غير متاح',
                              style: TextStyle(
                                color: work.isAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    work.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 22),
                      Text(work.priceType=='يُحدد بعد المعاينة'?
                                  'يُحدد بعد المعاينة '
                                  :'${work.price} دينار',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${work.priceType})',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        work.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 15),

                  const Text(
                    'تفاصيل الخدمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    work.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                work.craftsmanName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'حرفي معتمد',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
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
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(context: context, 
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
              ),
              builder:(context)=> OrderBottomSheet(
                work: work,
                onSubmit:(location,phone,notes){
                _submitOrderToFirebase(context: context,
                location:location,
                notes: notes,
                phone: phone);
              }
              )
              );
            },
            icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
            label: const Text(
              'تقديم طلب لهذه الخدمة',
              style: TextStyle(
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


  Future<void> toggleFav(WorkModel work,BuildContext context) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef= FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(uid)
        .collection('favorite')
        .doc(work.serviceId);
        try{
          if(work.isFav)
          {
            await favRef.delete();
          }
          else{
            await favRef.set(work.toMap());
          }
        }catch(e){
          if(!context.mounted)return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحديث المفضلة: $e'),
          backgroundColor:Colors.red ,));
          
        }
        
  }
  Future<void>_submitOrderToFirebase({
    
      required String location,
      required String phone,
      required String notes,
      required BuildContext context
    
  })async
  {
    final user=FirebaseAuth.instance.currentUser;
    if(user==null)return;
    showDialog(context: context, 
    builder:(context)=>Center(child: CircularProgressIndicator(),) );
    try
    {final docRef=FirebaseFirestore.instance.collection('orders').doc();
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
        price: work.priceType=='يُحدد بعد المعاينة'?null:work.price,
        priceType: work.priceType
      );
      WriteBatch batch=FirebaseFirestore.instance.batch();

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


      await batch.commit();

      if(!context.mounted)return;
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تقديم الطلب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
  }catch (e) {
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

  
