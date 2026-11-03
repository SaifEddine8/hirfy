import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';
import 'package:hirfy/models/work_model.dart';
import 'package:hirfy/utils.dart';

class OrderBottomSheet extends StatefulWidget {
  final WorkModel work;
final Function(String location, String phone, String notes) onSubmit;

  OrderBottomSheet({
    super.key,
    required this.onSubmit,
    required this.work,
  });

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  final TextEditingController locationController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تقديم طلب خدمة جديدة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'موقع العمل / العنوان بالتفصيل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال موقع العمل' : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف للتواصل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
                
                
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if(!Utils.checkPhone(phoneController.text.trim())){
                  return 'الرجاء إدخال رقم هاتف صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'تفاصيل إضافية أو وصف المشكلة...',
                border: OutlineInputBorder(),
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
                onPressed: () async {
                  widget.onSubmit(
                    locationController.text.trim(),
                    phoneController.text.trim(),
                  notesController.text.trim(),
                  );
                  Navigator.pop(context);
    },
                child: const Text(
                  'تأكيد وإرسال الطلب',
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