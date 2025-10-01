import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';
import '../models/cart_item_model.dart';
import '../models/doctor_model.dart';

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
        .map((snap) =>
        snap.docs.map((d) => Appointment.fromMap(d.id, d.data())).toList());
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
    return _favsCol(uid).snapshots().map(
            (snap) => snap.docs.map((d) => Doctor.fromMap(d.data(), d.id)).toList());
  }

  // ---------------- Cart -----------------
  static CollectionReference<Map<String, dynamic>> _cartCol(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  static Future<void> addToCart({
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
      'fee': doctor.fee,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _cartCol(uid).add(data);
  }

  static Stream<List<CartItem>> myCartStream(String uid) {
    return _cartCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList());
  }

  static Future<void> removeFromCart(String itemId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    await _cartCol(uid).doc(itemId).delete();
  }

  static Future<void> clearCart(String uid) async {
    final items = await _cartCol(uid).get();
    final batch = _db.batch();
    for (final d in items.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  /// يحول كل عناصر السلة إلى مواعيد ثم يفرّغ السلة
  static Future<void> confirmCart(String uid) async {
    final itemsSnap = await _cartCol(uid).get();
    if (itemsSnap.docs.isEmpty) return;

    final apptRef = _apptsCol(uid);
    final batch = _db.batch();

    for (final doc in itemsSnap.docs) {
      final j = doc.data();
      final toAppt = {
        'doctorId': j['doctorId'],
        'doctorName': j['doctorName'],
        'specialization': j['specialization'],
        'date': j['date'],
        'time': j['time'],
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(apptRef.doc(), toAppt);
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
