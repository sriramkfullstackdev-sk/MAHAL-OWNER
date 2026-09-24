import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Common button style for normal actions in the owner app.
class OwnerStandardButton extends StatelessWidget {
  const OwnerStandardButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? AppColors.primaryGradient
                : LinearGradient(colors: [Colors.grey, Colors.grey.shade400]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 56,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  factory OwnerStandardButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    bool enabled = true,
  }) {
    return OwnerStandardButton(
      key: key,
      onPressed: onPressed,
      width: width,
      enabled: enabled,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
