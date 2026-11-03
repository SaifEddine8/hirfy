import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/constant/constant_styles.dart';
import 'package:hirfy/screens/login_screen.dart';
import 'package:hirfy/screens/onBoarding/first_screen.dart';
import 'package:hirfy/screens/onBoarding/second_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController=PageController();
  bool isLastPage=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children:[ 
            PageView(
              onPageChanged: (index){
                setState(() {
                  isLastPage=index==1;

                });
              },
            controller: pageController,
            children:[ 
              FirstScreen(),
              SecondScreen(),
              
            ]
          ),
          Container(
            alignment: Alignment(0,0.7),
            child: SmoothPageIndicator(
              effect: WormEffect(
                activeDotColor: ConstantColors.primary,
                dotColor: Colors.grey.shade300
              ),
              
              controller: pageController,
              count: 2,
            ),
          ),
          Container(
  alignment: const Alignment(0, 0.9),
  child: SizedBox(
    width: double.infinity, 
    height: 50, 
    child: ElevatedButton(
      onPressed: () {
        isLastPage?Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen(),), (route) => false,):pageController.jumpToPage(1);
        

      },
      style: ConstantStyles.buttonStyle,
      
      child:  Text(
        "Get Started",
        style: ConstantStyles.buttonTextStyle,
      ),
    ),
  ),
)
          
          ]
        ),
      ),
    );
  }
}