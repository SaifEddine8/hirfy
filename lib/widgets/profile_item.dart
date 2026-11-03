import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class ProfileItem extends StatelessWidget {
   final IconData icon;
     final String title;
     final VoidCallback onTap;
  const ProfileItem({super.key,
  required  this.icon,
    required  this.title,
    required  this.onTap,});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: ConstantColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing:  Icon(Icons.arrow_forward_ios, size: 16, color: ConstantColors.primary),
        onTap: onTap,
      ),
    );
  }
}