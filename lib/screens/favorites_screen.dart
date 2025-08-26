import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';
import '../models/doctor_model.dart';
import '../utils/constants.dart';
import 'doctor_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view favorites.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: kPrimary,
      ),
      body: StreamBuilder<List<Doctor>>(
        stream: DbService.myFavoritesStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final favs = snap.data ?? [];
          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No favorites yet.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, i) {
              final d = favs[i];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(d.imageUrl),
                  ),
                  title: Text(
                    d.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      '${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DbService.removeFavorite(d.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${d.name} removed from favorites'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsScreen(doctor: d),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
