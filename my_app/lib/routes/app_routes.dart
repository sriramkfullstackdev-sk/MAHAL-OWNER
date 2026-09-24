import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/mahal_details/mahal_details_page.dart';
import '../screens/mahal_address/mahal_address_page.dart';
import '../screens/owner_details/owner_details_page.dart';
import '../screens/owner_home/owner_home_page.dart';
import '../screens/owner_profile/owner_profile_page.dart';
import '../screens/booking_details/booking_details_page.dart';
import '../screens/bank_account/bank_account_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String ownerDetails = '/owner-details';
  static const String mahalDetails = '/mahal-details';
  static const String ownerHome = '/owner-home';
  static const String mahalAddress = '/mahal-address';
  static const String ownerProfile = '/owner-profile';
  static const String bookingDetails = '/booking-details';
  static const String bankAccount = '/bank-account';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    ownerDetails: (context) => const OwnerDetailsPage(),
    ownerHome: (context) => const OwnerHomePage(),
    mahalDetails: (context) => const MahalDetailsPage(),
    mahalAddress: (context) => const MahalAddressPage(),
    ownerProfile: (context) => const OwnerProfilePage(),
    bookingDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return BookingDetailsPage(bookingId: args?['bookingId'] ?? '');
    },
    bankAccount: (context) => const BankAccountPage(),
  };
}
