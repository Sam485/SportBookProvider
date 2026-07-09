class UpdateUserModel {
  final String name;
  final double lat;
  final double lng;
  final String location;

  UpdateUserModel({
    required this.name,
    required this.lat,
    required this.lng,
    required this.location,
  });

  factory UpdateUserModel.fromJson(Map<String, dynamic> json) {
    return UpdateUserModel(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'lat': lat, 'lng': lng, 'location': location};
  }
}
