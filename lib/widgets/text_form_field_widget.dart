import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String hint;
  final String? lable;
  final IconData? preIcon;
  final Widget? sufIcon;
  final String? help;
  final TextEditingController controller;
  final bool obScure;
  final String? Function(String?)? validator;
  final VoidCallback? realTimeCheck;
  const TextFormFieldWidget({super.key,required this.hint,this.realTimeCheck,this.help, this.lable,this.preIcon,this.sufIcon,required this.controller,this.obScure=false, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) => realTimeCheck,
      validator: validator,
      controller: controller,
      obscureText:obScure ,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        hintText:hint ,
        labelText: lable,
        prefixIcon: Icon(preIcon),
        suffixIcon: sufIcon,
        helperText: help
        
        
      ),
    ) ;
  }
}