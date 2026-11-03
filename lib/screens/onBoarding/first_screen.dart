import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

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
                        Text("كل ما تحتاجه من خدمات منزلية وحرفية... بضغط زر واحدة",style:TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ConstantColors.primary
                        ),
                        textAlign: .center,
                        ),
                        Text("تصفح أفضل الحرفيين والمهنيين في منطقتك، واطلب الخدمة بكل سهولة وأمان.",
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