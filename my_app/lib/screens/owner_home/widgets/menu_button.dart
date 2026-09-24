import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {

  final String title;
  final bool isGradient;

  const MenuButton({
    super.key,
    required this.title,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 155,
      height: 80,

      decoration: BoxDecoration(

        color: isGradient ? null : Colors.grey.shade300,

        gradient: isGradient
            ? const LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.deepOrange,
                ],
              )
            : null,

        borderRadius: BorderRadius.circular(35),
      ),

      child: Center(

        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}