import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class RatingBottomSheet extends StatefulWidget {
  final Function(double rating, String review) onSubmitRating;

  const RatingBottomSheet({
    super.key,
    required this.onSubmitRating,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  double _currentRating = 5.0; 
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 15),

            const Text(
              'قيم الخدمة والحرفي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'كيف كانت تجربتك مع هذه الخدمة؟ رأيك يساعدنا في تحسين الجودة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _currentRating = (index + 1).toDouble();
                    });
                  },
                  icon: Icon(
                    index < _currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '$_currentRating / 5.0',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'اكتب تعليقاً أو ملاحظة (اختياري)',
                hintText: 'مثال: خدمة ممتازة وسريعة، أنصح بالتعامل معه...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onSubmitRating(
                    _currentRating,
                    _reviewController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'إرسال التقييم وإنهاء الطلب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}