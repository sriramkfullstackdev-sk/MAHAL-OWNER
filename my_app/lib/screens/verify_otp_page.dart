import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_constants.dart';
import '../routes/app_routes.dart';
import '../services/fcm_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class VerifyOtpPage extends StatefulWidget {
  final String phone;
  final String? sentOtp;

  const VerifyOtpPage({super.key, required this.phone, this.sentOtp});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final enteredOtp = otpController.text.trim();

    if (enteredOtp.isEmpty || enteredOtp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': widget.phone,
          'otp': enteredOtp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ApiConstants.token = data['token'];
        ApiConstants.phone = widget.phone;
        final owner = data['owner'];
        if (owner != null) {
          ApiConstants.mahalownerId = owner['mahalowner_id']?.toString();
        }

        await AuthService.saveSession(
          token: ApiConstants.token!,
          phone: ApiConstants.phone!,
          ownerId: ApiConstants.mahalownerId,
        );

        await FcmService().registerCurrentDevice();

        if (!mounted) return;
        final isExistingOwner = data['isExistingOwner'] == true || (owner != null && (owner['owner_name'] ?? '').toString().trim().isNotEmpty);
        await AuthService.setRegistrationComplete(isExistingOwner);
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          isExistingOwner ? AppRoutes.ownerHome : AppRoutes.ownerDetails,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP verification failed.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Phone: ${widget.phone}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              if (widget.sentOtp != null && widget.sentOtp!.isNotEmpty) ...[
                Text(
                  'Sent OTP (for testing): ${widget.sentOtp!}',
                  style: const TextStyle(fontSize: 18, color: Colors.green),
                ),
                const SizedBox(height: 20),
              ],
              rowWithOtpField(),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Resend OTP ?',
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Verify OTP',
                onPressed: verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowWithOtpField() {
    return Column(
      children: [
        const Text('Enter OTP', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          width: 220,
          child: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter 4-digit OTP',
            ),
          ),
        ),

      ],
    );
  }
}