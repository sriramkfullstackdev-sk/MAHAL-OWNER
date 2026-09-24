import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../models/owner_profile_models.dart';
import 'booking_card.dart';

/// Shows the active booking cards list in the Bookings tab.
class BookingsTab extends StatelessWidget {
  const BookingsTab({
    super.key,
    required this.bookings,
  });

  final List<BookingInfo> bookings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Bookings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        if (bookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.softShadow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'No booking requests available right now.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          Column(
            children: bookings
                .map(
                  (booking) => BookingCard(
                    booking: booking,
                    onAccept: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accepted ${booking.eventName}'),
                        ),
                      );
                    },
                    onReject: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rejected ${booking.eventName}'),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
