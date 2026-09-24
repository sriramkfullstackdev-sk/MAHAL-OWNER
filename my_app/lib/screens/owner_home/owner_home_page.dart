import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/api_constants.dart';
import '../../utils/app_colors.dart';
import '../booking_details/booking_details_page.dart';
import '../owner_profile/owner_profile_page.dart';
import 'total_bookings_page.dart';
import 'widgets/profile_section.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/request_card.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  int selectedIndex = 0;
  bool isLoading = true;

  int totalBookings = 0;
  int confirmedBookings = 0;
  int pendingBookings = 0;
  int rejectedBookings = 0;

  List<dynamic> bookingRequests = [];
  String? selectedRequestFilter;
  String searchQuery = '';

  List<dynamic> get _newRequestNotifications => bookingRequests.where((request) {
        final status = (request['booking_status'] ?? 'Pending').toString().toLowerCase();
        return status == 'pending' ||
            status == 'payment completed' ||
            status == 'visiting time selected' ||
            status == 'visit pending';
      }).toList();

  List<dynamic> get _filteredRequests {
    return bookingRequests.where((request) {
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty || [
        request['user_name'],
        request['event_name'],
        request['booking_id'],
        request['booking_status'],
      ].any((value) => value.toString().toLowerCase().contains(query));
      final matchesDate = _matchesBookingDate(request['booking_date'], query);

      if (!matchesSearch && !matchesDate) return false;
      if (selectedRequestFilter == null || selectedRequestFilter == 'Total Bookings') {
        return true;
      }

      final status = (request['booking_status'] ?? 'Pending').toString().toLowerCase();
      switch (selectedRequestFilter) {
        case 'Pending':
          return status == 'pending' ||
              status == 'payment completed' ||
              status == 'visiting time selected' ||
              status == 'visit pending';
        case 'Confirmed':
          return status == 'confirmed';
        case 'Rejected':
          return status == 'rejected' || status == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  bool _matchesBookingDate(dynamic value, String query) {
    if (value == null || query.isEmpty) return false;

    final bookingDate = DateTime.tryParse(value.toString());
    if (bookingDate == null) return false;

    final dateQuery = query.replaceAll(RegExp(r'\s+'), '');
    final shortDateMatch = RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{2}|\d{4})$').firstMatch(dateQuery);
    if (shortDateMatch != null) {
      final day = int.parse(shortDateMatch.group(1)!);
      final month = int.parse(shortDateMatch.group(2)!);
      final yearValue = int.parse(shortDateMatch.group(3)!);
      final year = yearValue < 100 ? 2000 + yearValue : yearValue;
      return bookingDate.year == year && bookingDate.month == month && bookingDate.day == day;
    }

    final normalizedQuery = dateQuery.replaceAll('.', '-').replaceAll('/', '-');
    return bookingDate.toIso8601String().startsWith(normalizedQuery);
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final statsResponse = await http.get(
        Uri.parse("${ApiConstants.bookingsUrl}/dashboard/stats"),
        headers: { "Authorization": "Bearer ${ApiConstants.token}" },
      );

      final requestsResponse = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/booking-requests"),
        headers: { "Authorization": "Bearer ${ApiConstants.token}" },
      );

      if (statsResponse.statusCode == 200 && requestsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        final requestsData = jsonDecode(requestsResponse.body);

        if (!mounted) return;
        setState(() {
          totalBookings = statsData['total'] ?? 0;
          confirmedBookings = statsData['confirmed'] ?? 0;
          pendingBookings = statsData['pending'] ?? 0;
          rejectedBookings = statsData['rejected'] ?? 0;
          bookingRequests = requestsData['requests'] ?? requestsData['bookings'] ?? [];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }



  void _navigateToDetails(String bookingId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsPage(bookingId: bookingId),
      ),
    );

    if (result == true) {
      _fetchDashboardData();
    }
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TotalBookingsPage()),
    );
  }

  void _selectRequestFilter(String filter) {
    setState(() {
      selectedRequestFilter = filter;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      selectedRequestFilter = value.trim().isEmpty ? null : 'Total Bookings';
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (index == 0) {
      _fetchDashboardData();
    }
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

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PROFILE SECTION
            ProfileSection(onTap: () => _onBottomNavTap(1)),

            const SizedBox(height: 24),

            const Text(
              'A clean overview of your Mahal performance, bookings and requests.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
            ),

            const SizedBox(height: 22),

            SearchBarWidget(onChanged: _onSearchChanged),

            const SizedBox(height: 24),

            Row(
              children: [
                _buildDashboardCard(
                  title: 'Total Bookings',
                  value: totalBookings.toString(),
                  icon: Icons.event_available,
                  color: Colors.deepOrange,
                  onTap: () => _selectRequestFilter('Total Bookings'),
                ),
                const SizedBox(width: 16),
                _buildDashboardCard(
                  title: 'Confirmed',
                  value: confirmedBookings.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  onTap: () => _selectRequestFilter('Confirmed'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildDashboardCard(
                  title: 'Pending',
                  value: pendingBookings.toString(),
                  icon: Icons.hourglass_top,
                  color: Colors.orange,
                  onTap: () => _selectRequestFilter('Pending'),
                ),
                const SizedBox(width: 16),
                _buildDashboardCard(
                  title: 'Rejected',
                  value: rejectedBookings.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                  onTap: () => _selectRequestFilter('Rejected'),
                ),
              ],
            ),

            const SizedBox(height: 28),
            if (selectedRequestFilter != null) ...[
              Text(
                '$selectedRequestFilter List',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_filteredRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'No bookings found in this category.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._filteredRequests.map((req) {
                final String status = req['booking_status'] ?? 'Pending';
                final Color statusColor = _getStatusColor(status);
                final String visitingTime = (req['visiting_time'] != null && req['visiting_date'] != null)
                    ? "${req['visiting_date']} (${req['visiting_time']})"
                    : (req['visiting_time'] ?? 'Not Selected');

                  return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: RequestCard(
                    name: req['user_name'] ?? 'Guest',
                    eventName: req['event_name'] ?? 'Event',
                    eventDate: req['booking_date'] ?? 'N/A',
                    bookingTime: req['event_time'] ?? 'N/A',
                    visitingTime: visitingTime,
                    status: status,
                    statusColor: statusColor,
                    onTap: () => _navigateToDetails(req['booking_id'].toString()),
                  ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A7A7A)),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'Dashboard' : 'Profile'),
        actions: selectedIndex == 0
            ? [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Notifications',
                      icon: const Icon(Icons.notifications_none),
                      onPressed: _showNotifications,
                    ),
                    if (_newRequestNotifications.isNotEmpty)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            _newRequestNotifications.length > 99 ? '99+' : _newRequestNotifications.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ]
            : null,
          ),
      body: SafeArea(
        child: selectedIndex == 0
            ? _buildDashboardBody()
            : const OwnerProfileContent(showBackButton: false),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: const Color(0xFF7A7A7A),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
