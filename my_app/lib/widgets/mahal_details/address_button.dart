import 'package:flutter/material.dart';
import '../owner_standard_button.dart';

class AddressButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddressButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OwnerStandardButton.text(
      text: 'ADDRESS',
      onPressed: onPressed,
    );
  }
}