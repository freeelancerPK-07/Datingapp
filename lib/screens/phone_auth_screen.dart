import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:version1/screens/profile_setup_screen.dart';
import 'package:version1/screens/signup_screen.dart';
import 'package:version1/services/app_state.dart';

/// Supported Country definition for phone verification
class CountryItem {
  final String name;
  final String dialCode;
  final String flag;
  final int minDigits;
  final int maxDigits;

  const CountryItem({
    required this.name,
    required this.dialCode,
    required this.flag,
    this.minDigits = 10,
    this.maxDigits = 10,
  });
}

const List<CountryItem> kSupportedCountries = [
  CountryItem(name: 'India', dialCode: '+91', flag: '🇮🇳', minDigits: 10, maxDigits: 10),
  CountryItem(name: 'United States', dialCode: '+1', flag: '🇺🇸', minDigits: 10, maxDigits: 10),
  CountryItem(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧', minDigits: 10, maxDigits: 10),
  CountryItem(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪', minDigits: 9, maxDigits: 9),
  CountryItem(name: 'Singapore', dialCode: '+65', flag: '🇸🇬', minDigits: 8, maxDigits: 8),
  CountryItem(name: 'Canada', dialCode: '+1', flag: '🇨🇦', minDigits: 10, maxDigits: 10),
  CountryItem(name: 'Australia', dialCode: '+61', flag: '🇦🇺', minDigits: 9, maxDigits: 9),
  CountryItem(name: 'Germany', dialCode: '+49', flag: '🇩🇪', minDigits: 10, maxDigits: 11),
  CountryItem(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦', minDigits: 9, maxDigits: 9),
  CountryItem(name: 'France', dialCode: '+33', flag: '🇫🇷', minDigits: 9, maxDigits: 9),
];

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  CountryItem _selectedCountry = kSupportedCountries.first; // Default India 🇮🇳 +91

  // 6-digit OTP fields
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isPhoneValid = false;
  String? _phoneValidationError;

  bool _isSendingOtp = false;
  bool _isOtpSent = false;
  String _confirmedPhoneNumber = '';

  bool _isVerifyingOtp = false;
  String? _otpErrorMessage;

  Timer? _countdownTimer;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    for (int i = 0; i < 6; i++) {
      _otpFocusNodes[i].addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _validatePhone() {
    final text = _phoneController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isPhoneValid = false;
        _phoneValidationError = null;
      });
      return;
    }

    if (_selectedCountry.dialCode == '+91') {
      if (text.length != 10) {
        setState(() {
          _isPhoneValid = false;
          _phoneValidationError = text.length > 10
              ? 'Enter a valid 10-digit mobile number'
              : null;
        });
        return;
      }
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
        setState(() {
          _isPhoneValid = false;
          _phoneValidationError = 'Indian mobile numbers must start with 6, 7, 8, or 9';
        });
        return;
      }
    } else {
      if (text.length < _selectedCountry.minDigits || text.length > _selectedCountry.maxDigits) {
        setState(() {
          _isPhoneValid = false;
          _phoneValidationError = 'Enter a valid ${_selectedCountry.minDigits}-digit phone number';
        });
        return;
      }
    }

    setState(() {
      _isPhoneValid = true;
      _phoneValidationError = null;
    });
  }

  String _formatPhoneNumber(String dialCode, String number) {
    if (number.length == 10) {
      return '$dialCode ${number.substring(0, 5)} ${number.substring(5)}';
    }
    return '$dialCode $number';
  }

  Future<void> _handleSendOtp() async {
    if (!_isPhoneValid || _isSendingOtp) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSendingOtp = true;
      _otpErrorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      setState(() {
        _isSendingOtp = false;
        _isOtpSent = true;
        _confirmedPhoneNumber = _formatPhoneNumber(
          _selectedCountry.dialCode,
          _phoneController.text.trim(),
        );
      });

      _startResendCountdown();

      for (final c in _otpControllers) {
        c.clear();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_otpFocusNodes[0].canRequestFocus) {
          _otpFocusNodes[0].requestFocus();
        }
      });

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
                  'Verification code sent successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text(
            'Failed to send code. Please try again.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend || _isSendingOtp) return;
    await _handleSendOtp();
  }

  void _handleBack() {
    if (_isOtpSent) {
      setState(() {
        _isOtpSent = false;
        _otpErrorMessage = null;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  bool get _isOtpComplete {
    return _otpControllers.every((c) => c.text.trim().isNotEmpty);
  }

  String get _enteredOtp {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  Future<void> _handleVerifyOtp() async {
    if (!_isOtpComplete || _isVerifyingOtp) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isVerifyingOtp = true;
      _otpErrorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      final otp = _enteredOtp;

      if (otp.length != 6) {
        setState(() {
          _isVerifyingOtp = false;
          _otpErrorMessage = 'Please enter the complete 6-digit code';
        });
        return;
      }

      setState(() {
        _isVerifyingOtp = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: const [
              Icon(Icons.verified_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone verified! Welcome to LinkUp.',
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifyingOtp = false;
        _otpErrorMessage = 'Invalid or expired verification code. Try again.';
      });
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCountries = kSupportedCountries.where((c) {
              final query = searchQuery.toLowerCase();
              return c.name.toLowerCase().contains(query) ||
                  c.dialCode.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
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
                  Text(
                    'Select Country',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search country or code...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF4F8F8),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2EAEF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2EAEF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF00A896)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCountries.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected = country.dialCode == _selectedCountry.dialCode &&
                            country.name == _selectedCountry.name;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF00A896) : const Color(0xFF0F2B32),
                            ),
                          ),
                          trailing: Text(
                            country.dialCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFF00A896) : const Color(0xFF6B868F),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                            _validatePhone();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = digits[i];
        }
        _otpFocusNodes[5].requestFocus();
        setState(() {});
        return;
      } else {
        _otpControllers[index].text = value.substring(value.length - 1);
      }
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
    setState(() {});
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
                        onPressed: _handleBack,
                      ),
                    ],
                  ),
                ),

                // Animated step switcher (One by One)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _isOtpSent
                        ? _buildStep2VerificationCode(horizontalPadding, height)
                        : _buildStep1MobileNumber(horizontalPadding, height),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: "Enter your mobile number" (Exact match to reference image left page)
  Widget _buildStep1MobileNumber(double horizontalPadding, double height) {
    return SingleChildScrollView(
      key: const ValueKey('step_mobile_number'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: (height * 0.015).clamp(8.0, 18.0)),

          // Centered App Icon (Extracted 256 teal squircle with interlocking hearts)
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
                  fontSize: 32,
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

          SizedBox(height: (height * 0.035).clamp(24.0, 36.0)),

          // Serif Headline: "Enter your\nmobile number"
          Text(
            'Enter your\nmobile number',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B3036),
              height: 1.18,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          Text(
            "We'll send a verification code\nto your number.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5A7A84),
              height: 1.4,
            ),
          ),

          SizedBox(height: (height * 0.045).clamp(28.0, 42.0)),

          // Phone Number Input Card [ 🇮🇳 +91 v | Phone number ]
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFDFD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _phoneValidationError != null
                    ? Colors.redAccent
                    : (_phoneFocusNode.hasFocus
                        ? const Color(0xFF00A896)
                        : const Color(0xFFE2EAEF)),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2B30).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // Country Selector
                GestureDetector(
                  onTap: _showCountryPicker,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry.dialCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F2B32),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0F2B32),
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Vertical Divider
                Container(
                  height: 28,
                  width: 1.2,
                  color: const Color(0xFFE2EAEF),
                ),

                const SizedBox(width: 12),

                // Phone number text field
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F2B32),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone number',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8B9FA7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_phoneValidationError != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _phoneValidationError!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: (height * 0.04).clamp(24.0, 36.0)),

          // Black Pill Action Button: "Continue  →" (or Send OTP)
          GestureDetector(
            key: const ValueKey('send_otp_btn'),
            onTap: _isSendingOtp ? null : _handleSendOtp,
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF111111), // Bold Black
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isSendingOtp
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
                            'Continue',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Step 2: "Enter the verification code" (Exact match to reference image right page)
  Widget _buildStep2VerificationCode(double horizontalPadding, double height) {
    return SingleChildScrollView(
      key: const ValueKey('step_verification_code'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: (height * 0.015).clamp(8.0, 18.0)),

          // Centered App Icon (Extracted 256 teal squircle with interlocking hearts)
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
                  fontSize: 32,
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

          SizedBox(height: (height * 0.035).clamp(24.0, 36.0)),

          // Serif Headline: "Enter the\nverification code"
          Text(
            'Enter the\nverification code',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B3036),
              height: 1.18,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle with formatted phone number
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5A7A84),
                height: 1.4,
              ),
              children: [
                const TextSpan(text: "We've sent a 6-digit code to\n"),
                TextSpan(
                  text: _confirmedPhoneNumber,
                  style: const TextStyle(
                    color: Color(0xFF0B3036),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: (height * 0.045).clamp(28.0, 42.0)),

          // 6 OTP Digit Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final isFilled = _otpControllers[index].text.isNotEmpty;
              final isFocused = _otpFocusNodes[index].hasFocus;

              return Container(
                width: 48,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFDFD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFF00A896)
                        : (isFilled
                            ? const Color(0xFF0F2B32)
                            : const Color(0xFFE2EAEF)),
                    width: isFocused ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    if (isFocused)
                      BoxShadow(
                        color: const Color(0xFF00A896).withValues(alpha: 0.16),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F2B32),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (val) => _onOtpDigitChanged(index, val),
                  ),
                ),
              );
            }),
          ),

          if (_otpErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _otpErrorMessage!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.redAccent,
              ),
            ),
          ],

          SizedBox(height: (height * 0.035).clamp(20.0, 32.0)),

          // Resend Timer: "Didn't get a code? Resend in 00:30"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't get a code? ",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5A7A84),
                ),
              ),
              GestureDetector(
                onTap: _canResend ? _handleResendOtp : null,
                child: Text(
                  _canResend
                      ? 'Resend OTP'
                      : 'Resend in 00:${_resendCountdown.toString().padLeft(2, '0')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00A896),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: (height * 0.035).clamp(24.0, 36.0)),

          // Black Pill Action Button: "Verify  →"
          GestureDetector(
            key: const ValueKey('verify_otp_btn'),
            onTap: _isVerifyingOtp ? null : _handleVerifyOtp,
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF111111), // Bold Black
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: _isVerifyingOtp
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
                            'Verify',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
