import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/glass_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: _sent
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        const Text('Password Reset Link Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Check your inbox (\${_emailController.text}) for instructions.'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Back to Sign In'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Reset Your Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Enter your registered email address to receive password reset instructions.'),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_emailController.text.contains('@')) {
                              setState(() => _sent = true);
                            }
                          },
                          child: const Text('Send Reset Link'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
