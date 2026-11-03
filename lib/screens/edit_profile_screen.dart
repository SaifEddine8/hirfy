import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/services/auth_service.dart';
import 'package:hirfy/widgets/profile_avatar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/widgets/text_form_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _nameController.text = currentUser!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, 
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي', style: ConstantStyles.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ProfileAvatarWidget(user: currentUser,),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('اختر الصورة الشخصية'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library, color: Colors.blue),
                                    title: const Text('معرض الصور'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (pickedFile != null) {
                                        setState(() {
                                          _selectedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt, color: Colors.blue),
                                    title: const Text('الكاميرا'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.camera,
                                      );
                                      if (pickedFile != null) {
                                        setState(() {
                                          _selectedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormFieldWidget(
                      controller: _nameController,
                      hint: 'أدخل اسمك الكامل',
                      lable: 'الاسم الكامل',
                     
                    ),
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
              

              
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ConstantStyles.buttonStyle,
                  onPressed:() async{
                    setState(() {
                      _isLoading=!_isLoading;
                    });
                        await  AuthService.updateDisplayName(_nameController.text.trim());
                        await AuthService.updateProfilePicture(_selectedImage);
                          
                          setState(() {
                            currentUser=FirebaseAuth.instance.currentUser;
                            _isLoading=!_isLoading;
                          });
                          _nameController.clear();
                        },
                        
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                          'حفظ التعديلات',
                          style: ConstantStyles.buttonTextStyle
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Colors.orange),
                  ),
                  title: const Text(
                    'كلمة المرور',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'تغيير كلمة المرور الخاصة بحسابك',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      if (currentUser?.email != null) {
                        AuthService.resendPassword(currentUser!.email!);
                      }
                    },
                    child: const Text(
                      'إعادة تعيين',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}