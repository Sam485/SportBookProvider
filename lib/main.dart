import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  // Initialize the service locator
  await setupServiceLocator();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SportMateApp());
}

class SportMateApp extends StatefulWidget {
  const SportMateApp({super.key});

  @override
  State<SportMateApp> createState() => _SportMateAppState();
}

class _SportMateAppState extends State<SportMateApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Register the navigator key in service locator
    if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
      getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'SportMate',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [Locale('en', ''), Locale('km', '')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Set splash screen as initial route
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the registered navigator key
    if (getIt.isRegistered<GlobalKey<NavigatorState>>()) {
      getIt.unregister<GlobalKey<NavigatorState>>();
    }
    super.dispose();
  }
}
