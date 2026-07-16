import 'package:flutter_application_1/features/SportClub/model/sport_club_model.dart';

class GetAllSportClubDto {
  final List<SportClubModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllSportClubDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllSportClubDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['data'];
    return GetAllSportClubDto(
      data: items.map((e) => SportClubModel.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
