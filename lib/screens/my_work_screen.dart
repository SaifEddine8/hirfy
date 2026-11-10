import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/screens/edit_work_screen.dart';

class MyWorkScreen extends StatelessWidget {
  const MyWorkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('خدماتي وأعمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: const Center(
          child: Text('يرجى تسجيل الدخول لعرض أعمالك', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ConstantColors.ternary,
      appBar: AppBar(
        title:  Text(
          'خدماتي وأعمالي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ConstantColors.ternary,
        // foregroundColor: Colors.black87,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('work') 
              .where('craftsmanId', isEqualTo: currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ في تحميل البيانات: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
        
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_off_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'لم تقم بإضافة أي خدمات بعد',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }
        
            final worksDocs = snapshot.data!.docs;
        
            return ListView.builder(
              itemCount: worksDocs.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final doc = worksDocs[index];
                final workData = doc.data() as Map<String, dynamic>;
                
                final work=WorkModel.fromMap(workData, doc.id); 
        
                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                work.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  work.isAvailable ? 'متاح' : 'غير متاح',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: work.isAvailable ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: work.isAvailable,
                                  activeColor: Colors.green,
                                  onChanged: (val) async {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('work')
                                          .doc(work.serviceId)
                                          .update({'isAvailable': val});
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('خطأ أثناء التحديث: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        // التفاصيل: السعر ورقم الهاتف
                        Row(
                          children: [
                            Icon(Icons.payments_outlined, size: 18, color: ConstantColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              work.priceType == 'يُحدد بعد المعاينة' 
                                  ? 'السعر: يُحدد بعد المعاينة' 
                                   : 'السعر: ${work.price} د.أ',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 18, color: ConstantColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'رقم التواصل: ${work.craftsmanPhone}',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // زر التعديل
                        Align(
                          alignment: Alignment.
                          centerRight,
                          child: ElevatedButton.icon(
                            
                            onPressed: () {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditWorkScreen(workId: work.serviceId, workData: workData),
                              ),
                            );
                            },
                            icon:  Icon(Icons.edit_rounded, size: 16, color: ConstantColors.ternary),
                            label:  Text('تعديل البيانات',
                                style: ConstantStyles.buttonTextStyle),
                            style: ConstantStyles.buttonStyle
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  
}