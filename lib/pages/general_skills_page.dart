// lib/pages/general_skills_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';

class GeneralSkillsPage extends StatefulWidget {
  const GeneralSkillsPage({super.key});

  @override
  State<GeneralSkillsPage> createState() => _GeneralSkillsPageState();
}

class _GeneralSkillsPageState extends State<GeneralSkillsPage> {
  final List<String> generalSkills = [
    "Communication",
    "Problem Solving",
    "Teamwork",
    "Time Management",
    "Leadership",
    "Adaptability",
    "Critical Thinking",
    "Creativity"
  ];

  final Set<String> selectedGeneral = {};

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final List<String> domains = (args?['domains'] as List?)?.cast<String>() ?? [];

    final isMobile = MediaQuery.of(context).size.width < 600;
    final domainsLabel = domains.join(', ');

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'General Skills'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Text(
                  'General Skills for: $domainsLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select general (soft) skills that apply to you. These will be combined with technical skills next.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: generalSkills.map((g) {
                    final isSelected = selectedGeneral.contains(g);
                    return FilterChip(
                      label: Text(g),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            selectedGeneral.add(g);
                          } else {
                            selectedGeneral.remove(g);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // proceed to technical skills page, pass both domains + selected general skills
                    Navigator.pushNamed(
                      context,
                      '/skills',
                      arguments: {
                        'domains': domains,
                        'generalSkills': selectedGeneral.toList(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Next', style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 12),
                Text(
                  '${selectedGeneral.length} general skill(s) selected',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
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
