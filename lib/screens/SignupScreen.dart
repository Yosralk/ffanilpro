import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool agree = false;
  bool _loading = false;

  Future<void> _onSignup() async {
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to terms.")),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        displayName:
        nameController.text.trim().isEmpty ? "User" : nameController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(height: 250, decoration: curvedHeader()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  "Create Account ✨",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: agree,
                                onChanged: (v) =>
                                    setState(() => agree = v ?? false),
                              ),
                              const Expanded(
                                  child: Text(
                                      "I agree to the processing of personal data",
                                      style: TextStyle(fontSize: 12))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _loading
                              ? const CircularProgressIndicator()
                              : CustomButton(
                              text: "Sign Up", onPressed: _onSignup),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
