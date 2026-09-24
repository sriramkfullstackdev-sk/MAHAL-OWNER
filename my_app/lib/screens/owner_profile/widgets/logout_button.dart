import 'package:flutter/material.dart';

import '../../../widgets/owner_standard_button.dart';

/// Gradient logout button shown at the bottom of the owner profile page.
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OwnerStandardButton.text(
      text: 'Logout',
      onPressed: onPressed,
    );
  }
}
