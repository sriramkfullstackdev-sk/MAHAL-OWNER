import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api_constants.dart';
import '../booking_details/booking_details_page.dart';
import 'widgets/request_card.dart';

class TotalBookingsPage extends StatefulWidget {
  const TotalBookingsPage({super.key});

  @override
  State<TotalBookingsPage> createState() => _TotalBookingsPageState();
}

class _TotalBookingsPageState extends State<TotalBookingsPage> {
  bool isLoading = true;
  List<dynamic> bookingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/booking-requests"),
        headers: {"Authorization": "Bearer ${ApiConstants.token}"},
      );
      final data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        bookingRequests = response.statusCode == 200
            ? (data['requests'] ?? data['bookings'] ?? [])
            : [];
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching total bookings: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToDetails(String bookingId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsPage(bookingId: bookingId),
      ),
    );
    _fetchBookings();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'qr verified':
      case 'verified':
        return Colors.blue;
      case 'waiting for user confirmation':
      case 'waiting user confirmation':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
      case 'expired':
        return Colors.grey;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Bookings'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBookings,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookingRequests.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 260),
                      Center(child: Text('No bookings found.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingRequests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, index) {
                      final request = bookingRequests[index];
                      final bookingId = request['booking_id']?.toString();
                      final status = request['booking_status'] ?? 'Pending';
                      final visitingTime =
                          request['visiting_time'] != null && request['visiting_date'] != null
                              ? "${request['visiting_date']} (${request['visiting_time']})"
                              : (request['visiting_time'] ?? 'Not Selected');

                      return RequestCard(
                        name: request['user_name'] ?? 'Guest',
                        eventName: request['event_name'] ?? 'Event',
                        eventDate: request['booking_date'] ?? 'N/A',
                        bookingTime: request['event_time'] ?? 'N/A',
                        visitingTime: visitingTime,
                        status: status,
                        statusColor: _getStatusColor(status),
                        onTap: bookingId == null ? null : () => _navigateToDetails(bookingId),
                      );
                    },
                  ),
      ),
    );
  }
}
