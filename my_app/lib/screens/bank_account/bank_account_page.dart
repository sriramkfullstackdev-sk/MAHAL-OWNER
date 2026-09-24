import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api_constants.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/owner_standard_button.dart';
import '../mahal_address/widgets/custom_textfield.dart';

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankNameController = TextEditingController();
  final ifscController = TextEditingController();
  final branchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBankAccount();
  }

  @override
  void dispose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    ifscController.dispose();
    branchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBankAccount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.ownerUrl}/bank-account'),
        headers: {'Authorization': 'Bearer ${ApiConstants.token}'},
      );
      if (response.statusCode != 200 || !mounted) return;

      final data = jsonDecode(response.body);
      final account = data['account'] ?? {};
      accountHolderController.text = account['account_holder_name'] ?? '';
      accountNumberController.text = account['account_number'] ?? '';
      bankNameController.text = account['bank_name'] ?? '';
      ifscController.text = account['ifsc_code'] ?? '';
      branchController.text = account['branch_name'] ?? '';
    } catch (error) {
      debugPrint('Error fetching bank account: $error');
    }
  }

  Future<void> _saveBankAccount() async {
    final accountHolder = accountHolderController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final bankName = bankNameController.text.trim();
    final ifsc = ifscController.text.trim().toUpperCase();
    final branch = branchController.text.trim();

    if ([accountHolder, accountNumber, bankName, ifsc, branch].any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all bank account details.')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.ownerUrl}/bank-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.token}',
        },
        body: jsonEncode({
          'account_holder_name': accountHolder,
          'account_number': accountNumber,
          'bank_name': bankName,
          'ifsc_code': ifsc,
          'branch_name': branch,
        }),
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        await AuthService.setRegistrationComplete(true);
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.ownerHome, (route) => false);
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to save bank details.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bank details: $error')),
      );
    }
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        CustomTextField(controller: controller, hintText: 'Enter $label', keyboardType: keyboardType),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Owner Bank Account'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add your bank account details to complete registration.'),
            const SizedBox(height: 28),
            _field('Account Holder Name', accountHolderController),
            const SizedBox(height: 20),
            _field('Account Number', accountNumberController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _field('Bank Name', bankNameController),
            const SizedBox(height: 20),
            _field('IFSC Code', ifscController),
            const SizedBox(height: 20),
            _field('Branch Name', branchController),
            const SizedBox(height: 40),
            OwnerStandardButton(
              onPressed: _saveBankAccount,
              enabled: !isLoading,
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Register', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
