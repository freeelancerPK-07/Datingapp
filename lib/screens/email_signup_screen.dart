import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:version1/screens/phone_auth_screen.dart';
import 'package:version1/screens/profile_setup_screen.dart';
import 'package:version1/screens/signup_screen.dart';
import 'package:version1/services/app_state.dart';

/// Full-Page Email Sign Up Screen matching LinkUp Account Creation design
class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00A896),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
      });
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

          // 2. Main Scrollable Form Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Navigation Bar with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 4.0,
                  ),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: (height * 0.012).clamp(6.0, 16.0)),

                          // App Icon: Interlocked Hearts Teal App Icon (256x256 clean squircle)
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

                          SizedBox(height: (height * 0.026).clamp(18.0, 30.0)),

                          // Serif Headline: "Create your account"
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 33,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Create ',
                                  style: TextStyle(color: Color(0xFF0F2B32)),
                                ),
                                TextSpan(
                                  text: 'your account',
                                  style: TextStyle(color: Color(0xFF005B66)),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Sign up with your email to get started\non LinkUp.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF4A6B74),
                              height: 1.35,
                            ),
                          ),

                          SizedBox(height: (height * 0.030).clamp(20.0, 32.0)),

                          // Field 1: Email address
                          _buildPillInputField(
                            key: const ValueKey('email_field'),
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

                          const SizedBox(height: 14),

                          // Field 2: Full name
                          _buildPillInputField(
                            key: const ValueKey('name_field'),
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

                          const SizedBox(height: 14),

                          // Field 3: Password
                          _buildPillInputField(
                            key: const ValueKey('password_field'),
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

                          SizedBox(height: (height * 0.030).clamp(20.0, 32.0)),

                          // CTA Button: "Continue →" (Deep teal pill button)
                          GestureDetector(
                            key: const ValueKey('email_continue_btn'),
                            onTap: _isLoading ? null : _handleSignUp,
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(27),
                                color: const Color(0xFF005159),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF005159)
                                        .withValues(alpha: 0.28),
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Continue',
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
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(height: (height * 0.026).clamp(18.0, 28.0)),

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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
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

                          SizedBox(height: (height * 0.026).clamp(18.0, 28.0)),

                          // Alternate Pill Option: "Create with mobile number →"
                          GestureDetector(
                            key: const ValueKey('create_with_mobile_btn'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PhoneAuthScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F6F4),
                                borderRadius: BorderRadius.circular(27),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFCEF0EB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.phone_outlined,
                                        color: Color(0xFF005159),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Create with mobile number',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F2B32),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6.0),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Color(0xFF005159),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
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

  Widget _buildPillInputField({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2EAEF),
          width: 1.1,
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
