// lib/main.dart
import 'package:flutter/material.dart';
import 'package:internconnect_webapp_flutter/pages/profile_page.dart';
import 'theme/app_colors.dart';

// pages
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/about.dart';
import 'pages/contact.dart';
import 'pages/features.dart';
import 'pages/forgot_password.dart';

// New Pages
import 'pages/domain_page.dart';
import 'pages/general_skills_page.dart';
import 'pages/skills_page.dart';
import 'pages/matching_page.dart';
import 'pages/companies_page.dart';
import 'pages/companies_details.dart';
import 'pages/apply_page.dart'; // <-- NEW

import 'services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const InternConnectApp(),
    ),
  );
}

class InternConnectApp extends StatelessWidget {
  const InternConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.accentOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/features': (context) => const FeaturesPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/domain': (context) => const DomainPage(),
        '/matching': (context) => const MatchingPage(),
        '/companies': (context) => const CompaniesPage(),
        '/profile': (context) => const ProfilePage(),
        '/apply': (context) => const ApplyPage(),
        },

      onGenerateRoute: (settings) {
        if (settings.name == '/skills') {
          final args = settings.arguments as Map<String, dynamic>?;
          final domain = args?['domain'] as String?;
          return MaterialPageRoute(
            builder: (context) => SkillsPage(domain: domain),
            settings: settings,
          );
        }

        if (settings.name == '/general_skills') {
          return MaterialPageRoute(
            builder: (context) => const GeneralSkillsPage(),
            settings: settings,
          );
        }

        if (settings.name == '/companyDetails') {
          final args = settings.arguments as Map<String, dynamic>?;
          final company = args?['company'] as Map<String, dynamic>?;
          if (company != null) {
            return MaterialPageRoute(
              builder: (context) => CompanyDetailsPage(company: company),
              settings: settings,
            );
          }
        }

        // Fallback: unknown route
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
          settings: settings,
        );
      },
    );
  }
}
