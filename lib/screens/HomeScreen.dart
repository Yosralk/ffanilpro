import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../utils/constants.dart';
import 'doctor_details_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import '../services/api_service.dart';

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
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.fetchDoctors();
      setState(() => _doctors = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading doctors: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// زر لإضافة بيانات تجريبية
  Future<void> _seedDoctors() async {
    final docs = [
      Doctor(
        id: 'd1',
        name: 'Dr. Sarah Ahmed',
        specialization: 'Dermatology',
        description: '10+ yrs experience in skin treatments.',
        imageUrl: 'https://images.unsplash.com/photo-1550831107-1553da8c8464',
        rating: 4.7,
        fee: 25.0,
      ),
      Doctor(
        id: 'd2',
        name: 'Dr. Omar Khaled',
        specialization: 'Cardiology',
        description: 'Cardiologist focused on prevention & rehab.',
        imageUrl: 'https://images.unsplash.com/photo-1511174511562-5f7f18b874f8',
        rating: 4.5,
        fee: 30.0,
      ),
      Doctor(
        id: 'd3',
        name: 'Dr. Lina Nassar',
        specialization: 'Pediatrics',
        description: 'Gentle pediatrician, child-friendly clinic.',
        imageUrl: 'https://images.unsplash.com/photo-1551601651-2a8555f1a136',
        rating: 4.8,
        fee: 20.0,
      ),
    ];

    try {
      for (final doc in docs) {
        await ApiService.addDoctor(doc);
      }
      await _loadDoctors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample doctors added ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _doctors.where((d) {
      final q = _query.toLowerCase().trim();
      return d.name.toLowerCase().trim().contains(q) ||
          d.specialization.toLowerCase().trim().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocTime'),
        backgroundColor: kPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'My Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'My Appointments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDoctors,
        child: Column(
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
                  : filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No doctors found.'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _seedDoctors,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Add Sample Doctors'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final d = filtered[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorDetailsScreen(doctor: d),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
