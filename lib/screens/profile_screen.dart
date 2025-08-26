import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    name.text = u?.displayName ?? 'User';
    email.text = u?.email ?? '';
    phone.text = u?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name.text.trim());
      await FirebaseAuth.instance.currentUser?.reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: kPrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 12),
          TextField(controller: email, enabled: false, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
          const SizedBox(height: 12),
          TextField(controller: phone, enabled: false, decoration: const InputDecoration(labelText: 'Phone (read-only)', prefixIcon: Icon(Icons.phone))),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kPrimary, width: 1.5)),
              child: const Text('Logout', style: TextStyle(color: kPrimary)),
            ),
          ),
        ]),
      ),
    );
  }
}
