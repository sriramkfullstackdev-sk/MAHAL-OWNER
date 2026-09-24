import 'package:flutter/material.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [

        Text(
          "WELCOME",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),

        SizedBox(height: 15),

        Text(
          "MAHAL SPOT",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}