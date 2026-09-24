import 'package:flutter/material.dart';

/// Booking information model used across the owner profile dashboard.
class BookingInfo {
  BookingInfo({
    required this.userName,
    required this.eventName,
    required this.bookingDate,
    required this.status,
  });

  final String userName;
  final String eventName;
  final String bookingDate;
  final String status;
}

/// Statistic payload used in the statistics dashboard cards.
class StatisticInfo {
  StatisticInfo({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
}
