import 'package:flutter/material.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'routes/app_routes.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSession = await AuthService.restoreSession();
  final navigatorKey = GlobalKey<NavigatorState>();
  final initialBookingId = await FcmService().initialize(navigatorKey);
  runApp(MyApp(
    hasSession: hasSession,
    navigatorKey: navigatorKey,
    initialBookingId: initialBookingId,
  ));
}

class MyApp extends StatelessWidget {
  final bool hasSession;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialBookingId;

  const MyApp({
    super.key,
    this.hasSession = false,
    this.navigatorKey,
    this.initialBookingId,
  });

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange1),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.orange1,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      navigatorKey: navigatorKey,
        initialRoute: !hasSession
          ? AppRoutes.login
          : AuthService.registrationComplete
            ? AppRoutes.ownerHome
            : AppRoutes.ownerDetails,
      routes: AppRoutes.routes,
    );

    if (initialBookingId == null || !hasSession) return app;

    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey?.currentState?.pushNamed(
            AppRoutes.bookingDetails,
            arguments: {'bookingId': initialBookingId},
          );
        });
        return app;
      },
    );
  }
}