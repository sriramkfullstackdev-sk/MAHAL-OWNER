import 'package:flutter/material.dart';
import '../../../widgets/owner_standard_button.dart';

class RegisterButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String label;

  const RegisterButton({super.key, this.isEnabled = true, this.onPressed, this.label = "Register"});

  @override
  Widget build(BuildContext context) {
    return OwnerStandardButton.text(
      text: label,
      onPressed: onPressed,
      enabled: isEnabled,
    );
  }
}
