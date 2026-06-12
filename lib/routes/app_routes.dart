import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/forget_screen.dart';
import 'package:flutter_application_1/screens/auth/landing_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/auth/signup_screen.dart';
import 'package:flutter_application_1/screens/auth/verify_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';

class AppRoutes {
  static const home = '/';
  static const landing = '/landing';
  static const signUp = '/signup';
  static const login = '/login';
  static const forget = '/forget';
  static const verify = '/verify';
  static const createProfile = '/createProfile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());
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
