import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';
import 'package:ffanilpro/models/appointment.dart';

class DbService {
  static final _db = FirebaseFirestore.instance;

  // ---------------- Appointments -----------------
  static CollectionReference<Map<String, dynamic>> _apptsCol(String uid) =>
      _db.collection('users').doc(uid).collection('appointments');

  static Future<void> addAppointment({
    required Doctor doctor,
    required String date,
    required String time,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final data = {
      'doctorId': doctor.id,
      'doctorName': doctor.name,
      'specialization': doctor.specialization,
      'date': date,
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _apptsCol(uid).add(data);
  }

  static Stream<List<Appointment>> myAppointmentsStream(String uid) {
    return _apptsCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      final j = d.data();
      return Appointment(
        id: d.id,
        doctorId: j['doctorId'] ?? '',
        doctorName: j['doctorName'] ?? '',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
      );
    }).toList());
  }

  static Future<void> deleteAppointment(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _apptsCol(uid).doc(id).delete();
  }

  // ---------------- Favorites -----------------
  static CollectionReference<Map<String, dynamic>> _favsCol(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  static Future<void> addFavorite(Doctor doctor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    await _favsCol(uid).doc(doctor.id).set(doctor.toJson());
  }

  static Future<void> removeFavorite(String doctorId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    await _favsCol(uid).doc(doctorId).delete();
  }

  static Stream<List<Doctor>> myFavoritesStream(String uid) {
    return _favsCol(uid).snapshots().map((snap) =>
        snap.docs.map((d) => Doctor.fromJson(d.data())).toList());
  }
}
