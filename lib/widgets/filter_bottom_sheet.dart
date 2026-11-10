import 'package:flutter/material.dart';
import 'package:hirfy/constant/constant_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialPriceType;
  final double initialMinPrice;
  final double initialMaxPrice;
  final double initialMinRating;
  final Function(String? priceType, double minPrice, double maxPrice, double minRating) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialPriceType,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialMinRating,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? tempPriceType;
  
  late double tempMinRating;
  TextEditingController minPriceController=TextEditingController();
  TextEditingController maxPriceController=TextEditingController();

  @override
  void initState() {
    super.initState();
    tempPriceType = widget.initialPriceType;
    
    tempMinRating = widget.initialMinRating;
    minPriceController=TextEditingController(text: widget.initialMinPrice.toString());
    maxPriceController=TextEditingController(text: widget.initialMaxPrice.toString());


  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
          
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
                    'تصفية النتائج (الفلترة)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tempPriceType = null;
                        minPriceController.text = '0';
                        maxPriceController.text = '1000';
                        tempMinRating = 0;
                      });
                    },
                    child: const Text('إعادة ضبط'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
      
              const Text('نوع احتساب السعر', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempPriceType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('الكل (جميع الأنواع)'),
                items: ['سعر ثابت', 'بالساعة', 'يُحدد بعد المعاينة'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    tempPriceType = val;
                  });
                },
              ),
              const SizedBox(height: 20),
      
              const Text('نطاق السعر (من - إلى)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الحد الأدنى', border: OutlineInputBorder()),
                      controller: minPriceController,
                      
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الحد الأقصى', border: OutlineInputBorder()),
                      controller: maxPriceController,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
      
              const Text('الحد الأدنى للتقييم', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: tempMinRating,
                min: 0,
                max: 5,
                divisions: 5,
                label: tempMinRating.toString(),
                onChanged: (val) {
                  setState(() {
                    tempMinRating = val;
                  });
                },
              ),
              Center(child: Text('التقييم المطلوب: $tempMinRating نجوم فأكثر')),
              const SizedBox(height: 25),
      
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ConstantColors.primary),
                  onPressed: () {
                    final double finalMinPrice = double.tryParse(minPriceController.text) ?? 0;
                    final double finalMaxPrice = double.tryParse(maxPriceController.text) ?? 1000;
                    widget.onApply(tempPriceType, finalMinPrice , finalMaxPrice, tempMinRating);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'تطبيق الفلترة',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}