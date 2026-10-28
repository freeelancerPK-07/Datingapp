import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/screens/login_screen.dart';
import 'package:version1/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Edge-to-edge system overlays with dark status icons for top blue sky area
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Bleed Skybound Together Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/skybound_together.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0F172A),
                child: const Center(
                  child: Icon(Icons.favorite_rounded, color: Color(0xFF007A78), size: 64),
                ),
              ),
            ),
          ),

          // 2. Safe Area with Top Center-Focused Content and Bottom Actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),

                  // Top Center-Focused Headline (In the open blue sky area)
                  Text(
                    'Your Real Connection,\nOn Demand',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A), // Pure Bold Black/Dark Slate
                      height: 1.18,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Top Center-Focused Subtitle (Grey)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Connect with verified creators and genuine matches whenever you need. Real talks, instant video vibes.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: const Color(0xFF334155), // Refined Charcoal Grey
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Spacer leaves the middle area (couple & hearts) completely open and unobstructed!
                  const Spacer(),

                  // Bottom Sleek Black Pill Button
                  GestureDetector(
                    key: const ValueKey('get_started_btn'),
                    onTap: () {
                      Navigator.of(context).push(
                        _createSmoothRoute(const SignUpScreen()),
                      );
                    },
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111), // Bold Black
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom "Already have an account? Sign In" (Grey & Black)
                  GestureDetector(
                    key: const ValueKey('welcome_signin_btn'),
                    onTap: () {
                      Navigator.of(context).push(
                        _createSmoothRoute(const LoginScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text.rich(
                        TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563), // Grey
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF111111), // Bold Black
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Route _createSmoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}
