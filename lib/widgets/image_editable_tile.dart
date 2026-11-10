import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart'; // تأكد من مسار ألوان مشروعك

class ImageEditableTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onEditPressed;

  const ImageEditableTile({
    Key? key,
    required this.imageUrl,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Directionality(
        textDirection: TextDirection.rtl, // 👈 لقلب الاتجاه من اليمين لليسار
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // الصورة في أقصى اليمين
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 16),
              // النصوص في المنتصف وتأخذ المساحة المتبقية
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('صورة الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('اضغط لتغيير الصورة (كاميرا أو معرض)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // زر التعديل (أيقونة القلم أو الكاميرا) في أقصى اليسار
              IconButton(
                icon: Icon(Icons.edit_outlined, color: ConstantColors.primary),
                onPressed: onEditPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}