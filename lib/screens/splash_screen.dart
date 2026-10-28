import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:version1/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;
  bool _navigated = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();

    // Gentle fade-in entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    // Auto-navigate to 2nd screen (WelcomeScreen) after 1.8s
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      _navigateToWelcome();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      // Pre-cache 2MB Welcome Screen background asset in RAM/GPU to eliminate transition lag
      precacheImage(const AssetImage('assets/images/skybound_together.png'), context);
      precacheImage(const AssetImage('assets/images/linkup_splash.png'), context);
    }
  }

  void _navigateToWelcome() {
    _navigationTimer?.cancel();
    if (!mounted || _navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8FEFB),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FEFB),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToWelcome, // Tap anywhere to skip directly to WelcomeScreen
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SizedBox.expand(
            child: Image.asset(
              'assets/images/linkup_splash.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text(
                  'LinkUp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
