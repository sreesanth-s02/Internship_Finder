// lib/pages/profile_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  bool saving = false;
  bool uploading = false;
  String? _token;

  // profile fields
  int? userId;
  String username = '';
  String email = '';
  String phone = '';
  String org = '';
  String? profilePicUrl;
  int appliedCount = 0;

  // edit mode
  bool editing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _orgController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _orgController = TextEditingController();
    // we cannot use ModalRoute in initState, but token/profile loading is fine
    _loadTokenAndProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  /// Try SharedPreferences first; if token not found, fall back to AuthProvider.
  Future<void> _loadTokenAndProfile() async {
    setState(() {
      loading = true;
    });

    String? t;

    // 1) SharedPreferences
    try {
      final sp = await SharedPreferences.getInstance();
      t = sp.getString('auth_token');
    } catch (_) {
      t = null;
    }

    // 2) Fallback to provider if prefs had no token
    if (t == null) {
      try {
        // ignore: use_build_context_synchronously
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.token != null && auth.token!.isNotEmpty) {
          t = auth.token;
        }
      } catch (_) {
        // provider not available – leave t as null
      }
    }

    // 3) If still null, go to login
    if (t == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _token = t;
    await _fetchProfile();

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _fetchProfile() async {
    if (_token == null) return;
    try {
      final res = await ApiService.get('/api/me', token: _token);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) {
          setState(() {
            userId = body['id'] is int ? body['id'] : int.tryParse('${body['id']}');
            username = (body['username'] ?? '').toString();
            email = (body['email'] ?? '').toString();
            phone = (body['phone'] ?? '').toString();
            org = (body['org'] ?? '').toString();
            profilePicUrl = body['profile_pic']?.toString();
            appliedCount = (body['applied_count'] is int)
                ? body['applied_count']
                : (int.tryParse('${body['applied_count']}') ?? 0);

            // update controllers
            _usernameController.text = username;
            _phoneController.text = phone;
            _orgController.text = org;
          });
        }
      } else if (res.statusCode == 401) {
        // token invalid -> clear and go login
        try {
          final sp = await SharedPreferences.getInstance();
          await sp.remove('auth_token');
        } catch (_) {}
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_token == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);
    final payload = {
      'username': _usernameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'org': _orgController.text.trim(),
    };

    try {
      final res = await ApiService.post('/api/me', payload, token: _token);
      if (res.statusCode == 200) {
        await _fetchProfile();
        setState(() => editing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${res.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('saveProfile error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Future<void> _pickAndUploadPic() async {
    if (_token == null) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;
    if (fileBytes == null) return;

    setState(() => uploading = true);

    try {
      // adjust path if your backend uses a different one
      final uri = Uri.parse('${ApiService.baseUrl}/api/upload_profile_pic');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(
        http.MultipartFile.fromBytes('profile_pic', fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('uploadPic error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => uploading = false);
      }
    }
  }

  Widget _avatar() {
    final displayedUrl = profilePicUrl;
    if (displayedUrl != null && displayedUrl.isNotEmpty) {
      final url = displayedUrl.startsWith('http')
          ? displayedUrl
          : '${ApiService.baseUrl}$displayedUrl';
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.transparent,
      );
    } else {
      final initials = (username.isNotEmpty
              ? username.split(' ').map((p) => p.isNotEmpty ? p[0] : '').join()
              : 'U')
          .toUpperCase();
      return CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.primaryBlue,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const Navbar(currentPage: ''),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    _avatar(),
                    const SizedBox(height: 12),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Internships applied: $appliedCount',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 18),

                    // upload + edit buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: uploading ? null : _pickAndUploadPic,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 22,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: uploading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Upload Photo'),
                        ),
                        const SizedBox(width: 12),
                        if (!editing)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                editing = true;
                                _usernameController.text = username;
                                _phoneController.text = phone;
                                _orgController.text = org;
                              });
                            },
                            child: const Text('Edit profile'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            enabled: editing,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            enabled: false,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                            keyboardType: TextInputType.phone,
                            enabled: editing,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _orgController,
                            decoration: const InputDecoration(
                              labelText: 'College / Company',
                            ),
                            enabled: editing,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (editing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: saving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                            ),
                            child: saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed:
                                saving ? null : () => setState(() => editing = false),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // 🔹 UPDATED LOGOUT BUTTON (uses AuthProvider + clears prefs)
                    TextButton(
                      onPressed: () async {
                        // 1) Tell the provider to clear user + token (this also clears prefs)
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.logout();

                        // 2) Just to be extra safe, remove any stray stored values
                        try {
                          final sp = await SharedPreferences.getInstance();
                          await sp.remove('auth_token');
                          await sp.remove('profile_pic');
                        } catch (_) {}

                        // 3) Go back to Home and clear navigation stack
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
