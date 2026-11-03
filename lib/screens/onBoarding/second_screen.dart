import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 30,
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    height: 200,
                    width: 200,
                  ),
                   
                    Column(
                      children: [
                        Text("حرفيون معتمدون وموثوقون... لخدمتك بأعلى جودة",style:TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ConstantColors.primary
                        ),
                        textAlign: .center,
                        ),
                        Text("تواصل مباشرة مع المتخصصين بعد تأكيد الطلب، وتابع إنجاز عملك بكل راحة وپثقة.",
                    style:TextStyle(
                      fontSize: 16,
                      color: ConstantColors.primary
                    ),
                    textAlign: .center,
                    ),
                      ],
                    ),
                    
                    
                    
                    
            
              
                  
                ],
              ),
            );
   
  }
}