// lib/pages/skills_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/navbar.dart';

class SkillsPage extends StatefulWidget {
  final String? domain;
  const SkillsPage({super.key, this.domain});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  // technical skills by domain
  final Map<String, List<String>> domainSkills = {
    "Web Development": [
      "HTML",
      "CSS",
      "JavaScript",
      "React",
      "Node.js",
      "Express.js",
      "SQL",
      "MongoDB"
    ],
    "Data Science": [
      "Python",
      "R",
      "SQL",
      "Tableau",
      "Power BI",
      "Excel"
    ],
    "Machine Learning": [
      "Python",
      "Scikit-learn",
      "TensorFlow",
      "Keras",
      "PyTorch",
      "OpenCV"
    ],
    "App Development": [
      "Java",
      "Kotlin",
      "Flutter",
      "Swift",
      "React Native",
      "Firebase"
    ],
    "Cybersecurity": [
      "Python",
      "C",
      "C++",
      "Wireshark",
      "Burp Suite",
      "Metasploit",
      "Kali Linux"
    ],
    "Artificial Intelligence": [
      "Python",
      "TensorFlow",
      "PyTorch",
      "OpenCV",
      "NLP",
      "Computer Vision",
      "Chatbot Development"
    ],
    "UI/UX Design": [
      "Figma",
      "Adobe XD",
      "Sketch",
      "User Research",
      "Prototyping",
      "Wireframing",
      "Design Thinking"
    ],
    "Cloud Computing": [
      "AWS",
      "Azure",
      "Google Cloud",
      "Docker",
      "Kubernetes",
      "DevOps",
      "CI/CD"
    ],
  };

  final List<String> levels = [
    "Basic",
    "Intermediate",
    "Skilled",
    "Advanced",
    "Expert"
  ];

  // skill -> selected level
  final Map<String, String> selectedSkills = {};

  late List<String> displaySkills;
  late List<String> domainsSelected;
  late List<String> generalSkillsSelected;

  @override
  void initState() {
    super.initState();
    displaySkills = [];
    domainsSelected = [];
    generalSkillsSelected = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final List<String>? domainsArg = args != null ? (args['domains'] as List?)?.cast<String>() : null;
    final List<String>? generalArg = args != null ? (args['generalSkills'] as List?)?.cast<String>() : null;
    final String? singleDomain = args != null ? (args['domain'] as String?) : null;

    if (domainsArg != null && domainsArg.isNotEmpty) {
      domainsSelected = domainsArg;
    } else if (singleDomain != null) {
      domainsSelected = [singleDomain];
    } else if (widget.domain != null) {
      domainsSelected = [widget.domain!];
    } else {
      domainsSelected = ["General"];
    }

    generalSkillsSelected = generalArg ?? [];

    // Build union of technical skills for domains
    final Set<String> union = <String>{};
    for (final d in domainsSelected) {
      final list = domainSkills[d];
      if (list != null) {
        union.addAll(list);
      }
    }
    // Also add general skills into display so users can select levels for them too if you want
    union.addAll(generalSkillsSelected);

    displaySkills = union.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final domainsLabel = domainsSelected.join(', ');

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const Navbar(currentPage: 'Skills'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Skills for: $domainsLabel",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select proficiency for the skills below. General skills (soft) are included at the top.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Skill list
                Column(
                  children: displaySkills.map((skill) {
                    final level = selectedSkills[skill];
                    final bool selected = level != null;
                    return GestureDetector(
                      onTap: () => _showLevelPopup(context, skill),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryBlue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.primaryBlue : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // skill text + level
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: selected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  level ?? "Tap to select level",
                                  style: TextStyle(
                                    color: selected ? Colors.white70 : Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    if (selectedSkills.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select at least one skill level."), behavior: SnackBarBehavior.floating),
                      );
                      return;
                    }

                    // Final payload: domains + generalSkills + selected technical skills (skill->level)
                    Navigator.pushReplacementNamed(
                      context,
                      '/matching',
                      arguments: {
                        'domains': domainsSelected,
                        'generalSkills': generalSkillsSelected,
                        'selectedSkills': Map<String, String>.from(selectedSkills),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 12),
                Text("${selectedSkills.length} skill(s) selected", style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _footer(),
    );
  }

  void _showLevelPopup(BuildContext context, String skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Select Level for $skill"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: levels.map((level) {
              final selected = selectedSkills[skill] == level;
              return ListTile(
                title: Text(
                  level,
                  style: TextStyle(
                    color: selected ? AppColors.primaryBlue : Colors.black87,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() => selectedSkills[skill] = level);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      color: AppColors.footerBlue,
      padding: const EdgeInsets.all(16),
      child: const Text('© 2025 InternConnect. All rights reserved.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
    );
  }
}
