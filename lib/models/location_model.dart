class LocationModel {
  final String id;
  final String name;
  final int sequence;
  final double latitude;
  final double longitude;
  final String? description;

  const LocationModel({
    required this.id,
    required this.name,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sequence: _toInt(json['sequence']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      description: json['description']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
