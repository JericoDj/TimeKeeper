import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'Controller/attendance_controller.dart';
import 'Screens/clockin_clockout.dart';
import 'Screens/manager_dashboard.dart';
import 'Screens/timecard.dart';
import 'Screens/widgets/edit_timecard.dart';
import 'Screens/widgets/view_and_edit.dart';
import 'firebase_options.dart'; // Import FirebaseOptions
import 'Controller/auth_controller.dart';
import 'Screens/authentication.dart';
import 'Screens/Mainscreen.dart';
import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the correct options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Initialize AuthController using Get.put
  Get.put(AuthController());
  Get.put(AttendanceController());

  runApp(TimeKeeperApp());
}

class TimeKeeperApp extends StatelessWidget {
  final bool isUserSignedIn = FirebaseAuth.instance.currentUser != null;
  @override
  Widget build(BuildContext context) {
    // Set up GoRouter for URL-based navigation
    final GoRouter router = GoRouter(
      initialLocation: isUserSignedIn ? '/home' : '/',

      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AuthScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => MainScreen(),
        ),
        GoRoute(
          path: '/clockin-clockout',
          builder: (context, state) => ClockInOutScreen(),
        ),
        GoRoute(
          path: '/timecard',
          builder: (context, state) => TimecardScreen(),
        ),
        GoRoute(
          path: '/manager-dashboard',
          builder: (context, state) => ManagerDashboard(),
        ),

        GoRoute(
          path: '/view-timecard',
          builder: (context, state) {
            // Extract query parameters from the state
            final employeeId = state.uri.queryParameters['employeeId'] ?? '';
            final employeeName = state.uri.queryParameters['employeeName'] ?? 'Unknown';
            return ViewTimecardScreen(
              employeeId: employeeId,
              employeeName: employeeName,
            );
          },
        ),
      ],
    );

    // Use GetMaterialApp for state management and Router for navigation
    // Main Application setup
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Timekeeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
