import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/screens/nav_bar_screen.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                const Text(
                  'تأكيد البريد الإلكتروني',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Text(
                  'أرسلنا رابط التحقق إلى:\n${auth.currentUser?.email ?? ''}\nيرجى فتح الإيميل والضغط على الرابط لتفعيل حسابك.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final User? user = auth.currentUser;
                      await user?.reload();
                      if (!context.mounted) return;

                      if (user?.emailVerified == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('email verified successfully'),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => NavBarScreen()
                          ),(route)=>false
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('please verifiey your account'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تحققت، متابعة',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () async {
                    try {
                      final User? user = auth.currentUser;
                      if (!context.mounted) return;
                      await user?.sendEmailVerification();
                      // if (user!.emailVerified) {
                      //   Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => NavBar()),
                      //   );
                      // }
                    } on FirebaseException catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.message!)));
                    }
                  },
                  child: const Text('إعادة إرسال الرابط'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
