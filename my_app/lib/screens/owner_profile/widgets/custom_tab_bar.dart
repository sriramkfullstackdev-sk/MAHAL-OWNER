import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

/// Custom tab control for switching between My Mahal and Bookings.
class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  Widget _buildTab(BuildContext context, String title, int index) {
    final bool selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: 56,
          margin: EdgeInsets.only(right: index == 0 ? 12 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.cardBackground,
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.softShadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
            border: selected
                ? null
                : Border.all(color: AppColors.textSecondary.withOpacity(0.16)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTab(context, 'My Mahal', 0),
        _buildTab(context, 'Bookings', 1),
      ],
    );
  }
}
