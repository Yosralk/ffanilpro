import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  String? _selectedDate;
  String? _selectedTime;

  final _dates = List.generate(7, (i) {
    final d = DateTime.now().add(Duration(days: i));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  });

  final _times = const [
    '09:00 AM',
    '10:30 AM',
    '12:00 PM',
    '01:30 PM',
    '03:00 PM',
    '04:30 PM',
  ];

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time.')),
      );
      return;
    }
    try {
      // حفظ الموعد في Firestore
      await DbService.addAppointment(
        doctor: widget.doctor,
        date: _selectedDate!,
        time: _selectedTime!,
      );

      // 🕑 حساب وقت التذكير
      // مبدئياً: تحويل التاريخ والوقت ل DateTime
      DateTime appointmentTime = _parseDateTime(_selectedDate!, _selectedTime!);

      // تذكير قبل ساعة من الموعد
      final reminderTime = appointmentTime.subtract(const Duration(hours: 1));

      // 🔔 جدولة الإشعار
      await NotificationService.schedule(
        title: "Upcoming appointment",
        body: "You have an appointment with ${widget.doctor.name} at $_selectedTime",
        scheduledTime: reminderTime.isAfter(DateTime.now())
            ? reminderTime
            : DateTime.now().add(const Duration(seconds: 10)), // fallback للتجربة
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  /// تحويل date + time (مثلاً "2025-08-25" + "09:00 AM") إلى DateTime
  DateTime _parseDateTime(String date, String time) {
    try {
      // time مثل: "09:00 AM"
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      final period = parts[1];

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final dParts = date.split('-'); // "2025-08-25"
      final year = int.parse(dParts[0]);
      final month = int.parse(dParts[1]);
      final day = int.parse(dParts[2]);

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return DateTime.now().add(const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.name),
        backgroundColor: kPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(d.imageUrl),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                d.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                '${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, color: kPrimary),
                Text('Consultation Fee: ${d.fee.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('About Doctor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(d.description),
            const SizedBox(height: 20),

            // -------- Date --------
            const Text('Select Date',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _dates.map((date) {
                final selected = _selectedDate == date;
                return ChoiceChip(
                  label: Text(date),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedDate = date),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // -------- Time --------
            const Text('Select Time',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _times.map((t) {
                final selected = _selectedTime == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedTime = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _book,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
