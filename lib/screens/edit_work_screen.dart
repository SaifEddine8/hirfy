import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/widgets/image_editable_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_editable_tile.dart';

class EditWorkScreen extends StatefulWidget {
  final String workId;
  final Map<String, dynamic> workData;

  const EditWorkScreen({Key? key, required this.workId, required this.workData}) : super(key: key);

  @override
  State<EditWorkScreen> createState() => _EditWorkScreenState();
}

class _EditWorkScreenState extends State<EditWorkScreen> {
  late Map<String, dynamic> localData;
bool _isLoading = false;
  final List<String> _categories = [
    'سباكة وصحي',
    'كهرباء منزلية',
    'نجارة وتركيب',
    'دهان وديكور',
    'تكييف وتبريد',
    'أخرى'
  ];
final List<String> pricingOptions = [
    'سعر ثابت',
    'بالساعة',
    'يُحدد بعد المعاينة',
  ];
  XFile? image;
  final storageRef = Supabase.instance.client.storage;
  @override
  void initState() {
    super.initState();
    localData = Map.from(widget.workData);
  }

  @override
  Widget build(BuildContext context) {
    final phoneValue = localData['craftsmanPhone'] ?? localData['phone'] ?? '';
    final priceType = localData['priceType'] ?? 'ثابت';
    final price = localData['price'];
    
    // تنسيق عرض التسعير بحسب النوع
    String priceDisplay = priceType;
    if (priceType != 'يُحدد بعد المعاينة') {
      priceDisplay = '$price دينار ($priceType)';
    }

    return Scaffold(
      backgroundColor: ConstantColors.ternary,
      appBar: AppBar(
        title: const Text('تعديل تفاصيل الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: ConstantColors.ternary,
        // foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. كارد تعديل الصورة (يفتح خيار الكاميرا أو المعرض)
          ImageEditableTile(
            imageUrl: localData['imageUrl'] ?? '',
            onEditPressed: () {
            _showImageSourceDialog(context);
  },),

          // 2. عنوان الخدمة
          CustomEditableTile(
            title: 'عنوان الخدمة',
            currentValue: localData['title'] ?? '',
            icon: Icons.title_rounded,
            onEditPressed: () => _showTextFieldDialog(
              title: 'عنوان الخدمة',
              fieldKey: 'title',
              initialValue: localData['title'] ?? '',
            ),
          ),

          // 3. تفاصيل الخدمة
          CustomEditableTile(
            title: 'تفاصيل الخدمة',
            currentValue: localData['description'] ?? '',
            icon: Icons.description_rounded,
            onEditPressed: () => _showTextFieldDialog(
              title: 'تفاصيل الخدمة',
              fieldKey: 'description',
              initialValue: localData['description'] ?? '',
              isTextArea: true,
            ),
          ),

          // 4. تصنيف الحرفة (يفتح قائمة Dropdown لاختيار التصنيف)
          CustomEditableTile(
            title: 'تصنيف الحرفة',
            currentValue: localData['category'] ?? '',
            icon: Icons.category_rounded,
            onEditPressed: () => _showCategoryEditBottomSheet(),
          ),

          // 5. رقم التواصل
          CustomEditableTile(
            title: 'رقم التواصل',
            currentValue: phoneValue,
            icon: Icons.phone_rounded,
            onEditPressed: () => _showTextFieldDialog(
              title: 'رقم التواصل',
              fieldKey: 'craftsmanPhone',
              initialValue: phoneValue,
              keyboardType: TextInputType.phone,
            ),
          ),

          // 6. الموقع أو المنطقة
          CustomEditableTile(
            title: 'الموقع أو المنطقة',
            currentValue: localData['location'] ?? '',
            icon: Icons.location_on_rounded,
            onEditPressed: () => _showTextFieldDialog(
              title: 'الموقع أو المنطقة',
              fieldKey: 'location',
              initialValue: localData['location'] ?? '',
            ),
          ),

          // 7. التسعير (يفتح BottomSheet الخاص به مع الخيارات الثلاثة)
          CustomEditableTile(
            title: 'التسعير',
            currentValue: priceDisplay,
            icon: Icons.payments_outlined,
            onEditPressed: () => _showPriceEditBottomSheet(),
          ),
        ],
      ),
    );
  }



