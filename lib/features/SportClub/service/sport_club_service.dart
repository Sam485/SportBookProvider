import 'package:flutter_application_1/features/SportClub/model/dto/created_sport_clubs_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';

abstract class SportClubService {
  Future<SportClubModel> createSportClub(CreatedSportClubsDto sportClub);
  Future<SportClubModel> updateSportClub(
    CreatedSportClubsDto sportClub,
    int sportClubid,
  );
  Future<bool> deleteSportClub(int sportClubId);
  Future<List<SportClubModel>> getAllSportClub(
    int page,
    int limit,
    String? search,
  );

  bool get isLoading;
  String get error;
}
