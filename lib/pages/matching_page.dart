import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'dart:async';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    _rotation = Tween<double>(begin: 0, end: 1).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startMatchingFlow());
  }

  Future<void> _startMatchingFlow() async {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final List<String>? domains = (routeArgs?['domains'] as List?)?.cast<String>();
    final Map<String, String>? selectedSkills =
        (routeArgs?['selectedSkills'] as Map?)?.cast<String, String>();

    if (domains == null || selectedSkills == null || selectedSkills.isEmpty) {
      // Missing input: return to domain to restart the flow
      Navigator.pushReplacementNamed(context, '/domain');
      return;
    }

    // Optional: call your backend to compute matches using domains + selectedSkills
    // For now we simulate a small delay for the animation.
    await Future.delayed(const Duration(seconds: 3));

    // Forward to companies page with payload
    Navigator.pushReplacementNamed(
      // ignore: use_build_context_synchronously
      context,
      '/companies',
      arguments: {
        'domains': domains,
        'selectedSkills': selectedSkills,
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final List<String>? domains = (routeArgs?['domains'] as List?)?.cast<String>();
    final int domainCount = domains?.length ?? 0;

    return Scaffold(
      appBar: const Navbar(currentPage: 'Matching'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              domainCount > 0
                  ? "Finding matches for $domainCount selected domain(s)..."
                  : "Finding your perfect match...",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            RotationTransition(
              turns: _rotation,
              child: const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This may take a few seconds.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
