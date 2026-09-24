import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api_constants.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../widgets/owner_standard_button.dart';
import 'widgets/logout_button.dart';
import 'widgets/my_mahal_tab.dart';
import 'widgets/profile_header.dart';

/// Owner Profile Dashboard Page for Mahal Spot with a premium presentation.
class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: const SafeArea(child: OwnerProfileContent(showBackButton: true)),
    );
  }
}

class OwnerProfileContent extends StatefulWidget {
  const OwnerProfileContent({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<OwnerProfileContent> createState() => _OwnerProfileContentState();
}

class _OwnerProfileContentState extends State<OwnerProfileContent> {
  bool isLoading = true;

  String ownerName = "Loading...";
  String ownerCity = "";

  String mahalName = "No Mahal registered";
  String capacity = "0";
  String pricePerDay = "₹0";
  String address = "";
  String mahalId = "";

  @override
  void initState() {
    super.initState();
    _fetchProfileAndBookings();
  }

  Future<void> _fetchProfileAndBookings() async {
    try {
      final profileResponse = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/profile"),
        headers: { "Authorization": "Bearer ${ApiConstants.token}" },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);

        final profileInfo = profileData['profile'] ?? {};
        final mahalInfo = profileData['mahal'] ?? {};

        setState(() {
          ownerName = profileInfo['owner_name'] ?? 'Owner Name';
          ownerCity = profileInfo['city'] ?? '';

          if (profileData['mahal'] != null) {
            mahalId = mahalInfo['mahal_id'] ?? '';
            mahalName = mahalInfo['mahal_name'] ?? 'Mahal Name';
            capacity = "Up to ${mahalInfo['mahal_seating_capcity'] ?? '0'} guests";
            pricePerDay = "₹${mahalInfo['mahal_price'] ?? '0'} / day";
            address = mahalInfo['mahal_address'] ?? 'No address';
            ApiConstants.mahalId = mahalId;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from Mahal Spot?',
          ),
          actions: [
            SizedBox(
              width: 120,
              child: OwnerStandardButton.text(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            SizedBox(
              width: 120,
              child: OwnerStandardButton.text(
                text: 'Logout',
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.clearSession();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          ProfileHeader(
            profileImageUrl: mahalId.isNotEmpty
                ? '${ApiConstants.mahalUrl}/$mahalId/image'
                : 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85',
            title: ownerName,
            subtitle: ownerCity.isNotEmpty ? "Owner in $ownerCity" : 'Mahal Owner',
            isVerified: true,
          ),

          const SizedBox(height: 24),

          MyMahalTab(
            mahalName: mahalName,
            capacity: capacity,
            pricePerDay: pricePerDay,
            address: address,
            onEditMahal: () => Navigator.of(context)
                .pushNamed(AppRoutes.mahalDetails)
                .then((_) => _fetchProfileAndBookings()),
            onAddMahal: () => Navigator.of(context)
                .pushNamed(AppRoutes.mahalDetails)
                .then((_) => _fetchProfileAndBookings()),
          ),

          const SizedBox(height: 30),

          // Logout Button
          LogoutButton(onPressed: _confirmLogout),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
