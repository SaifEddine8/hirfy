import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/screens/active_orders_screen.dart';
import 'package:hirfy/screens/received_orders_screen.dart';
import 'package:hirfy/widgets/category_card.dart';
import 'package:hirfy/widgets/filter_bottom_sheet.dart';
import 'package:hirfy/widgets/work_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
final List<String> _categories = [
  'الكل',
    'سباكة وصحي',
    'كهرباء منزلية',
    'نجارة وتركيب',
    'دهان وديكور',
    'تكييف وتبريد',
    'أخرى'
  ];
class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController search = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  
  String selectedItem = _categories[0];
  String? _filterPriceType; 
  double _minPrice = 0;     
  double _maxPrice = 1000;  
  double _minRating = 0;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ConstantColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حرفي',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'اختر أفضل الخدمات والحرفيين',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ActiveOrdersScreen()),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.local_shipping_outlined, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: search,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة أو حرفة...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[400],
                        ),
                        suffixIcon: search.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    search.clear();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: ConstantColors.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                    icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return FilterBottomSheet(
                            initialPriceType: _filterPriceType,
                            initialMinPrice: _minPrice,
                            initialMaxPrice: _maxPrice,
                            initialMinRating: _minRating,
                            onApply: (priceType, minPrice, maxPrice, minRating) {
                              setState(() {
                                _filterPriceType = priceType;
                                _minPrice = minPrice;
                                _maxPrice = maxPrice;
                                _minRating = minRating;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ListView.builder(
                itemExtent: 150,
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedItem == _categories[index];
                  return CategoryCard(
                    title: _categories[index],
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedItem = _categories[index];
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('work')
                    .snapshots(),
                builder: (context, workSnapshot) {
                  if (workSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!workSnapshot.hasData ||
                      workSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'لا توجد خدمات متاحة حالياً',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  final works = workSnapshot.data!.docs
                      .map((doc) => WorkModel.fromMap(
                            doc.data() ,
                            doc.id,
                          ))
                      .where((doc) =>
                          doc.category == selectedItem ||
                          
                          selectedItem == 'الكل')
                      .where((doc) => doc.title
                          .toLowerCase()
                          .contains(search.text.trim().toLowerCase()))
                          .where((doc)=>_filterPriceType==null ||
                          _filterPriceType!.isEmpty ||
                          doc.priceType==_filterPriceType)
                          .where((doc){
                            if (doc.price == null) return false;
                            return doc.price!>=_minPrice && doc.price!<=_maxPrice;
                          })
                          .where((doc)=>doc.rating>=_minRating)
                      .toList();

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('usersCollection')
                        .doc(firebaseAuth.currentUser!.uid)
                        .collection('favorite')
                        .snapshots(),
                    builder: (context, favsSnapshot) {
                      final favId = favsSnapshot.hasData
                          ? favsSnapshot.data!.docs.map((f) => f.id).toSet()
                          : <String>{};

                      final workWithFav = works
                          .map((w) =>
                              w.copyWith(isFav: favId.contains(w.serviceId)))
                          .toList();

                      if (workWithFav.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد نتائج تطابق بحثك',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: workWithFav.length,
                        itemBuilder: (context, index) => WorkCard(
                          work: workWithFav[index],
                          onFavoriteTap: () async {
                            if (workWithFav[index].isFav) {
                              await FirebaseFirestore.instance
                                  .collection('usersCollection')
                                  .doc(firebaseAuth.currentUser!.uid)
                                  .collection('favorite')
                                  .doc(workWithFav[index].serviceId)
                                  .delete();
                            } else {
                              await addFav(workWithFav[index]);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (context)=>ReceivedOrdersScreen()));
        },
        
        backgroundColor: ConstantColors.primary,
        label: const Text(
          'الطلبات الواردة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    );
  }

  Future<void> addFav(WorkModel work) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(uid)
        .collection('favorite')
        .doc(work.serviceId)
        .set(work.toMap());
  }
}