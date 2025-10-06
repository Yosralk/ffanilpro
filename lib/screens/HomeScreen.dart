import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/jordan_places_service.dart';
import '../services/db_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Doctor>> _futureDoctors;

  @override
  void initState() {
    super.initState();
    _futureDoctors = JordanPlacesService.fetchProviders(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctors in Jordan")),
      body: FutureBuilder<List<Doctor>>(
        future: _futureDoctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const Center(child: Text("No doctors found."));
          }

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, i) {
              final d = doctors[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(d.specialization),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () async {
                      await DbService.addFavorite(d);
                      if (!mounted) return;
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
