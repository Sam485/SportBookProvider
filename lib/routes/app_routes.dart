import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/DashBoard/dash_board_screen.dart';
import 'package:flutter_application_1/screens/auth/forget_screen.dart';
import 'package:flutter_application_1/screens/auth/landing_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/auth/signup_screen.dart';
import 'package:flutter_application_1/screens/auth/verify_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/monitor/monitor_screen.dart';

class AppRoutes {
  static const home = '/';
  static const dashBoard = '/dashBoard';
  static const landing = '/landing';
  static const signUp = '/signup';
  static const login = '/login';
  static const forget = '/forget';
  static const verify = '/verify';
  static const createProfile = '/createProfile';
  static const monitor = '/monitor';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case monitor:
        return MaterialPageRoute(builder: (_) => MonitorScreen());
      case dashBoard:
        return MaterialPageRoute(builder: (_) => DashBoardScreen());
      case verify:
        final target = settings.arguments as bool;
        return MaterialPageRoute(
          builder: (_) => VerifyScreen(isSignUp: target),
        );

      case forget:
        return MaterialPageRoute(builder: (_) => const ForgetScreen());

      case landing:
        return MaterialPageRoute(builder: (_) => LandingScreen());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

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
