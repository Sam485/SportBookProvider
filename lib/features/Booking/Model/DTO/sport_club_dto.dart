class SportClubDto {
  final int id;
  final String name;
  final String location;

  SportClubDto({required this.id, required this.name, required this.location});

  factory SportClubDto.fromjson(Map<String, dynamic> json) {
    return SportClubDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }

  SportClubDto copyWith(int? id, String? name, String? location) {
    return SportClubDto(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }
}
