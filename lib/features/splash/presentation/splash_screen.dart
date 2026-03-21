import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Center(
        child: const Text(
          'Attenly',
          style: TextStyle(
            color: Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutBack)
        .then(delay: 500.ms)
        .fadeOut(duration: 400.ms),
      ),
    );
  }
}
