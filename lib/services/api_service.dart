import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class ApiService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future<List<Doctor>> fetchDoctors() async {
    final snap = await _db.collection('doctors').get();
    return snap.docs
        .map((doc) => Doctor.fromMap(doc.data(), doc.id))
        .toList();
  }
  static Future<void> addDoctor(Doctor doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toJson());
  }
}
