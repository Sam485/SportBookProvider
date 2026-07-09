import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/DashBoard/Notification/notification_screen.dart';
import 'package:flutter_application_1/screens/auth/landing_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/auth/signup_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/operating_hour_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/payout_banking_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/personal_info_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/password_security_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/reviews_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/settings_screen.dart';
import 'package:flutter_application_1/screens/settings/Features/venue_photos_screen.dart';
import 'package:flutter_application_1/screens/splash/splash_screen.dart';

class AppRoutes {
  static const home = '/mainScreen';
  static const landing = '/';
  static const signUp = '/signup';
  static const login = '/login';
  static const forget = '/forget';
  static const verify = '/verify';
  static const createProfile = '/createProfile';
  static const splash = '/splash';

  // Settings and Profile routes
  static const setting = '/settings';
  static const personalInfo = '/personal-info';
  static const payment = '/payment';
  static const notifications = '/notifications';
  static const passAndSecurity = '/password-security';
  static const operatingHours = '/operating-hours';
  static const reviews = '/reviews';
  static const venuePhotos = '/venue-photos';
  static const editVenueProfile = '/edit-venue-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case operatingHours:
        return MaterialPageRoute(builder: (_) => const OperatingHourScreen());

      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case personalInfo:
        return MaterialPageRoute(builder: (_) => const PersonalInfoScreen());

      case payment:
        return MaterialPageRoute(builder: (_) => const PayoutBankingScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case passAndSecurity:
        return MaterialPageRoute(
          builder: (_) => const PasswordSecurityScreen(),
        );

      case reviews:
        return MaterialPageRoute(builder: (_) => const ReviewsScreen());

      case venuePhotos:
        return MaterialPageRoute(builder: (_) => const VenuePhotosScreen());

      case editVenueProfile:
        return MaterialPageRoute(builder: (_) => const VenuePhotosScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route ${settings.name} not found',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}
