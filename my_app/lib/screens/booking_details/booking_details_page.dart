import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/api_constants.dart';
import '../scan_qr/scan_qr_page.dart';
import '../../utils/app_colors.dart';
import '../../widgets/owner_standard_button.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  bool isLoading = true;
  bool isActionLoading = false;
  Map<String, dynamic>? bookingData;
  String? errorMessage;

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty || value == 'N/A') return 'N/A';
    final date = DateTime.tryParse(value.trim());
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}';
  }

  String _formatTime(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])').firstMatch(value);
    if (match == null) return value;

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!.toLowerCase();
    if (period == 'pm' && hour < 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour.$minute ${hour >= 12 ? 'pm' : 'am'}';
  }

  String _formatVisitingDateTime(String? dateValue, String? timeValue) {
    if (dateValue == null || dateValue.trim().isEmpty || dateValue == 'Not Selected') {
      return 'Not Selected';
    }

    final date = DateTime.tryParse(dateValue.trim());
    if (date == null) return timeValue ?? dateValue;

    var result = '${_formatDate(dateValue)}, ${_weekdays[date.weekday - 1]}';
    final time = timeValue?.trim() ?? '';
    if (time.isNotEmpty && time != 'Not Selected') {
      result += '\n${_formatTime(time)}';
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/booking-details/${widget.bookingId}"),
        headers: {"Authorization": "Bearer ${ApiConstants.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['booking'] != null) {
          if (!mounted) return;
          setState(() {
            bookingData = data['booking'];
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load booking details.';
            isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _promptScanQr() async {
    final String? qrToken = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => const ScanQrPage()),
    );

    if (qrToken != null && qrToken.trim().isNotEmpty) {
      _executeScanQr(qrToken.trim());
    }
  }

  Future<void> _executeScanQr(String qrToken) async {
    setState(() {
      isActionLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.ownerUrl}/scan-qr"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "booking_id": widget.bookingId,
          "qr_token": qrToken,
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("QR Verified Successfully! You can now Accept or Reject the booking."),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 4),
          ),
        );
        _fetchBookingDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'QR Verification Failed.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning QR: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> _acceptBooking() async {
    setState(() {
      isActionLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.ownerUrl}/accept"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "booking_id": widget.bookingId,
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking Approved by Owner! User notification sent for final confirmation."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        _fetchBookingDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to accept booking.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> _rejectBooking() async {
    setState(() {
      isActionLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.ownerUrl}/reject"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({"booking_id": widget.bookingId}),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200 && data['success'] == true
                ? 'Booking rejected successfully.'
                : (data['message'] ?? 'Failed to reject booking.'),
          ),
          backgroundColor: response.statusCode == 200 && data['success'] == true
              ? Colors.red
              : Colors.orange,
        ),
      );
      if (response.statusCode == 200 && data['success'] == true) {
        _fetchBookingDetails();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepOrange, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? const Color(0xFF212121),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
      case 'pending':
      case 'payment completed':
      case 'visiting time selected':
      case 'visit pending':
      default:
        return Colors.amber;
    }
  }

  String _normalizeStatus(dynamic value) => (value ?? '').toString().trim();

  @override
  Widget build(BuildContext context) {
    final userDetails = bookingData?['user_details'] ?? {};
    final eventDetails = bookingData?['event_details'] ?? {};
    final additionalDetails = bookingData?['additional_details'] ?? {};

    final String currentStatus = _normalizeStatus(bookingData?['booking_status'] ?? additionalDetails['booking_status'] ?? 'Pending');
    final String normalizedStatus = currentStatus.toLowerCase();
    final bool isQrVerified = bookingData?['qr_verified'] == true ||
        normalizedStatus.contains('qr verified') ||
        normalizedStatus.contains('waiting for user confirmation') ||
        normalizedStatus.contains('waiting user confirmation') ||
        normalizedStatus.contains('confirmed') ||
        normalizedStatus.contains('verified');
      final bool ownerAccepted = bookingData?['owner_decision'] == 'Accepted' ||
        normalizedStatus.contains('waiting for user confirmation');
      final bool canShowActionButtons = !['confirmed', 'rejected', 'cancelled'].contains(normalizedStatus) &&
        !ownerAccepted;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        OwnerStandardButton.text(
                          text: 'Retry',
                          onPressed: _fetchBookingDetails,
                          width: 140,
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// STATUS BANNER
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentStatus).withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(currentStatus).withAlpha(100),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  currentStatus.toLowerCase() == 'confirmed'
                                      ? Icons.check_circle
                                      : currentStatus.toLowerCase() == 'rejected'
                                          ? Icons.cancel
                                          : currentStatus.toLowerCase() == 'qr verified'
                                              ? Icons.verified
                                              : currentStatus.toLowerCase().contains('waiting')
                                                  ? Icons.hourglass_bottom
                                                  : Icons.hourglass_top,
                                  color: _getStatusColor(currentStatus),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Current Booking Status",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF616161),
                                        ),
                                      ),
                                      Text(
                                        currentStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(currentStatus),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// USER DETAILS CARD
                          _buildSectionCard(
                            title: "User Details",
                            icon: Icons.person_outline,
                            children: [
                              _buildDetailRow("User Name", bookingData?['user_name'] ?? userDetails['user_name'] ?? 'N/A', isBold: true),
                              _buildDetailRow("Mobile Number", bookingData?['mbl_no'] ?? userDetails['mbl_no'] ?? 'N/A'),
                              _buildDetailRow("Email", bookingData?['email'] ?? userDetails['email'] ?? 'N/A'),
                            ],
                          ),

                          /// EVENT DETAILS CARD
                          _buildSectionCard(
                            title: "Event Details",
                            icon: Icons.event_available_outlined,
                            children: [
                              _buildDetailRow("Event Name", bookingData?['event_name'] ?? eventDetails['event_name'] ?? 'N/A', isBold: true),
                              _buildDetailRow(
                                "Event Date",
                                _formatDate(
                                  (bookingData?['booking_date'] ?? eventDetails['event_date'])?.toString(),
                                ),
                              ),
                              _buildDetailRow(
                                "End Date",
                                _formatDate(
                                  (bookingData?['end_date'] ?? eventDetails['end_date'])?.toString(),
                                ),
                              ),
                              _buildDetailRow("Start Time", bookingData?['event_time'] ?? eventDetails['start_time'] ?? 'N/A'),
                              _buildDetailRow("End Time", bookingData?['end_time'] ?? bookingData?['event_end_time'] ?? eventDetails['end_time'] ?? 'N/A'),
                            ],
                          ),

                          /// VISITING & QR DETAILS CARD
                          _buildSectionCard(
                            title: "Visiting & QR Details",
                            icon: Icons.qr_code_2_outlined,
                            children: [
                              _buildDetailRow(
                                "Visiting Time",
                                _formatVisitingDateTime(
                                  (bookingData?['visiting_date'] ?? bookingData?['visit_date'] ?? bookingData?['date'])?.toString(),
                                  (bookingData?['visiting_time'] ?? bookingData?['visit_time'] ?? bookingData?['time'])?.toString(),
                                ),
                                isBold: true,
                              ),
                              _buildDetailRow("Visit Status", bookingData?['visit_status'] ?? 'Scheduled'),
                              _buildDetailRow("QR Token", bookingData?['qr_token'] ?? bookingData?['qrToken'] ?? bookingData?['qr_code'] ?? 'Not Generated'),
                              if (bookingData?['rejection_reason'] != null)
                                _buildDetailRow("Rejection Reason", bookingData!['rejection_reason'], valueColor: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (isActionLoading)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),

      /// DYNAMIC BOTTOM ACTION BUTTONS
      /// Rules:
      /// 1. Initially display ONLY [ Scan QR ]. ACCEPT and REJECT buttons must NOT be visible before QR scan!
      /// 2. Only AFTER successful QR verification (isQrVerified == true), display ACCEPT and REJECT buttons.
      bottomNavigationBar: (!isLoading && errorMessage == null && canShowActionButtons)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: !isQrVerified
                    ? SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isActionLoading ? null : _promptScanQr,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE3F2FD),
                            foregroundColor: const Color(0xFF0D47A1),
                            disabledBackgroundColor: const Color(0xFFE0E0E0),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner, size: 21),
                              SizedBox(width: 10),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'SCAN CUSTOMER QR',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isActionLoading ? null : _rejectBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "REJECT",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isActionLoading ? null : _acceptBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "ACCEPT",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : null,
    );
  }
}
