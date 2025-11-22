// lib/pages/domain_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  final List<String> domains = [
    "Web Development",
    "Data Science",
    "Machine Learning",
    "App Development",
    "Cybersecurity",
    "Artificial Intelligence",
    "UI/UX Design",
    "Cloud Computing"
  ];

  final Set<String> selectedDomains = {};

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'Domain'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Select One or More Domains',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pick any domains you are interested in. You will first select general skills, then technical skills for the selected domains.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: domains.map((d) {
                    final isSelected = selectedDomains.contains(d);
                    return ChoiceChip(
                      label: Text(d),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            selectedDomains.add(d);
                          } else {
                            selectedDomains.remove(d);
                          }
                        });
                      },
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: selectedDomains.isEmpty ? null : () {
                    final selectedList = selectedDomains.toList();
                    Navigator.pushNamed(
                      context,
                      '/general_skills',
                      arguments: {'domains': selectedList},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  selectedDomains.isEmpty
                      ? "No domains selected"
                      : "${selectedDomains.length} domain(s) selected",
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
