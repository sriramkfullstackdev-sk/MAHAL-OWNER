import 'package:flutter/material.dart';
import '../../../widgets/owner_standard_button.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// CIRCLE
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.black54,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// BUTTON
        OwnerStandardButton(
          width: 130,
          onPressed: onTap,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}