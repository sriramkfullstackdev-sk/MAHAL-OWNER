import 'package:flutter/material.dart';
import '../../../widgets/owner_standard_button.dart';

class FinishButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const FinishButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OwnerStandardButton.text(
      text: 'Next',
      onPressed: onPressed,
      enabled: isEnabled,
    );
  }
}
