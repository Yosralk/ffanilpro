class CartItem {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String date;
  final String time;
  final double fee;

  CartItem({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.date,
    required this.time,
    required this.fee,
  });

  factory CartItem.fromMap(String id, Map<String, dynamic> map) {
    return CartItem(
      id: id,
      doctorId: (map['doctorId'] ?? '').toString(),
      doctorName: (map['doctorName'] ?? '').toString(),
      specialization: (map['specialization'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      time: (map['time'] ?? '').toString(),
      fee: (map['fee'] is num) ? (map['fee'] as num).toDouble() : 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialization': specialization,
    'date': date,
    'time': time,
    'fee': fee,
  };
}
