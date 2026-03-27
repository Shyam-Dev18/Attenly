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
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                  .scale(begin: const Offset(0.78, 0.78), duration: 700.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 22),
              const Text(
                'Attenly',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 750.ms, delay: 120.ms)
                  .slideY(begin: 0.14, end: 0, duration: 750.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}
