
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/screens/edit_profile_screen.dart';
import 'package:hirfy/screens/login_screen.dart';
import 'package:hirfy/screens/my_orders_screen.dart';
import 'package:hirfy/screens/notification_screen.dart';
import 'package:hirfy/screens/support_screen.dart';
import 'package:hirfy/services/auth_service.dart';
import 'package:hirfy/widgets/profile_avatar_widget.dart';
import 'package:hirfy/widgets/profile_item.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<Map<String,IconData>,Widget>profileItems=
    {
      {'تعديل الملف الشخصي':Icons.edit_outlined,}:EditProfileScreen(),
      {'حجوزاتي والطلبات':Icons.assignment_outlined,}:MyOrdersScreen(),
      {'إعدادات الإشعارات':Icons.notifications_outlined,}:NotificationScreen(),
      {'المساعدة والدعم':Icons.help_outline}:SupportScreen()
      };
      
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(
        title:  Text('الملف الشخصي',style: ConstantStyles.title,),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<User?>(
        stream: AuthService.authState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                Center(
                  child: Column(
                    children: [
                      ProfileAvatarWidget(user: user,),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName ?? 'مستخدم حِرفي',
                        style: ConstantStyles.subTitle
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'لا يوجد بريد إلكتروني',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.emailVerified ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: user.emailVerified ? Colors.green : Colors.orange,
                          ),
                        ),
                        child: Text(
                          user.emailVerified ? 'البريد موثق' : 'البريد غير موثق',
                          style: TextStyle(
                            fontSize: 12,
                            color: user.emailVerified ? Colors.green.shade700 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                ...profileItems.entries.map((item)=>ProfileItem(
                  icon: item.key.values.first, 
                  title: item.key.keys.first, 
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>item.value));
                  })).toList(),
               
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await AuthService.signout();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

 

}