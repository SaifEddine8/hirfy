import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/screens/forget_password.dart';
import 'package:hirfy/screens/nav_bar_screen.dart';
import 'package:hirfy/screens/verification_screen.dart';
import 'package:hirfy/services/auth_service.dart';
import 'package:hirfy/utils.dart';
import 'package:hirfy/widgets/text_form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hasAccount = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passScure=true;
  String _userRole = 'client'; 
  bool _isLoading=false;

 
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.ternary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasAccount ? 'أهلاً بك في حِرْفي' : 'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ConstantColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasAccount
                        ? 'قم بتسجيل الدخول للمتابعة'
                        : 'سجّل الآن للوصول إلى أفضل الحرفيين والخدمات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (!hasAccount) ...[
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('عميل', style: TextStyle(fontSize: 14)),
                            value: 'client',
                            groupValue: _userRole,
                            activeColor: ConstantColors.secondary,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('حرفي', style: TextStyle(fontSize: 14)),
                            value: 'artisan',
                            groupValue: _userRole,
                            activeColor: ConstantColors.secondary,
                            onChanged: (value) {
                              setState(() {
                                _userRole = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                  if (!hasAccount)
                    TextFormFieldWidget(
                      hint: 'الاسم الكامل',
                      lable: 'الاسم الكامل',
                      preIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (!hasAccount && (value == null || value.trim().isEmpty)) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        if(!Utils.checkUsername(value!))
                        {
                          return 'الاسم غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormFieldWidget(
                      hint: '079....',
                      lable: 'رقم الهاتف',
                      preIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      validator: (value) {
                        if (!hasAccount && (value == null || value.trim().isEmpty)) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        if(!Utils.checkPhone(value!))
                        {
                          return 'رقم الهاتف غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormFieldWidget(
                    hint: 'name@domain.com',
                    lable: 'البريد الإلكتروني',
                    preIcon: Icons.email_outlined,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      if(!Utils.checkEmail(value))
                        {
                          return 'البريد الالكتروني غير صحيح';
                        }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormFieldWidget(
                    hint: '********',
                    lable: 'كلمة المرور',
                    preIcon: Icons.lock_outline,
                    sufIcon: InkWell(
                          onTap: () => setState(() {
                            passScure = !passScure;
                          }),
                          child: passScure ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                        ),
                    controller: _passwordController,
                    obScure: passScure, 
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 خانات على الأقل';
                      }
                      if(!Utils.checkPassword(value))
                        {
                          return 'كلمة المرور غير صحيحه';
                        }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  if(hasAccount)
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPassword()));
                  },
                  style: TextButton.styleFrom(
                    alignment: .centerRight
                  )
                  , child: Text('نسيت كلمة المرور')),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: ()async{
                      if(_formKey.currentState!.validate())
                      {
                        setState(() {
                          _isLoading=!_isLoading;
                        });
                        try
                        {if(hasAccount)
                        {
                          final credential=await AuthService.login(email: _emailController.text.trim(), password: _passwordController.text.trim());
                          if(!credential.user!.emailVerified)
                          {
                            return;
                            }
                            if(credential.user!.emailVerified)
                            {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>NavBarScreen()), (route)=>false);
                            }
                            }
                        }on AuthException catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mas)));
                        }
                        if(!hasAccount)
                        {
                          try
                          {final credential=await AuthService.signUp(email: _emailController.text.trim(), password: _passwordController.text.trim(), context: context,displayName: _nameController.text.trim(),role: _userRole);
                          final User? user=credential.user;
                          await user?.sendEmailVerification();
                          if(!context.mounted)return;
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>VerificationScreen()));
                          }on AuthException catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mas)));
                          }

                        }

                      }
                      setState(() {
                        _isLoading=!_isLoading;
                      });
                      _emailController.clear();
                      _passwordController.clear();
                      _phoneController.clear();
                      _nameController.clear();
                      
                    },
                    style: ConstantStyles.buttonStyle,
                    child: _isLoading?Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.white,
                              strokeWidth: 2,),
                    ):Text(
                      hasAccount ? 'تسجيل الدخول' : 'إنشاء الحساب',
                      style: ConstantStyles.buttonTextStyle
                    ),
                  ),
                  Divider(),
                  CircleAvatar(
                    
                    child:ElevatedButton(onPressed: ()async{
                      final credential=await AuthService.signInWithGoogle(context);
                      if(credential!=null)
                      {
                        Navigator.pushAndRemoveUntil(context, 
                        MaterialPageRoute(builder: (context)=>NavBarScreen()), 
                        (route)=>false);
                        
                      }
                      
                    }, 
                    
                    child: Image.network('https://media.wired.com/photos/5926ffe47034dc5f91bed4e8/3:2/w_2560%2Cc_limit/google-logo.jpg'))
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            hasAccount = !hasAccount; 
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          hasAccount ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                          style:  TextStyle(
                            // color: ConstantColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        hasAccount ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      
                    ],
                  ),
                ],
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}