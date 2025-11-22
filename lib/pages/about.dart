import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'About'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HERO SECTION =====
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 60 : 100,
                horizontal: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.blueGradient,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      Text(
                        'About InternConnect',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 26 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'At InternConnect, we’re reshaping how students and companies connect — bridging ambition and opportunity with trusted internships and mentorship.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 14 : 16,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== MAIN CONTENT =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Our Story',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'What started as a small idea has become a platform connecting thousands of students with meaningful internships. We combine verification, mentorship and smart matching to help learners start their careers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ===== VALUE CARDS =====
                      Wrap(
                        spacing: isMobile ? 10 : 20,
                        runSpacing: isMobile ? 10 : 20,
                        alignment: WrapAlignment.center,
                        children: const [
                          ValueCard(
                            emoji: '🎯',
                            title: 'Vision',
                            body:
                                'To become the most trusted global platform for internships.',
                          ),
                          ValueCard(
                            emoji: '💡',
                            title: 'Approach',
                            body:
                                'Smart, ethical matching that respects learners and employers.',
                          ),
                          ValueCard(
                            emoji: '🤝',
                            title: 'Promise',
                            body:
                                'Verified companies and transparent application flows.',
                          ),
                          ValueCard(
                            emoji: '📈',
                            title: 'Impact',
                            body:
                                'Help students grow through real-world work experiences.',
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Why Choose Us?',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We focus on verified roles, mentorship, and an easy-to-use experience so students can apply with confidence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== FOOTER =====
      bottomNavigationBar: _footer(),
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

class ValueCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;

  const ValueCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
