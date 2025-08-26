import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class ApiService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// جلب جميع الأطباء من Firestore
  static Future<List<Doctor>> fetchDoctors() async {
    final snap = await _db.collection('doctors').get();
    return snap.docs.map((d) => Doctor.fromJson(d.data() as Map<String, dynamic>)).toList();
  }

  /// إضافة دكتور (ممكن تستعملها للتجربة أو للوحة تحكم)
  static Future<void> addDoctor(Doctor doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toJson());
  }
}
