import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart'; // ✅ استدعاء خدمة الإشعارات
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
    '09:00 AM','10:30 AM','12:00 PM','01:30 PM','03:00 PM','04:30 PM',
  ];

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time.')),
      );
      return;
    }
    try {
      // ✅ إضافة الموعد إلى Firestore
      await DbService.addAppointment(
        doctor: widget.doctor,
        date: _selectedDate!,
        time: _selectedTime!,
      );

      // ✅ تحويل التاريخ والوقت المختارين إلى DateTime
      final appointmentDateTime = DateTime.parse("$_selectedDate $_selectedTime");

      // ✅ إنشاء Reminder قبل الموعد بساعة
      final reminderTime = appointmentDateTime.subtract(const Duration(hours: 1));
      await NotificationService.schedule(
        title: "Appointment Reminder",
        body: "You have an appointment with ${widget.doctor.name} at $_selectedTime",
        scheduledTime: reminderTime,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully! Reminder set.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;

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
            Center(child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(d.imageUrl))),
            const SizedBox(height: 12),
            Center(
              child: Text(d.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Text('${d.specialization} • ⭐ ${d.rating.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, color: kPrimary),
                Text('Consultation Fee: ${d.fee.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('About Doctor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(d.description),
            const SizedBox(height: 20),

            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.w600)),
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

            const Text('Select Time', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
