import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: Navbar(currentPage: ''),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: [BoxShadow(color: AppColors.shadowColor.withValues(), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Forgot Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Enter your registered email and we’ll send a reset link.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 18),
                    TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Back to Login')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _footer(),
    );
  }

  Widget _footer() {
    return Container(color: AppColors.footerBlue, padding: const EdgeInsets.all(16), child: const Text('© 2025 InternConnect. All rights reserved.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)));
  }
}
