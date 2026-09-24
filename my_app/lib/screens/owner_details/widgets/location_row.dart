import 'package:flutter/material.dart';

class LocationRow extends StatelessWidget {
  final TextEditingController? pincodeController;
  final TextEditingController? cityController;

  const LocationRow({
    super.key,
    this.pincodeController,
    this.cityController,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        /// PINCODE
        Expanded(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(
                "Pincode",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 55,
                child: TextField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    hintText: 'Enter pincode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        /// TOWN / CITY
        Expanded(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Text(
                "Town/city",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 55,
                child: TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    hintText: 'Enter city',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}