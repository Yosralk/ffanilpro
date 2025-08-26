import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../models/doctor_model.dart';
import '../utils/constants.dart';
import 'doctor_details_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.fetchDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _doctors.where((d) {
      final q = _query.toLowerCase();
      return d.name.toLowerCase().contains(q) || d.specialization.toLowerCase().contains(q);
    }).toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocTime'),
        backgroundColor: kPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'My Appointments',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor or specialization...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (uid == null)
                ? _buildList(filtered, const <String>{})
                : StreamBuilder<Set<String>>(
              stream: DbService.favoriteIdsStream(uid),
              builder: (context, favSnap) {
                final favIds = favSnap.data ?? <String>{};
                return _buildList(filtered, favIds);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Doctor> items, Set<String> favIds) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final d = items[i];
        final isFav = favIds.contains(d.id);
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(d.imageUrl)),
          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}'),
          trailing: IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
            onPressed: () async {
              await DbService.toggleFavorite(d);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isFav ? 'Removed from favorites' : 'Added to favorites')),
              );
            },
          ),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctor: d))),
        );
      },
    );
  }
}
