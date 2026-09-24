import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/api_constants.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/location_row.dart';
import 'widgets/state_dropdown.dart';
import 'widgets/finish_button.dart';
import '../mahal_address/widgets/terms_checkbox.dart';

class OwnerDetailsPage extends StatefulWidget {
  const OwnerDetailsPage({super.key});

  @override
  State<OwnerDetailsPage> createState() => _OwnerDetailsPageState();
}

class _OwnerDetailsPageState extends State<OwnerDetailsPage> {
  bool isChecked = false;

  String? selectedState;

  final List<String> states = [
    "Tamil Nadu",
    "Kerala",
    "Karnataka",
    "Andhra Pradesh",
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController flatController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = ApiConstants.phone ?? '';
    _fetchOwnerProfile();
  }

  Future<void> _fetchOwnerProfile() async {
    if (ApiConstants.token == null) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['profile'] != null) {
          final profile = data['profile'];
          final String name = profile['owner_name'] ?? '';
          final String phone = profile['mbl_no'] ?? ApiConstants.phone ?? '';
          final String city = profile['city'] ?? '';
          final String fullAddress = profile['address'] ?? '';

          String flat = '';
          String area = '';
          String pincode = '';

          if (fullAddress.isNotEmpty) {
            String tempAddress = fullAddress;
            if (tempAddress.contains('Pincode:')) {
              final pinParts = tempAddress.split('Pincode:');
              pincode = pinParts.last.trim();
              tempAddress = pinParts.first.trim();
              if (tempAddress.endsWith(',')) {
                tempAddress = tempAddress.substring(0, tempAddress.length - 1).trim();
              }
            }
            final addressParts = tempAddress.split(',');
            if (addressParts.isNotEmpty) {
              flat = addressParts.first.trim();
              if (addressParts.length > 1) {
                area = addressParts.sublist(1).join(',').trim();
              }
            }
          }

          setState(() {
            if (name.isNotEmpty) nameController.text = name;
            if (phone.isNotEmpty) phoneController.text = phone;
            if (city.isNotEmpty) cityController.text = city;
            if (flat.isNotEmpty) flatController.text = flat;
            if (area.isNotEmpty) areaController.text = area;
            if (pincode.isNotEmpty) pincodeController.text = pincode;
            if (name.isNotEmpty) isChecked = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching owner profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    flatController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final flat = flatController.text.trim();
    final area = areaController.text.trim();
    final pincode = pincodeController.text.trim();
    final city = cityController.text.trim();

    if (name.isEmpty || phone.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, Phone, and City are required fields.')),
      );
      return;
    }

    try {
      final fullAddress = "$flat, $area, Pincode: $pincode";
      
      final response = await http.post(
        Uri.parse("${ApiConstants.ownerUrl}/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "owner_name": name,
          "address": fullAddress,
          "city": city,
          "mbl_no": phone,
        }),
      );

      final data = jsonDecode(response.body);
  if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushNamed(context, AppRoutes.mahalDetails);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to save owner profile.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Owner Details')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              /// OWNER NAME
              CustomTextField(
                hintText: "Mahal owner name",
                controller: nameController,
              ),

              const SizedBox(height: 15),

              /// MOBILE NUMBER
              CustomTextField(
                hintText: "mobile number",
                keyboardType: TextInputType.phone,
                controller: phoneController,
              ),

              const SizedBox(height: 15),

              /// ADDRESS TITLE
              const Text(
                "Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 10),

              const Text(
                "Flat ,House no ,Building,Company,Apartment",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              CustomTextField(
                controller: flatController,
              ),

              const SizedBox(height: 15),

              const Text(
                "Area,Street,Sector,Village",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              CustomTextField(
                controller: areaController,
              ),

              const SizedBox(height: 35),

              //const CustomTextField(),
              const SizedBox(height: 10),

              /// PINCODE + CITY
              LocationRow(
                pincodeController: pincodeController,
                cityController: cityController,
              ),

              const SizedBox(height: 30),

              /// STATE DROPDOWN
              StateDropdown(
                value: selectedState,
                items: states,
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              /// TERMS CHECKBOX
              TermsCheckbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),

              const SizedBox(height: 40),

              /// FINISH BUTTON
              Center(
                child: FinishButton(
                  isEnabled: isChecked,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
