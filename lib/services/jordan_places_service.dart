import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';

class JordanPlacesService {
  static const String _query = '''
[out:json][timeout:25];
area["name:en"="Jordan"]->.a;
(
  node["amenity"="doctors"](area.a);
  node["amenity"="clinic"](area.a);
  node["amenity"="hospital"](area.a);
);
out body; >; out skel qt;
''';

  static Future<List<Doctor>> fetchProviders({int limit = 50}) async {
    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(_query)}',
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception("Overpass API Error: ${resp.statusCode}");
    }

    final data = jsonDecode(resp.body);
    final elements = (data['elements'] as List?) ?? [];

    final doctors = <Doctor>[];
    for (final e in elements) {
      if (e['type'] == 'node') {
        final tags = e['tags'] as Map<String, dynamic>? ?? {};
        final name = tags['name'] ?? 'Unknown Clinic';
        final spec = tags['amenity'] ?? 'clinic';

        doctors.add(Doctor(
          id: 'osm_${e['id']}',
          name: name,
          specialization: spec,
          description: tags['description'] ?? '',
          imageUrl: '', // ما فيه صور، ممكن تحط صورة افتراضية
          fee: 10.0,    // قيمة افتراضية
          rating: 4.0,  // قيمة افتراضية
        ));
      }
      if (doctors.length >= limit) break;
    }

    return doctors;
  }
}
