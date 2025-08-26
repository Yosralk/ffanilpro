import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';
import '../models/appointment.dart';

class DbService {
  static final _db = FirebaseFirestore.instance;

  // -------------------- Appointments --------------------

  // users/{uid}/appointments/{docId}
  static CollectionReference<Map<String, dynamic>> _apptsCol(String uid) =>
      _db.collection('users').doc(uid).collection('appointments');

  static Future<void> addAppointment({
    required Doctor doctor,
    required String date,
    required String time,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    final appt = Appointment(
      id: '',
      doctorId: doctor.id,
      doctorName: doctor.name,
      date: date,
      time: time,
      status: 'booked',
      price: doctor.fee,
    );

    await _apptsCol(uid).add({
      ...appt.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Appointment>> myAppointmentsStream(String uid) {
    return _apptsCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => Appointment.fromMap(d.id, d.data()))
        .toList());
  }

  static Future<void> deleteAppointment(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _apptsCol(uid).doc(id).delete();
  }

  static Future<void> cancelAppointment(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _apptsCol(uid).doc(id).update({'status': 'cancelled'});
  }

  // -------------------- Favorites --------------------

  // users/{uid}/favorites/{doctorId}
  static CollectionReference<Map<String, dynamic>> _favCol(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  /// أضف طبيب إلى المفضلة (نحفظ snapshot بيانات الطبيب لتسهيل العرض)
  static Future<void> addFavorite(Doctor doctor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    await _favCol(uid).doc(doctor.id).set({
      'id': doctor.id,
      'name': doctor.name,
      'specialization': doctor.specialization,
      'imageUrl': doctor.imageUrl,
      'description': doctor.description,
      'rating': doctor.rating,
      'fee': doctor.fee,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> removeFavorite(String doctorId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _favCol(uid).doc(doctorId).delete();
  }

  /// Stream لمجموعة معرّفات الأطباء المفضّلين
  static Stream<Set<String>> favoriteIdsStream(String uid) {
    return _favCol(uid)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet());
  }

  /// Stream لقائمة الأطباء (معلومات كاملة) من المفضلة
  static Stream<List<Doctor>> favoritesStream(String uid) {
    return _favCol(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Doctor.fromJson(d.data())).toList());
  }

  /// Toggle: إذا موجود يشيله، إذا مش موجود يضيفه
  static Future<void> toggleFavorite(Doctor doctor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    final doc = await _favCol(uid).doc(doctor.id).get();
    if (doc.exists) {
      await removeFavorite(doctor.id);
    } else {
      await addFavorite(doctor);
    }
  }
}
