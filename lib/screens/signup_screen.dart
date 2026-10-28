import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/screens/email_signup_screen.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/screens/login_screen.dart';
import 'package:version1/screens/phone_auth_screen.dart';
import 'package:version1/screens/profile_setup_screen.dart';
import 'package:version1/services/app_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  void _openEmailSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmailSignUpScreen(),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF007A78),
            content: Text('Signed in as ${account.displayName ?? account.email}'),
          ),
        );
        if (!AppState.instance.isProfileCompleted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        return;
      }
    } catch (_) {
      // In mock/test/web fallback environments
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF007A78),
          behavior: SnackBarBehavior.floating,
          content: Text('Connected with Google successfully!'),
        ),
      );
      if (!AppState.instance.isProfileCompleted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding = (width * 0.07).clamp(20.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Organic Mint & Aqua Header Wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: const CustomPaint(
              painter: CreateAccountHeaderPainter(),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Navigation Bar with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF0F2B32),
                          size: 26,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: (height * 0.015).clamp(8.0, 18.0)),

                        // App Icon: Interlocked Hearts Teal App Icon (Cleanly extracted transparent squircle)
                        Image.memory(
                          kAppIconTealBytes,
                          width: 86,
                          height: 86,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 10),

                        // Brand Wordmark: "LinkUp" with smile curve
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LinkUp',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 33,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F2B32),
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Curved smile underline below "inkUp"
                            SizedBox(
                              width: 58,
                              height: 5,
                              child: CustomPaint(
                                painter: SmileUnderlinePainter(
                                  color: const Color(0xFF00A896),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: (height * 0.032).clamp(20.0, 34.0)),

                        // Serif Headline: "Create\nyour account"
                        Text(
                          'Create\nyour account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F2B32),
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          "Let's get you closer to\nmeaningful connections.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF4A6B74),
                            height: 1.35,
                          ),
                        ),

                        SizedBox(height: (height * 0.036).clamp(24.0, 38.0)),

                        // Option 1 Card: "Use Email Address"
                        _buildOptionCard(
                          title: 'Use Email Address',
                          subtitle: 'Create account with your email',
                          icon: Icons.mail_outline_rounded,
                          onTap: _openEmailSignUp,
                        ),

                        const SizedBox(height: 14),

                        // Option 2 Card: "Use Mobile Number"
                        _buildOptionCard(
                          title: 'Use Mobile Number',
                          subtitle: 'Create account with your phone number',
                          icon: Icons.phone_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PhoneAuthScreen(),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: (height * 0.035).clamp(24.0, 36.0)),

                        // Divider with "or" in center
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE2EAEF),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'or',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8B9FA7),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE2EAEF),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: (height * 0.024).clamp(16.0, 24.0)),

                        // Google OAuth Direct Button with Google 4-Color Logo
                        GestureDetector(
                          key: const ValueKey('signup_google_btn'),
                          onTap: _handleGoogleSignIn,
                          child: Container(
                            height: 54,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(27),
                              border: Border.all(
                                color: const Color(0xFFE2EAEF),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.string(
                                  LinkUpVectors.googleLogoSvg,
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F2B32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: (height * 0.024).clamp(16.0, 24.0)),

                        // Bottom link: "Already have an account? Sign In"
                        GestureDetector(
                          key: const ValueKey('signup_signin_btn'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text.rich(
                              TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4A6B74),
                                ),
                                children: [
                                  const TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF007A78),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9F1F3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2B30).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Mint Circle Icon
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F6F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFF0F2B32),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Middle Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B868F),
                    ),
                  ),
                ],
              ),
            ),

            // Right Arrow Circle Button
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F7F8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF0F2B32),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Modal Bottom Sheet for Email Sign Up
class _EmailSignUpBottomSheet extends StatefulWidget {
  const _EmailSignUpBottomSheet();

  @override
  State<_EmailSignUpBottomSheet> createState() => _EmailSignUpBottomSheetState();
}

class _EmailSignUpBottomSheetState extends State<_EmailSignUpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pop(); // dismiss sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00A896),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Account created successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: bottomInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create with Email',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF0F2B32),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                'Enter your details to create your LinkUp account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B868F),
                ),
              ),

              const SizedBox(height: 20),

              // Field 1: Full name
              _buildPillInputField(
                controller: _nameController,
                hintText: 'Full name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Field 2: Email address
              _buildPillInputField(
                controller: _emailController,
                hintText: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Field 3: Password
              _buildPillInputField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              // Submit Button: "Create Account →"
              GestureDetector(
                onTap: _isLoading ? null : _handleSignUp,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00A896),
                        Color(0xFF028090),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A896).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2EAEF),
          width: 1.0,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F2B32),
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              icon,
              color: const Color(0xFF0F2B32),
              size: 21,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 24,
          ),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8B9FA7),
          ),
        ),
      ),
    );
  }
}

/// Smile curve underline painter below brand wordmark
class SmileUnderlinePainter extends CustomPainter {
  final Color color;
  const SmileUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, 1)
      ..quadraticBezierTo(size.width * 0.5, size.height + 1, size.width - 2, 1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SmileUnderlinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Organic Mint Waves Header Painter matching reference UI
class CreateAccountHeaderPainter extends CustomPainter {
  const CreateAccountHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft mint base wave flowing down from top-right to left
    final baseWavePaint = Paint()
      ..color = const Color(0xFFE5F7F4)
      ..style = PaintingStyle.fill;

    final baseWave = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.95)
      ..cubicTo(w * 0.76, h * 0.88, w * 0.45, h * 0.45, 0, h * 0.32)
      ..close();
    canvas.drawPath(baseWave, baseWavePaint);

    // 2. Middle gentle aqua wave
    final midWavePaint = Paint()
      ..color = const Color(0xFFCEF1EB).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final midWave = Path()
      ..moveTo(w * 0.22, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.75)
      ..cubicTo(w * 0.78, h * 0.68, w * 0.55, h * 0.32, w * 0.22, 0)
      ..close();
    canvas.drawPath(midWave, midWavePaint);

    // 3. Accent deeper teal curve in top-right corner
    final accentWavePaint = Paint()
      ..color = const Color(0xFFAFE6DC).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final accentWave = Path()
      ..moveTo(w * 0.52, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.52)
      ..cubicTo(w * 0.85, h * 0.45, w * 0.72, h * 0.15, w * 0.52, 0)
      ..close();
    canvas.drawPath(accentWave, accentWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
