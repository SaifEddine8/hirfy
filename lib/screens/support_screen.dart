import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/widgets/faq_item_card.dart';
import 'package:hirfy/widgets/text_form_field_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('المساعدة والدعم', style: ConstantStyles.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            

            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
                  FaqItemCard(
                    question: 'كيف يمكنني تعديل بيانات حسابي؟',
                    answer: 'يمكنك الانتقال إلى الملف الشخصي، ثم الضغط على زر تعديل الملف الشخصي لتغيير اسمك أو رقم هاتفك.',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  FaqItemCard(
                    question: 'كيف أستطيع التواصل مع الحرفي؟',
                    answer: 'عند تصفح الخدمات أو الطلبات، يظهر لك زر اتصال أو واتساب خاص بالحرفي المعني لتتمكن من التفاهم معه مباشرة.',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  FaqItemCard(
                    question: 'نسيت كلمة المرور، ماذا أعمل؟',
                    answer: 'من شاشة تعديل الملف الشخصي، يمكنك الضغط على "إعادة تعيين كلمة المرور" وسيتم إرسال رابط التغيير لبريدك الإلكتروني فوراً.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'أرسل لنا رسالة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormFieldWidget(
                      controller: _messageController,
                      hint: 'اكتب مشكلتك أو استفسارك بالتفصيل...',
                      lable: 'رسالة الدعم',
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'الرجاء كتابة رسالة قبل الإرسال'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ConstantStyles.buttonStyle,
                        onPressed: () async{
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = !_isLoading);
                                  await _sendEmailDirectly(context,_messageController.text.trim());
                                  if(!context.mounted)return;
                                  setState(() => _isLoading = !_isLoading);
                                    _messageController.clear();
                                  
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            :  Text(
                                'إرسال الرسالة',
                                style: ConstantStyles.buttonTextStyle
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

 Future<void> _sendEmailDirectly(BuildContext context, String userMessage) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'saifbnyslamh12@gmail.com', 
    queryParameters: {
      'subject': 'شكوى أو استفسار جديد من تطبيق حِـرَفـِي',
      'body': userMessage,
    },
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح تطبيق البريد الإلكتروني على جهازك.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}