// lib/widgets/navbar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../services/auth_service.dart';

/// Navbar that uses AuthProvider to know if user is logged in.
/// - If logged in: shows avatar + Logout
/// - If not logged in: shows Login / Register buttons
class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final String currentPage;
  const Navbar({super.key, this.currentPage = ''});

  @override
  State<Navbar> createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    AuthProvider? auth;
    try {
      auth = Provider.of<AuthProvider>(context); // listen: true
    } catch (_) {
      auth = null;
    }

    final bool loggedIn =
        auth != null && auth.token != null && auth.token!.isNotEmpty;

    final String? initials = auth?.user?.email != null &&
            auth!.user!.email!.isNotEmpty
        ? auth.user!.email![0].toUpperCase()
        : null;

    final isMobile = MediaQuery.of(context).size.width < 700;

    return AppBar(
      elevation: 2,
      backgroundColor: AppColors.primaryBlue,
      titleSpacing: 16,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Row(
        children: [
          const Text(
            'InternConnect',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          if (!isMobile) ...[
            _navButton(context, 'Home', '/'),
            const SizedBox(width: 8),
            _navButton(context, 'About', '/about'),
            const SizedBox(width: 8),
            _navButton(context, 'Features', '/features'),
            const SizedBox(width: 8),
            _navButton(context, 'Contact', '/contact'),
          ],
        ],
      ),
      actions: [
        if (loggedIn) ...[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials ?? 'U',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Logout',
                  onPressed: () async {
                    if (auth != null) {
                      await auth.logout();
                    }
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      // ignore: use_build_context_synchronously
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _navButton(BuildContext context, String label, String route) {
    final active = widget.currentPage.toLowerCase() == label.toLowerCase();
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: active
            ? BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
