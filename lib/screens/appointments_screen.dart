import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';
import '../models/doctor_model.dart';
import '../utils/constants.dart';
import 'package:ffanilpro/models/appointment.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view appointments.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: kPrimary,
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: DbService.myAppointmentsStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final appts = snap.data ?? [];
          if (appts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No appointments yet.',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: appts.length,
            itemBuilder: (context, i) {
              final a = appts[i];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.calendar_today,
                      color: kPrimary, size: 30),
                  title: Text(
                    a.doctorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${a.date} • ${a.time}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DbService.deleteAppointment(a.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment canceled')),
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
