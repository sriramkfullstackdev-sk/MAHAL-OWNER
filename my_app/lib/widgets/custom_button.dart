import 'package:flutter/material.dart';
import 'owner_standard_button.dart';

class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return OwnerStandardButton.text(
      text: text,
      onPressed: onPressed,
    );
  }
}