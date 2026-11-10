import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/utils.dart';
import 'package:hirfy/widgets/text_form_field_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AddWork extends StatefulWidget {
  const AddWork({super.key});

  @override
  State<AddWork> createState() => _AddWorkState();
}

class _AddWorkState extends State<AddWork> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
    final TextEditingController _phoneNumberController = TextEditingController();


  String? _selectedCategory;
  String? _selectedPriceType;
  bool _isAvailable = true;
File? _selectedImage;

final storageRef = Supabase.instance.client.storage;
  final List<String> _categories = [
    'سباكة وصحي',
    'كهرباء منزلية',
    'نجارة وتركيب',
    'دهان وديكور',
    'تكييف وتبريد',
    'أخرى'
  ];

  final List<String> _priceTypes = [
    'سعر ثابت',
    'بالساعة',
    'يُحدد بعد المعاينة'
  ];
  XFile? image;
  bool isLoading=false;
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantColors.primary,
        title: Text('إضافة حرفة / خدمة جديدة', style: ConstantStyles.title.copyWith(color: ConstantColors.ternary)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
            onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اختر مصدر الصورة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('معرض الصور'),
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    image = await picker.pickImage(
                      source: ImageSource.gallery,
                      
                    );
                    
                    if (image == null) return;
                    
                      setState(() {
                        _selectedImage = File(image!.path);
                      });
                    
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('الكاميرا'),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    image = await picker.pickImage(
                      source: ImageSource.camera,
                      
                    );
                    if (image == null) return;
                    
                      setState(() {
                        _selectedImage = File(image!.path);
                      });
                    
                  },
                ),
              ],
            ),
          ),
        );
            },
            child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 45,
                    color: Colors.blueGrey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'اضغط لإضافة صورة توضيحية للعمل',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(من المعرض أو الكاميرا)',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ]
            )
            )
            ),
            SizedBox(height: 20,),
            
            
          
                TextFormFieldWidget(
                  controller: _titleController,
                  hint: 'مثال: تركيب وصيانة مكيفات مركزية',
                  lable: 'عنوان الخدمة',
                  
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال عنوان الخدمة'
                      : null,
                ),
                const SizedBox(height: 16),
        
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'تصنيف الحرفة',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار التصنيف' : null,
                ),
                const SizedBox(height: 16),
        
                TextFormFieldWidget(
                  controller: _descriptionController,
                  hint: 'اشرح بوضوح ما تقدمه في هذه الخدمة...',
                  lable: 'تفاصيل الخدمة / نبذة عن خبرتك',
                  
                  
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال تفاصيل الخدمة'
                      : null,
                ),
                const SizedBox(height: 16),
        
                TextFormFieldWidget(
                  preIcon: Icons.attach_money,
                  controller: _priceController,
                  hint: 'مثال: 15',
                  lable: 'السعر',
                  
                  validator: (value) {
                    if (_selectedPriceType!=_priceTypes[2] && (value == null || value.trim().isEmpty)) {
                      return 'الرجاء إدخال السعر';
                    }
                    if (value!.trim().isNotEmpty && double.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
        
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriceType,
                  decoration: const InputDecoration(
                    labelText: 'نوع احتساب السعر',
                    border: OutlineInputBorder(),
                  ),
                  items: _priceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriceType = value;
                    });
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار نوع السعر' : null,
                ),
                const SizedBox(height: 16),
        
                TextFormFieldWidget(
                  controller: _locationController,
                  hint: 'مثال: إربد، الحي الشرقي',
                  lable: 'موقع العمل / نطاق الخدمة',
                  
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال موقع تقديم الخدمة'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormFieldWidget(
                  controller: _phoneNumberController,
                  hint: '07*******',
                  lable: 'رقم التواصل',
                  
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال رقم للتواصل'
                      : !Utils.checkPhone(_phoneNumberController.text)?'الرجاء إدخال رقم صحيح للتواصل':null,
                ),
                
        
               
                const SizedBox(height: 16),
        
                SwitchListTile(
                  title: const Text('متاح لاستقبال الطلبات حالياً'),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
        
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
                      
                      if (_formKey.currentState!.validate()) {
                        if(_selectedImage==null)
                        {
                          ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('الرجاءادخال صوره لاعمال سابقه لك')));
                          return;
                        }
                        final imageRef='images/${image!.name}';
                        await storageRef.from('storage').upload(imageRef, File(image!.path));
                        final UrlUmage=await storageRef.from('storage').getPublicUrl(imageRef);
                        WorkModel newWork=WorkModel(
                          serviceId: FirebaseFirestore.instance.collection('work').doc().id, 
                          craftsmanId: FirebaseAuth.instance.currentUser!.uid, 
                          craftsmanName: FirebaseAuth.instance.currentUser!.displayName!, 
                          craftsmanPhone: _phoneNumberController.text, 
                          title: _titleController.text, 
                          category: _selectedCategory!, 
                          description: _descriptionController.text, 
                          price: double.tryParse(_priceController.text), 
                          priceType: _selectedPriceType!, 
                          location: _locationController.text, 
                          imageUrl: UrlUmage, 
                          isAvailable: _isAvailable, 
                          rating: 5.0);
                          setState(() {
                            isLoading=!isLoading;
                          });
                          await addWork(newWork);
                          setState(() {
                            isLoading=!isLoading;
                          });
                      }
                      _titleController.clear();
                      _descriptionController.clear();
                      _priceController.clear();
                      _locationController.clear();
                      _phoneNumberController.clear();
                      _selectedImage=null;
                    },
                    style: ConstantStyles.buttonStyle,
                    child: isLoading?CircularProgressIndicator(color: Colors.white,): Text(
                      'حفظ ونشر الخدمة',
                      style: ConstantStyles.buttonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void>addWork(WorkModel newWork)async{
    final docRef=FirebaseFirestore.instance.collection('work').doc();
    newWork=newWork.copyWith(serviceId: docRef.id);
    await docRef.set(newWork.toMap());
    
  }
}