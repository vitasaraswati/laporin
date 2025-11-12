class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? buildingName;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.buildingName,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      buildingName: json['building_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'building_name': buildingName,
    };
  }

  String get displayText {
    if (buildingName != null) {
      return buildingName!;
    }
    if (address != null) {
      return address!;
    }
    return '$latitude, $longitude';
  }
}
