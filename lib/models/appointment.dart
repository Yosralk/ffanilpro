class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String date; // مثال: 2025-08-25
  final String time; // مثال: 09:00 AM
  final String? status; // booked / cancelled
  final double? price;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    this.status,
    this.price,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> m) {
    return Appointment(
      id: id,
      doctorId: (m['doctorId'] ?? '').toString(),
      doctorName: (m['doctorName'] ?? '').toString(),
      date: (m['date'] ?? '').toString(),
      time: (m['time'] ?? '').toString(),
      status: m['status']?.toString(),
      price: (m['price'] is num) ? (m['price'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'doctorName': doctorName,
    'date': date,
    'time': time,
    if (status != null) 'status': status,
    if (price  != null) 'price':  price,
  };
}
