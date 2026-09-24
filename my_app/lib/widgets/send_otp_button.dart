import 'package:flutter/material.dart';
import 'owner_standard_button.dart';

class SendOtpButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SendOtpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OwnerStandardButton.text(
      text: 'sent OTP',
      onPressed: onPressed,
    );
  }
}