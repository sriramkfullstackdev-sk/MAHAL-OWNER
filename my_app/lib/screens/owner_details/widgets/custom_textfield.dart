import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.hintText,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(

        hintText: hintText,

        filled: true,

        fillColor: Colors.grey.shade300,

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(0),

          borderSide: BorderSide.none,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 18,
        ),
      ),
    );
  }
}