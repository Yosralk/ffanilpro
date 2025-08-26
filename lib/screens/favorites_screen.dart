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
      appBar: AppBar(title: const Text('Favorites'), backgroundColor: kPrimary),
      body: StreamBuilder<List<Doctor>>(
        stream: DbService.favoritesStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final favs = snap.data ?? [];
          if (favs.isEmpty) {
            return const Center(child: Text('No favorite doctors yet.'));
          }
          return ListView.separated(
            itemCount: favs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = favs[i];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(d.imageUrl)),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await DbService.removeFavorite(d.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from favorites')),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctor: d)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
