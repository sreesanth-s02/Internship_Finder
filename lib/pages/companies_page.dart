import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../theme/app_colors.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _paidFilter = 'any'; // any / paid / unpaid
  String _modeFilter = 'any'; // any / remote / onsite
  String _stipendFilter = 'any'; // any / 0-5 / 5-15 / 15+
  String _searchTerm = '';

  // ---------------------------------------------------------------------------
  // MOCK INTERNSHIPS (frontend only, no backend call => no CORS)
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> _allInternships = [
    {
      'id': 1,
      'name': 'DataForge Labs',
      'role': 'Data Science Intern',
      'domains': ['Data Science', 'Machine Learning'],
      'skills': ['Python', 'Pandas', 'SQL', 'TensorFlow'],
      'location': 'Chennai',
      'mode': 'onsite',
      'paid': true,
      'stipend': 15000,
      'about':
          'DataForge Labs works on building data pipelines, dashboards and ML models for real business problems.',
      'prerequisites':
          'Strong Python skills, curiosity to explore data and willingness to learn.',
      'extra':
          'Certificate, letter of recommendation and chance to convert to full-time role.',
    },
    {
      'id': 2,
      'name': 'FinTrack',
      'role': 'Data Analyst Intern',
      'domains': ['Data Science', 'Web Development'],
      'skills': ['Python', 'SQL', 'Tableau'],
      'location': 'Remote',
      'mode': 'remote',
      'paid': true,
      'stipend': 13000,
      'about':
          'FinTrack builds tools to track personal finances and investment portfolios.',
      'prerequisites': 'Good communication skills and basic statistics.',
      'extra': 'Flexible working hours, remote-first team.',
    },
    {
      'id': 3,
      'name': 'PixelCraft Studios',
      'role': 'Frontend Web Intern',
      'domains': ['Web Development'],
      'skills': ['HTML', 'CSS', 'JavaScript', 'React'],
      'location': 'Bengaluru',
      'mode': 'onsite',
      'paid': true,
      'stipend': 10000,
      'about':
          'PixelCraft designs modern, responsive websites for startups and creators.',
      'prerequisites': 'Basic React knowledge and a small portfolio.',
      'extra': 'You will work with designers and another senior developer.',
    },
    {
      'id': 4,
      'name': 'CloudNova',
      'role': 'Cloud & DevOps Intern',
      'domains': ['Cloud Computing'],
      'skills': ['AWS', 'Docker', 'CI/CD'],
      'location': 'Hyderabad',
      'mode': 'remote',
      'paid': false,
      'stipend': 0,
      'about':
          'CloudNova helps companies migrate their infrastructure to the cloud.',
      'prerequisites': 'Comfortable with Linux and basic networking concepts.',
      'extra': 'Hands-on experience deploying services to AWS.',
    },
    {
      'id': 5,
      'name': 'SecureGate',
      'role': 'Cybersecurity Intern',
      'domains': ['Cybersecurity'],
      'skills': ['Python', 'Kali Linux', 'Burp Suite'],
      'location': 'Pune',
      'mode': 'onsite',
      'paid': true,
      'stipend': 8000,
      'about':
          'SecureGate performs security audits and penetration testing for clients.',
      'prerequisites': 'Basic understanding of networks and web applications.',
      'extra': 'You will shadow senior security engineers on live projects.',
    },
  ];

  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get _filteredInternships {
    return _allInternships.where((company) {
      final String name = (company['name'] ?? '').toString().toLowerCase();
      final String role = (company['role'] ?? '').toString().toLowerCase();
      final List<String> domains =
          (company['domains'] as List?)?.cast<String>() ?? [];
      final String mode = (company['mode'] ?? '').toString().toLowerCase();
      final bool paid = company['paid'] == true;
      final int stipend = (company['stipend'] ?? 0) as int;

      // search
      if (_searchTerm.isNotEmpty) {
        final String q = _searchTerm.toLowerCase();
        final bool matchesText =
            name.contains(q) || role.contains(q) || domains.join(',').toLowerCase().contains(q);
        if (!matchesText) return false;
      }

      // paid filter
      if (_paidFilter == 'paid' && !paid) return false;
      if (_paidFilter == 'unpaid' && paid) return false;

      // mode filter
      if (_modeFilter == 'remote' && mode != 'remote') return false;
      if (_modeFilter == 'onsite' && mode != 'onsite') return false;

      // stipend filter
      if (_stipendFilter == '0-5' && stipend > 5000) return false;
      if (_stipendFilter == '5-15' &&
          !(stipend >= 5000 && stipend <= 15000 && stipend > 0)) {
        return false;
      }
      if (_stipendFilter == '15+' && stipend < 15000) return false;

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final results = _filteredInternships;

    return Scaffold(
      appBar: const Navbar(currentPage: 'Companies'),
      body: Column(
        children: [
          // search + filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() {
                      _searchTerm = v.trim();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search companies or roles...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _toggleChip(
                        label: 'Paid',
                        active: _paidFilter == 'paid',
                        onTap: () => setState(() => _paidFilter =
                            _paidFilter == 'paid' ? 'any' : 'paid'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: 'Unpaid',
                        active: _paidFilter == 'unpaid',
                        onTap: () => setState(() => _paidFilter =
                            _paidFilter == 'unpaid' ? 'any' : 'unpaid'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: 'Remote',
                        active: _modeFilter == 'remote',
                        onTap: () => setState(() => _modeFilter =
                            _modeFilter == 'remote' ? 'any' : 'remote'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: 'Onsite',
                        active: _modeFilter == 'onsite',
                        onTap: () => setState(() => _modeFilter =
                            _modeFilter == 'onsite' ? 'any' : 'onsite'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: 'Any stipend',
                        active: _stipendFilter == 'any',
                        onTap: () =>
                            setState(() => _stipendFilter = 'any'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: '0-5k',
                        active: _stipendFilter == '0-5',
                        onTap: () => setState(() => _stipendFilter =
                            _stipendFilter == '0-5' ? 'any' : '0-5'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: '5k-15k',
                        active: _stipendFilter == '5-15',
                        onTap: () => setState(() => _stipendFilter =
                            _stipendFilter == '5-15' ? 'any' : '5-15'),
                      ),
                      const SizedBox(width: 8),
                      _toggleChip(
                        label: '15k+',
                        active: _stipendFilter == '15+',
                        onTap: () => setState(() => _stipendFilter =
                            _stipendFilter == '15+' ? 'any' : '15+'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _paidFilter = 'any';
                            _modeFilter = 'any';
                            _stipendFilter = 'any';
                            _searchController.clear();
                            _searchTerm = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${results.length} internship(s) found',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No internships found'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final company = results[index];
                      return _buildCompanyCard(context, company, isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------

  Widget _toggleChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildCompanyCard(
      BuildContext context, Map<String, dynamic> company, bool isMobile) {
    final String name = (company['name'] ?? 'Unknown').toString();
    final String role = (company['role'] ?? '').toString();
    final List<String> domains =
        (company['domains'] as List?)?.cast<String>() ?? [];
    final List<String> skills =
        (company['skills'] as List?)?.cast<String>() ?? [];
    final String mode = (company['mode'] ?? 'remote').toString();
    final bool paid = company['paid'] == true;
    final int stipend = (company['stipend'] ?? 0) as int;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue, // dark blue card
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // company avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accentOrange,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),

            // main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (role.isNotEmpty)
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  if (domains.isNotEmpty)
                    Text(
                      domains.join(', '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: -4,
                    children: skills.take(4).map((s) {
                      return Chip(
                        label: Text(
                          s,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.white,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          mode,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          paid ? '₹$stipend' : 'Unpaid',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // actions
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/companyDetails',
                      arguments: {'company': company},
                    );
                  },
                  child: const Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
