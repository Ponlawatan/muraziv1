class Place {
  final String id;
  final String name;
  final String bannerImage;
  final List<String> categories;
  final Map<String, dynamic> address;
  final String googleMapUrl;
  final String description;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.name,
    required this.bannerImage,
    required this.categories,
    required this.address,
    required this.googleMapUrl,
    required this.description,
    required this.createdAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      address: json['address'] ?? {},
      googleMapUrl: json['googleMapUrl'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Helper getters
  String get province => address['province'] ?? '';
  String get district => address['district'] ?? '';
  String get subdistrict => address['subdistrict'] ?? '';

  // Helper method to get full address
  String get fullAddress =>
      '${address['subdistrict'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}';
}
