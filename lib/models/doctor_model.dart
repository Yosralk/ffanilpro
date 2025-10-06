class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String description;
  final String imageUrl;
  final double fee;
  final double rating;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.description,
    required this.imageUrl,
    required this.fee,
    required this.rating,
  });

  // من Firestore
  factory Doctor.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      return Doctor(
        id: documentId,
        name: '',
        specialization: '',
        description: '',
        imageUrl: '',
        fee: 0,
        rating: 0,
      );
    }

    return Doctor(
      id: data['id'] ?? documentId,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      fee: (data['fee'] is num) ? (data['fee'] as num).toDouble() : 0.0,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
    );
  }

  // من Overpass (OSM)
  factory Doctor.fromOverpass(Map<String, dynamic> e) {
    final tags = (e['tags'] ?? {}) as Map<String, dynamic>;
    return Doctor(
      id: "osm_${e['id']}",
      name: tags['name'] ?? "Unknown",
      specialization: tags['amenity'] ?? "clinic",
      description: tags['description'] ?? '',
      imageUrl: '',
      fee: 10.0,
      rating: 4.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'description': description,
      'imageUrl': imageUrl,
      'fee': fee,
      'rating': rating,
    };
  }
}
