import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/widgets/favorite_card.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _firebaseAuth.currentUser;
    return Scaffold(
      // backgroundColor:ConstantColors.ternary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ConstantColors.primary,
        title:  Text(
          'المفضلة',
          style: ConstantStyles.title.copyWith(color: ConstantColors.ternary)
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usersCollection')
            .doc(currentUser!.uid)
            .collection('favorite')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ في جلب البيانات',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 50,
                      color: ConstantColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد خدمات في المفضلة',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'قم بإضافة الخدمات التي تعجبك لسهولة الوصول إليها لاحقاً',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data!.docs.map((doc) {
            return WorkModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return FavoriteCard(
                work: favorites[index],
                
                onRemove: () async {
                  await FirebaseFirestore.instance
                      .collection('usersCollection')
                      .doc(currentUser.uid)
                      .collection('favorite')
                      .doc(favorites[index].serviceId)
                      .delete();
                },
                
              );
            },
          );
        },
      ),
    );
  }
}