import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config/app_config.dart';
import 'package:flutter_application_1/core/interceptors/auth_interceptor.dart';
import 'package:flutter_application_1/features/Booking/Repository/booking_repository.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service.dart';
import 'package:flutter_application_1/features/Booking/Service/booking_service_imp.dart';
import 'package:flutter_application_1/features/Notification/repository/notification_repository.dart';
import 'package:flutter_application_1/features/Notification/service/notification_service.dart';
import 'package:flutter_application_1/features/Notification/service/notification_service_imp.dart';
import 'package:flutter_application_1/features/SportClub/repository/sport_club_repository.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service_imp.dart';
import 'package:flutter_application_1/features/Token/Api/token_api.dart';
import 'package:flutter_application_1/features/Token/service/token_service.dart';
import 'package:flutter_application_1/features/Auth/auth_service.dart';
import 'package:flutter_application_1/features/User/Repository/user_respository.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';
import 'package:flutter_application_1/features/User/Service/user_service_imp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ============================================================
  // REGISTER DIO FIRST (no dependencies)
  // ============================================================
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor());

    return dio;
  });

  // ============================================================
  // REGISTER TOKEN (depends on Dio)
  // ============================================================
  getIt.registerLazySingleton<TokenApi>(() => TokenApi(getIt<Dio>()));
  getIt.registerLazySingleton<TokenService>(
    () => TokenService(getIt<TokenApi>()),
  );

  // ============================================================
  // REGISTER AUTH SERVICE (depends on TokenService)
  // ============================================================
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  //User
  getIt.registerLazySingleton<UserRespository>(
    () => UserRespository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<UserService>(
    () => UserServiceImp(getIt<UserRespository>()),
  );

  //Notification
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImp(getIt<NotificationRepository>()),
  );

  //Booking
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<BookingService>(
    () => BookingServiceImp(getIt<BookingRepository>()),
  );

  //SportClub
  getIt.registerLazySingleton<SportClubRepository>(
    () => SportClubRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<SportClubService>(
    () => SportClubServiceImp(getIt<SportClubRepository>()),
  );
}
