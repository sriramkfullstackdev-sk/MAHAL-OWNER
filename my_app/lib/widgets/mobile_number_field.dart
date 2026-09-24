import 'package:flutter/material.dart';

class MobileNumberField extends StatelessWidget {
  final TextEditingController controller;

  const MobileNumberField({super.key,required this.controller,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: TextField(
         controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your mobile number",
          hintStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}