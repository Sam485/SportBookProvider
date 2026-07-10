import 'package:flutter_application_1/features/SportClub/model/dto/created_sport_clubs_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/dto/update_sport_club_dto.dart';
import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';
import 'package:flutter_application_1/features/SportClub/repository/sport_club_repository.dart';
import 'package:flutter_application_1/features/SportClub/service/sport_club_service.dart';

class SportClubServiceImp implements SportClubService {
  SportClubRepository sportClubRepository;
  SportClubServiceImp(this.sportClubRepository);
  String _error = '';
  bool _isLoading = false;

  @override
  String get error => _error;

  @override
  bool get isLoading => _isLoading;
  @override
  Future<SportClubModel> createSportClub(CreatedSportClubsDto sportClub) async {
    _isLoading = true;
    _error = '';
    try {
      final data = await sportClubRepository.createSportClub(sportClub);
      _isLoading = false;
      return data;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<bool> deleteSportClub(int sportClubId) async {
    _isLoading = true;
    _error = '';
    try {
      final response = await sportClubRepository.deleteSportclub(sportClubId);
      _isLoading = false;
      return response;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      rethrow;
    }
  }

  @override
  Future<SportClubModel> updateSportClub(
    UpdateSportClubDto sportClub,
    int sportClubid,
  ) async {
    _isLoading = true;
    _error = '';
    try {
      final data = await sportClubRepository.updateSportClub(
        sportClub,
        sportClubid,
      );
      _isLoading = false;
      return data;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      rethrow;
    }
  }
}
