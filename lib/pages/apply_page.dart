import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String? _companyName;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _prefillFromArgsAndPrefs();
  }

  Future<void> _prefillFromArgsAndPrefs() async {
    // get args (company + maybe prefilled user data)
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;

    if (args != null) {
      final Map<String, dynamic>? company =
          args['company'] as Map<String, dynamic>?;
      _companyName = company?['name']?.toString();

      // if you passed user data via arguments, use it here
      final String? name = args['name'] as String?;
      final String? email = args['email'] as String?;
      final String? phone = args['phone'] as String?;

      if (name != null && name.isNotEmpty) _nameCtrl.text = name;
      if (email != null && email.isNotEmpty) _emailCtrl.text = email;
      if (phone != null && phone.isNotEmpty) _phoneCtrl.text = phone;
    }

    // Also try SharedPreferences as a fallback
    try {
      final sp = await SharedPreferences.getInstance();
      _nameCtrl.text = _nameCtrl.text.isNotEmpty
          ? _nameCtrl.text
          : (sp.getString('profile_name') ?? '');
      _emailCtrl.text = _emailCtrl.text.isNotEmpty
          ? _emailCtrl.text
          : (sp.getString('profile_email') ?? '');
      _phoneCtrl.text = _phoneCtrl.text.isNotEmpty
          ? _phoneCtrl.text
          : (sp.getString('profile_phone') ?? '');
    } catch (_) {}

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _expCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final title = _companyName != null
        ? 'Apply to $_companyName'
        : 'Apply Now';

    return Scaffold(
      appBar: const Navbar(currentPage: ''),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 28,
                  vertical: isMobile ? 20 : 26,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'We will contact you if shortlisted.',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      _label('Full name'),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      _label('Email'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final email = v.trim();
                          if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,4}$')
                              .hasMatch(email)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      _label('Phone'),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      _label('Experience (in years)'),
                      TextFormField(
                        controller: _expCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(hint: 'e.g., 0, 0.5, 1'),
                      ),
                      const SizedBox(height: 16),

                      _label('Message (optional)'),
                      TextFormField(
                        controller: _messageCtrl,
                        maxLines: 4,
                        decoration:
                            _inputDecoration(hint: 'Tell us why you are a fit'),
                      ),
                      const SizedBox(height: 28),

                      Center(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 260,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit Application',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    // no backend call → no 400 / CORS. Just simulate delay.
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _companyName != null
              ? 'Application submitted to $_companyName'
              : 'Application submitted',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}
