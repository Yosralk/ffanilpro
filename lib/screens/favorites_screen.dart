import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';
import '../services/db_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Please sign in to view favorites.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: StreamBuilder<List<Doctor>>(
        stream: DbService.myFavoritesStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favs = snapshot.data ?? [];
          if (favs.isEmpty) {
            return const Center(child: Text("No favorites yet ❤️"));
          }

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, i) {
              final d = favs[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(d.specialization),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () async {
                      await DbService.removeFavorite(d.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${d.name} removed from favorites")),
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
