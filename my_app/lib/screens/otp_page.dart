import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/mobile_number_field.dart';
import '../widgets/send_otp_button.dart';
import 'verify_otp_page.dart';
import '../services/auth_service.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final phoneController = TextEditingController();

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    final mobileCheck = await AuthService.checkMobile(phone);
    if (mobileCheck["success"] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mobileCheck["message"] ?? 'Unable to check mobile number')),
      );
      return;
    }

    final response = await AuthService.sendOtp(phone);

    if(response["success"] == true){

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpPage(
            phone: phone,
          ),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
        ),
      );

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Enter Mobile Number')),
      body: Center(
        child: Container(
          width: 350,
          height: 750,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MobileNumberField(controller: phoneController,),

              const SizedBox(height: 60),

              SendOtpButton(
                onPressed: () {
                  sendOtp();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}