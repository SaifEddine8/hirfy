import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class CustomEditableTile extends StatelessWidget {
  final String title;
  final String currentValue;
  final IconData icon;
  final VoidCallback onEditPressed;

  const CustomEditableTile({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.icon,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Directionality(
        textDirection: TextDirection.rtl, 
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: ConstantColors.primary), 
          title: Text(
            title, 
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              currentValue.isNotEmpty ? currentValue : 'غير محدد',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit_outlined, color: ConstantColors.primary), 
            onPressed: onEditPressed,
          ),
        ),
      ),
    );
  }
}