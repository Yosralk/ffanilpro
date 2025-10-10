import 'package:flutter/material.dart';
import '../services/jordan_places_service.dart';
import '../models/doctor_model.dart';
import '../utils/constants.dart';
import 'doctor_details_screen.dart';
import '../services/db_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Doctor>> _futureDoctors;

  @override
  void initState() {
    super.initState();
    _futureDoctors = JordanPlacesService.fetchProviders(limit: 25);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors in Jordan (API)"),
        backgroundColor: kPrimary,
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _futureDoctors,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final doctors = snap.data ?? [];
          if (doctors.isEmpty) {
            return const Center(child: Text("No doctors found in API."));
          }

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, i) {
              final d = doctors[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimary.withOpacity(0.1),
                    child: const Icon(Icons.local_hospital, color: kPrimary),
                  ),
                  title: Text(
                    d.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(d.specialization),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsScreen(doctor: d),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () async {
                      await DbService.addFavorite(d);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${d.name} added to favorites ❤️")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
