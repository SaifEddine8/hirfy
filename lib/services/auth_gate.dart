import 'package:flutter/material.dart';

import 'package:hirfy/screens/login_screen.dart';
import 'package:hirfy/screens/nav_bar_screen.dart';
import 'package:hirfy/screens/splash_screen.dart';
import 'package:hirfy/screens/verification_screen.dart';
import 'package:hirfy/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } 
        else if (snapshot.hasData) {
          final user=snapshot.data;
          if(user==null)
          {
            return LoginScreen();
          }
          else if(!user.emailVerified)
          {
            return VerificationScreen();
          }
          else if(user.emailVerified)
          {
            return NavBarScreen();
          }
          // return FutureBuilder(
          //   future: FirebaseFirestore.instance.collection('usersCollection')
          //       .doc(snapshot.data!.uid)
          //       .get(),
          //   builder: (context,roleSnapshot)
          //   {

          //     if(!roleSnapshot.hasData)
          //     {
          //       return Scaffold(body: Center(child: CircularProgressIndicator()));

          //     }
          //     final user=snapshot.data;
          //     if(user==null)
          //     {return LoginScreen();}
          //     else if(!user.emailVerified)
          //     {
          //       return VerificationScreen();
          //     }
          //     else if(user.emailVerified)
          //     {
                
              
              
          //       return NavBarScreen();
              
             
          //     }
          //     // print('object');
              
          //      return Center(child: CircularProgressIndicator());

          //   },
          // );
        }
        return SplashScreen();
      },
    );
  }
}