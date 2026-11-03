import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class ConstantStyles {




 static final TextStyle title=TextStyle(
    color: Colors.black,
    fontWeight: .bold,
    fontSize: 24
  );
  static final TextStyle subTitle=TextStyle(
    color: Colors.black,
    fontWeight: .bold,
    fontSize: 20
  );




  static final TextStyle buttonTextStyle=TextStyle(
    color: Colors.white,
    fontWeight: .bold,
    fontSize: 16
  );
  static final ButtonStyle buttonStyle=ElevatedButton.styleFrom(
     backgroundColor: ConstantColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
  );
}