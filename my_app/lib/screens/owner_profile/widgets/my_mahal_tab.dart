import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/owner_standard_button.dart';

/// Displays the Mahal details section for the "My Mahal" tab.
class MyMahalTab extends StatelessWidget {
  const MyMahalTab({
    super.key,
    required this.mahalName,
    required this.capacity,
    required this.pricePerDay,
    required this.address,
    required this.onEditMahal,
    required this.onAddMahal,
  });

  final String mahalName;
  final String capacity;
  final String pricePerDay;
  final String address;
  final VoidCallback onEditMahal;
  final VoidCallback onAddMahal;

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mahal Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Mahal Name', mahalName),
              _buildDetailRow('Capacity', capacity),
              _buildDetailRow('Price / Day', pricePerDay),
              _buildDetailRow('Address', address),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OwnerStandardButton.text(
                text: 'Edit Mahal',
                onPressed: onEditMahal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OwnerStandardButton.text(
                text: 'Add Mahal',
                onPressed: onAddMahal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
