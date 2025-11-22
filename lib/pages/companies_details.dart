import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class CompanyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> company;
  const CompanyDetailsPage({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final String name = (company['name'] ?? 'Unknown').toString();
    final String role = (company['role'] ?? '').toString();
    final List<String> domains =
        (company['domains'] as List?)?.cast<String>() ?? [];
    final List<String> skills =
        (company['skills'] as List?)?.cast<String>() ?? [];
    final String mode = (company['mode'] ?? '').toString();
    final String location = (company['location'] ?? 'Not specified').toString();
    final bool paid = company['paid'] == true;
    final int stipend = (company['stipend'] ?? 0) as int;

    final String about =
        (company['about'] ?? 'No description available.').toString();
    final String prereq =
        (company['prerequisites'] ?? 'Not specified.').toString();
    final String extra = (company['extra'] ?? 'Not specified.').toString();

    return Scaffold(
      appBar: const Navbar(currentPage: 'Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left blue panel
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.accentOrange,
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (role.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              role,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '$location • ${mode[0].toUpperCase()}${mode.substring(1)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (domains.isNotEmpty)
                            Text(
                              domains.join(', '),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Stipend: ${paid ? "₹$stipend" : "Unpaid"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/apply',
                                arguments: {'company': company},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              minimumSize:
                                  const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Apply Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right white detail section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailSection(
                            title: 'About Company',
                            content: about,
                          ),
                          _detailSection(
                            title: 'Domains',
                            content: domains.isEmpty
                                ? 'Not specified'
                                : domains.join(', '),
                          ),
                          _detailSection(
                            title: 'Required Skills',
                            content: skills.isEmpty
                                ? 'Not specified'
                                : '• ${skills.join('\n• ')}',
                          ),
                          _detailSection(
                            title: 'Prerequisites',
                            content: prereq,
                          ),
                          _detailSection(
                            title: 'Stipend',
                            content: paid
                                ? '₹$stipend per month'
                                : 'Unpaid internship',
                          ),
                          _detailSection(
                            title: 'Additional Info',
                            content: extra,
                          ),
                        ],
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

  Widget _detailSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.accentOrange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
