import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),

      decoration: BoxDecoration(

        color: const Color(0xFFE5DFE8),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(

        children: [

          Icon(Icons.menu),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),

              child: TextField(
                onChanged: onChanged,

                decoration: const InputDecoration(
                  hintText: "search",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Icon(Icons.search),
        ],
      ),
    );
  }
}