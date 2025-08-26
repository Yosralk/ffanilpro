import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/db_service.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view appointments.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments'), backgroundColor: kPrimary),
      body: StreamBuilder<List<Appointment>>(
        stream: DbService.myAppointmentsStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final appts = snap.data ?? [];
          if (appts.isEmpty) {
            return const Center(child: Text('No appointments yet.'));
          }

          // تعيين اليوم الحالي إذا مش محدد
          _selectedDay ??= _focusedDay;

          // مواعيد اليوم المختار
          final todaysAppts = appts.where((a) => a.date == _formatDate(_selectedDay!)).toList();

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: kAccent, shape: BoxShape.circle),
                ),
              ),
              const Divider(),
              Expanded(
                child: todaysAppts.isEmpty
                    ? const Center(child: Text("No appointments for this day."))
                    : ListView.separated(
                  itemCount: todaysAppts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = todaysAppts[i];
                    return ListTile(
                      leading: const Icon(Icons.calendar_today, color: kPrimary),
                      title: Text(a.doctorName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// تحويل DateTime -> String بنفس صيغة التخزين (yyyy-MM-dd)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
