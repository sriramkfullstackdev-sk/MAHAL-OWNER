import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api_constants.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import 'widgets/custom_textfield.dart';
import 'widgets/state_dropdown.dart';
import 'widgets/terms_checkbox.dart';
import 'widgets/register_button.dart';

class MahalAddressPage extends StatefulWidget {
  const MahalAddressPage({super.key});

  @override
  State<MahalAddressPage> createState() => _MahalAddressPageState();
}

class _MahalAddressPageState extends State<MahalAddressPage> {
  String? selectedState;
  bool isChecked = false;

  final List<String> states = [
    "Tamil Nadu",
    "Kerala",
    "Karnataka",
    "Andhra Pradesh",
  ];

  final TextEditingController buildingController = TextEditingController();
  final TextEditingController doorNoController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMahalAddress();
  }

  Future<void> _fetchMahalAddress() async {
    if (ApiConstants.token == null) return;
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
        if (data['success'] == true && data['mahal'] != null) {
          final mahal = data['mahal'];
          final String fullAddr = mahal['mahal_address'] ?? '';
          final String city = mahal['city'] ?? '';

          String doorNo = '';
          String building = '';
          String area = '';
          String pincode = '';

          if (fullAddr.isNotEmpty) {
            String temp = fullAddr;
            if (temp.contains('Pincode:')) {
              final pinParts = temp.split('Pincode:');
              pincode = pinParts.last.trim();
              temp = pinParts.first.trim();
              if (temp.endsWith(',')) {
                temp = temp.substring(0, temp.length - 1).trim();
              }
            }
            if (temp.contains('Door No:')) {
              final doorParts = temp.split('Door No:');
              final rest = doorParts.last.trim();
              final commaParts = rest.split(',');
              if (commaParts.isNotEmpty) {
                doorNo = commaParts.first.trim();
                if (commaParts.length > 1) {
                  building = commaParts[1].trim();
                }
                if (commaParts.length > 2) {
                  area = commaParts.sublist(2).join(',').trim();
                }
              }
            } else {
              final parts = temp.split(',');
              if (parts.isNotEmpty) building = parts.first.trim();
              if (parts.length > 1) area = parts.sublist(1).join(',').trim();
            }
          }

          setState(() {
            if (doorNo.isNotEmpty) doorNoController.text = doorNo;
            if (building.isNotEmpty) buildingController.text = building;
            if (area.isNotEmpty) areaController.text = area;
            if (pincode.isNotEmpty) pincodeController.text = pincode;
            if (city.isNotEmpty) cityController.text = city;
            if (fullAddr.isNotEmpty || city.isNotEmpty) isChecked = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching mahal address: $e");
    }
  }

  @override
  void dispose() {
    buildingController.dispose();
    doorNoController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    final building = buildingController.text.trim();
    final doorNo = doorNoController.text.trim();
    final area = areaController.text.trim();
    final pincode = pincodeController.text.trim();
    final city = cityController.text.trim();

    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Town/City is a required field.')),
      );
      return;
    }

    try {
      final addressText = "Door No: $doorNo, $building, $area, Pincode: $pincode";

      final response = await http.post(
        Uri.parse("${ApiConstants.mahalUrl}/address"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "mahal_address": addressText,
          "city": city,
        }),
      );

      final data = jsonDecode(response.body);
  if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushNamed(context, AppRoutes.bankAccount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to save address details.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Mahal Address')),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              /// ADDRESS
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
                controller: buildingController,
              ),

              const SizedBox(height: 20),

              const Text("Door No :", style: TextStyle(fontSize: 14)),

              const SizedBox(height: 8),

              CustomTextField(
                controller: doorNoController,
              ),

              const SizedBox(height: 20),

              const Text(
                "Area,Street,Sector,Village",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              CustomTextField(
                controller: areaController,
              ),

              const SizedBox(height: 20),

              /// PINCODE + CITY
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text("Pincode", style: TextStyle(fontSize: 14)),

                        const SizedBox(height: 8),

                        CustomTextField(
                          controller: pincodeController,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text("Town/city", style: TextStyle(fontSize: 14)),

                        const SizedBox(height: 8),

                        CustomTextField(
                          controller: cityController,
                        ),
                      ],
                    ),
                  ),
                ],
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

              const SizedBox(height: 30),

              /// TERMS CHECKBOX
              TermsCheckbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),

              const SizedBox(height: 60),

              /// REGISTER BUTTON
              Center(
                child: RegisterButton(
                  label: "Account Details",
                  isEnabled: isChecked,
                  onPressed: _saveAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
