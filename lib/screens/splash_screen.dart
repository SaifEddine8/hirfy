import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/screens/onBoarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()
  {
    super.initState();
Timer(
      Duration(seconds:3),()=>
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>OnboardingScreen())
      )

    );  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                    'assets/images/logo.png', 
                    height: 200,
                    width: 200,
                  ),
             CircularProgressIndicator(
               color: ConstantColors.primary,
             )
              
            ],
          ),
        ),
      ),
    );
  }
}