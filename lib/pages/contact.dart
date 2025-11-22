import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture messenger before async call
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSending = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isSending = false);

    messenger.showSnackBar(
      const SnackBar(
        content: Text("Thank you for your feedback!"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'Contact'),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 30 : 40,
                horizontal: isMobile ? 16 : 20,
              ),
              child: Column(
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We’d love to hear from you! Whether you’re a student or recruiter, drop us a message.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _contactForm(context, isMobile),

                  const SizedBox(height: 30),
                  Text(
                    'Or reach out directly:\n'
                    'support@internconnect.com\n'
                    '+1 (800) 234-5678\n'
                    '12 Innovation Park, San Francisco, CA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _footer(),
    );
  }

  Widget _contactForm(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Name'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration('Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              decoration: _inputDecoration('Message'),
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a message';
                if (v.trim().length < 5) return 'Message is too short';
                return null;
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Send Message',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _footer() {
    return Container(
      color: AppColors.footerBlue,
      padding: const EdgeInsets.all(16),
      child: const Text(
        '© 2025 InternConnect. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
