import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/services/auth_service.dart';
import 'package:hirfy/utils.dart';
import 'package:hirfy/widgets/text_form_field_widget.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.ternary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ConstantColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'نسيت كلمة المرور',
          style: TextStyle(color: ConstantColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  'أدخل بريدك الإلكتروني المرتبط بحسابك، وسنرسل لك تعليمات إعادة تعيين كلمة المرور.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

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
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = !_isLoading;
                      });

                      try {
                        await AuthService.resendPassword(_emailController.text.trim());
                        
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('إذا كان لديك حساب، سوف نرسل لك رابط/رمز تأكيد عليه'),
                          ),
                        );
                        Navigator.pop(context); 
                      } on AuthException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.mas)),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = !_isLoading;
                          });
                        }
                      }
                    }
                  },
                  style: ConstantStyles.buttonStyle,
                  child: _isLoading
                      ?  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                          'إعادة التعيين',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}