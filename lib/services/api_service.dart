import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';

class ApiService {
  static const String baseUrl = "https://mocki.io/v1";
  // Endpoint يرجع List<Doctor> بصيغة JSON
  static const String doctorsEndpoint = "/a17a8d2c-45a6-4f2d-8b43-7b3dcf7b7d3e";

  static Future<List<Doctor>> fetchDoctors() async {
    final response = await http.get(Uri.parse(baseUrl + doctorsEndpoint));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load doctors (${response.statusCode})");
    }
  }
}