  // 📌 ديالوج لاختيار مصدر الصورة (كاميرا أو معرض)
  void _showImageSourceDialog(BuildContext context) {
  final parentContext = context;

  showDialog(
    context: parentContext,
    builder: (dialogContext) => AlertDialog(
      title: const Text('تغيير صورة الخدمة'),
      content: const Text('من أين تريد اختيار الصورة الجديدة؟'),
      actions: [
        TextButton.icon(
          onPressed: () async {
            Navigator.pop(dialogContext);

            final ImagePicker picker = ImagePicker();
            XFile? image;

            try {
              image = await picker.pickImage(
                source: ImageSource.camera,
              );
            } catch (e) {
              if (!parentContext.mounted) return;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('تعذر فتح الكاميرا: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (image == null) return;

            if (!parentContext.mounted) return;

            showDialog(
              context: parentContext,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            try {
              final file = File(image.path);
              final fileExt = image.name.split('.').last.toLowerCase();
              final fileName = 'work_${widget.workId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
              final imageRef = 'images/$fileName';

              final String oldImageUrl = localData['imageUrl'] ?? '';
              if (oldImageUrl.isNotEmpty) {
                try {
                  final uri = Uri.parse(oldImageUrl);
                  final filePath = uri.pathSegments.last;
                  await storageRef.from('storage').remove(['images/$filePath']);
                } catch (_) {}
              }

              await storageRef.from('storage').upload(imageRef, file);
              final String newPublicUrl = storageRef.from('storage').getPublicUrl(imageRef);

              await FirebaseFirestore.instance.collection('work').doc(widget.workId).update({
                'imageUrl': newPublicUrl,
              });

              setState(() {
                localData['imageUrl'] = newPublicUrl;
              });

              if (!parentContext.mounted) return;
              Navigator.pop(parentContext); 

              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('تم استبدال الصورة بالكاميرا بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (parentContext.mounted) {
                Navigator.pop(parentContext);
              }
              if (!parentContext.mounted) return;
              
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('فشل رفع صورة الكاميرا: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('الكاميرا'),
        ),

        ElevatedButton.icon(
          style: ConstantStyles.buttonStyle,
          onPressed: () async {
            Navigator.pop(dialogContext);

            final ImagePicker picker = ImagePicker();
            XFile? image;

            try {
              image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
            } catch (e) {
              if (!parentContext.mounted) return;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('تعذر فتح المعرض: $e'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (image == null) return;

            if (!parentContext.mounted) return;

            showDialog(
              context: parentContext,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            try {
              final file = File(image.path);
              final fileExt = image.name.split('.').last.toLowerCase();
              final fileName = 'work_${widget.workId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
              final imageRef = 'images/$fileName';

              final String oldImageUrl = localData['imageUrl'] ?? '';
              if (oldImageUrl.isNotEmpty) {
                try {
                  final uri = Uri.parse(oldImageUrl);
                  final filePath = uri.pathSegments.last;
                  await storageRef.from('storage').remove(['images/$filePath']);
                } catch (_) {}
              }

              await storageRef.from('storage').upload(imageRef, file);
              final String newPublicUrl = storageRef.from('storage').getPublicUrl(imageRef);

              await FirebaseFirestore.instance.collection('work').doc(widget.workId).update({
                'imageUrl': newPublicUrl,
              });

              setState(() {
                localData['imageUrl'] = newPublicUrl;
              });

              if (!parentContext.mounted) return;
              Navigator.pop(parentContext); 

              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('تم استبدال الصورة من المعرض بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (processError) {
              if (parentContext.mounted) {
                Navigator.pop(parentContext); 
              }
              if (!parentContext.mounted) return;

              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(
                  content: Text('فشل رفع صورة المعرض: $processError'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: Icon(Icons.photo_library, color: ConstantColors.ternary),
          label: Text('المعرض', style: ConstantStyles.buttonTextStyle),
        ),
      ],
    ),
  );
}

  // 📌 ديالوج نصي موحد لتعديل الخانات النصية
  void _showTextFieldDialog({
    required String title,
    required String fieldKey,
    required String initialValue,
    bool isTextArea = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $title'),
        content: TextField(
          controller: controller,
          maxLines: isTextArea ? 3 : 1,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'أدخل $title الجديد',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ConstantStyles.buttonStyle,
            onPressed: () async {
              final newValue = controller.text.trim();
              try {
                await FirebaseFirestore.instance.collection('work').doc(widget.workId).update({
                  fieldKey: newValue,
                });

                setState(() {
                  localData[fieldKey] = newValue;
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تحديث $title بنجاح!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child:  Text('حفظ',style:ConstantStyles.buttonTextStyle ,),
          ),
        ],
      ),
    );
  }

  // 📌 BottomSheet خاص بتعديل تصنيف الحرفة (Dropdown)
  void _showCategoryEditBottomSheet() {
    String selectedCategory = localData['category'] ?? _categories.first;
    if (!_categories.contains(selectedCategory)) {
      selectedCategory = _categories.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر تصنيف الحرفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ConstantStyles.buttonStyle,
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance.collection('work').doc(widget.workId).update({
                            'category': selectedCategory,
                          });

                          setState(() {
                            localData['category'] = selectedCategory;
                          });

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث التصنيف بنجاح!'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child:  Text('حفظ التعديل',style: ConstantStyles.buttonTextStyle,),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 📌 BottomSheet خاص بتعديل خيارات التسعير (ثابت، بالساعة، يُحدد بعد المعاينة)
  void _showPriceEditBottomSheet() {
    String selectedType = localData['priceType'] ?? 'ثابت';
    final priceController = TextEditingController(
      text: localData['price'] != null ? localData['price'].toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تعديل خيارات التسعير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'نوع التسعير', border: OutlineInputBorder()),
                    items: pricingOptions.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  if (selectedType != 'يُحدد بعد المعاينة') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: selectedType == 'بالساعة' ? 'قيمة السعر لكل ساعة (دينار)' : 'قيمة السعر (دينار)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ConstantStyles.buttonStyle,
                      onPressed: () async {
                        final double? parsedPrice = selectedType == 'يُحدد بعد المعاينة'
                            ? null
                            : double.tryParse(priceController.text);

                        try {
                          await FirebaseFirestore.instance.collection('work').doc(widget.workId).update({
                            'priceType': selectedType,
                            'price': parsedPrice,
                          });

                          setState(() {
                            localData['priceType'] = selectedType;
                            localData['price'] = parsedPrice;
                          });

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث التسعير بنجاح!'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child:  Text('حفظ التعديل',style: ConstantStyles.buttonTextStyle,),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}