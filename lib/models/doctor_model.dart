class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final String description;
  final double rating;
  final double fee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.fee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'].toString(),
      name: json['name'],
      specialization: json['specialization'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'specialization': specialization,
    'imageUrl': imageUrl,
    'description': description,
    'rating': rating,
    'fee': fee,
  };
}
