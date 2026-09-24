import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/option_card.dart';
import 'widgets/welcome_title.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// WELCOME TEXT
              const WelcomeTitle(),

              const SizedBox(height: 40),

              /// BUTTONS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// REGISTER
                  OptionCard(
                    title: "Register\nYour Mahal",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.ownerDetails);
                    },
                  ),

                  const SizedBox(width: 30),

                  /// BOOKING
                  OptionCard(
                    title: "Booking\nMahal",
                    onTap: () {

                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}