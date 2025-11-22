import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'Features'),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 30 : 50,
                horizontal: isMobile ? 15 : 20,
              ),
              child: Column(
                children: [
                  Text(
                    'Why Choose InternConnect?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Empowering students and companies with next-gen tools for internship discovery and success.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ===== Responsive Cards =====
                  Wrap(
                    spacing: isMobile ? 10 : 20,
                    runSpacing: isMobile ? 10 : 20,
                    alignment: WrapAlignment.center,
                    children: const [
                      FeatureCard(
                          icon: '🌐',
                          title: 'Global Opportunities',
                          desc:
                              'Connect with verified companies across locations.'),
                      FeatureCard(
                          icon: '🤖',
                          title: 'Smart AI Matching',
                          desc:
                              'AI-driven recommendations that suit your skills.'),
                      FeatureCard(
                          icon: '🛡️',
                          title: 'Verified Companies',
                          desc: 'Transparent and safe internship listings.'),
                      FeatureCard(
                          icon: '📈',
                          title: 'Application Tracker',
                          desc:
                              'Track your applications and get instant feedback.'),
                      FeatureCard(
                          icon: '🤝',
                          title: 'Mentorship',
                          desc:
                              'Get personalized guidance from experienced mentors.'),
                      FeatureCard(
                          icon: '💬',
                          title: 'Community',
                          desc:
                              'Join global peers and share your learning journey.'),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
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

class FeatureCard extends StatelessWidget {
  final String icon, title, desc;
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Container(
      width: isMobile ? double.infinity : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
