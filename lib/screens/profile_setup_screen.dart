import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/user_profile_model.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/app_image.dart';

/// 10-Step Dating App Profile Setup Onboarding Screen
/// Matches the exact pixel-perfect design specifications & UI mockup.
class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late PageController _pageController;
  int _currentStep = 1; // 1 to 10

  // Profile Form State
  late TextEditingController _nameController;
  DateTime? _selectedDob;
  String _selectedGender = '';
  String _selectedPhotoUrl = '';
  late TextEditingController _bioController;
  final List<String> _selectedInterests = [];
  final List<String> _selectedLanguages = [];
  String _selectedCity = '';
  String _selectedState = '';
  String _selectedCountry = 'India';

  bool _notificationsEnabled = true;
  bool _cameraEnabled = true;
  bool _microphoneEnabled = true;

  bool _isUploadingPhoto = false;
  bool _isSavingFinalProfile = false;

  // Search controller for Location screen
  final TextEditingController _locationSearchController = TextEditingController();

  // Curated list of Indian Cities with States
  final List<Map<String, String>> _kPopularCities = const [
    {'city': 'Chennai', 'state': 'Tamil Nadu'},
    {'city': 'Bengaluru', 'state': 'Karnataka'},
    {'city': 'Mumbai', 'state': 'Maharashtra'},
    {'city': 'Delhi', 'state': 'Delhi'},
    {'city': 'Hyderabad', 'state': 'Telangana'},
    {'city': 'Kolkata', 'state': 'West Bengal'},
    {'city': 'Kochi', 'state': 'Kerala'},
    {'city': 'Pune', 'state': 'Maharashtra'},
    {'city': 'Coimbatore', 'state': 'Tamil Nadu'},
    {'city': 'Madurai', 'state': 'Tamil Nadu'},
    {'city': 'Ahmedabad', 'state': 'Gujarat'},
    {'city': 'Jaipur', 'state': 'Rajasthan'},
  ];


  // Available Interests with Emojis
  final List<Map<String, String>> _kAllInterests = const [
    {'title': 'Music', 'icon': '🎵'},
    {'title': 'Dance', 'icon': '💃'},
    {'title': 'Travel', 'icon': '✈️'},
    {'title': 'Movies', 'icon': '🍿'},
    {'title': 'Gaming', 'icon': '🎮'},
    {'title': 'Fitness', 'icon': '🏋️'},
    {'title': 'Food', 'icon': '🍴'},
    {'title': 'Photography', 'icon': '📷'},
    {'title': 'Reading', 'icon': '📖'},
    {'title': 'Animals', 'icon': '🐾'},
    {'title': 'Nature', 'icon': '🍃'},
    {'title': 'Art', 'icon': '🎨'},
    {'title': 'Tech', 'icon': '💻'},
    {'title': 'Coffee', 'icon': '☕'},
    {'title': 'Sports', 'icon': '⚽'},
    {'title': 'Yoga', 'icon': '🧘'},
  ];

  // Available Languages
  final List<String> _kAllLanguages = const [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final initialProfile = AppState.instance.userProfile;
    _currentStep = initialProfile.currentStep.clamp(1, 10);
    _pageController = PageController(initialPage: _currentStep - 1);

    _nameController = TextEditingController(text: initialProfile.name);
    _selectedDob = initialProfile.dob ?? DateTime(2003, 8, 15);
    _selectedGender = initialProfile.gender.isNotEmpty ? initialProfile.gender : 'Male';
    _selectedPhotoUrl = initialProfile.photoUrl;
    _bioController = TextEditingController(text: initialProfile.bio);

    if (initialProfile.interests.isNotEmpty) {
      _selectedInterests.addAll(initialProfile.interests);
    } else {
      _selectedInterests.addAll(['Music', 'Travel', 'Fitness']);
    }

    if (initialProfile.languages.isNotEmpty) {
      _selectedLanguages.addAll(initialProfile.languages);
    } else {
      _selectedLanguages.addAll(['Tamil', 'English', 'Hindi']);
    }

    _selectedCity = initialProfile.city.isNotEmpty ? initialProfile.city : 'Chennai';
    _selectedState = initialProfile.state.isNotEmpty ? initialProfile.state : 'Tamil Nadu';
    _selectedCountry = initialProfile.country;

    _notificationsEnabled = initialProfile.notificationsEnabled;
    _cameraEnabled = initialProfile.cameraEnabled;
    _microphoneEnabled = initialProfile.microphoneEnabled;

    _nameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation Helpers
  // ---------------------------------------------------------------------------
  int get _calculatedAge {
    if (_selectedDob == null) return 0;
    final now = DateTime.now();
    int age = now.year - _selectedDob!.year;
    if (now.month < _selectedDob!.month ||
        (now.month == _selectedDob!.month && now.day < _selectedDob!.day)) {
      age--;
    }
    return age;
  }

  bool get _isAdult => _calculatedAge >= 18;

  bool get _isCurrentStepValid {
    switch (_currentStep) {
      case 1:
        final trimmed = _nameController.text.trim();
        return trimmed.length >= 2 &&
            trimmed.length <= 30 &&
            RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(trimmed);
      case 2:
        return _selectedDob != null && _isAdult;
      case 3:
        return _selectedGender.isNotEmpty;
      case 4:
        return _selectedPhotoUrl.isNotEmpty && !_isUploadingPhoto;
      case 5:
        return _bioController.text.length <= 150;
      case 6:
        return _selectedInterests.length >= 3 && _selectedInterests.length <= 8;
      case 7:
        return _selectedLanguages.isNotEmpty;
      case 8:
        return _selectedCity.isNotEmpty;
      case 9:
        return true;
      case 10:
        return true;
      default:
        return false;
    }
  }

  // Save draft state to AppState
  void _saveDraft() {
    final draft = UserProfile(
      name: _nameController.text.trim(),
      dob: _selectedDob,
      gender: _selectedGender,
      photoUrl: _selectedPhotoUrl,
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
      languages: _selectedLanguages,
      city: _selectedCity,
      state: _selectedState,
      country: _selectedCountry,
      notificationsEnabled: _notificationsEnabled,
      cameraEnabled: _cameraEnabled,
      microphoneEnabled: _microphoneEnabled,
      profileCompleted: false,
      currentStep: _currentStep,
    );
    AppState.instance.saveOnboardingDraft(draft);
  }

  void _goToNextStep() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_currentStep < 10) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
      _saveDraft();
    } else {
      _handleFinalSubmission();
    }
  }

  void _goToPreviousStep() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
      _saveDraft();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleFinalSubmission() async {
    setState(() => _isSavingFinalProfile = true);
    HapticFeedback.heavyImpact();

    // Simulate POST /users/profile API call
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final finalProfile = UserProfile(
      name: _nameController.text.trim(),
      dob: _selectedDob,
      gender: _selectedGender,
      photoUrl: _selectedPhotoUrl,
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
      languages: _selectedLanguages,
      city: _selectedCity,
      state: _selectedState,
      country: _selectedCountry,
      notificationsEnabled: _notificationsEnabled,
      cameraEnabled: _cameraEnabled,
      microphoneEnabled: _microphoneEnabled,
      profileCompleted: true,
      currentStep: 10,
    );

    AppState.instance.completeProfileSetup(finalProfile);

    setState(() => _isSavingFinalProfile = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Profile completed successfully! Welcome to LinkUp.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF007A78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    // Direct to Home Screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // Build Methods
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Back Arrow, Wave Accent & Progress Bar
            _buildTopProgressHeader(),

            // Main 10-step PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Controlled via bottom CTA
                children: [
                  _buildStep1Name(),
                  _buildStep2Birthday(),
                  _buildStep3Gender(),
                  _buildStep4ProfilePhoto(),
                  _buildStep5Bio(),
                  _buildStep6Interests(),
                  _buildStep7Languages(),
                  _buildStep8Location(),
                  _buildStep9Permissions(),
                  _buildStep10AllSet(),
                ],
              ),
            ),

            // Bottom CTA Container
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header with Progress Bar
  // ---------------------------------------------------------------------------
  Widget _buildTopProgressHeader() {
    final progress = _currentStep / 10.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5F7F4),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF0F2B32),
                  size: 24,
                ),
                onPressed: _goToPreviousStep,
              ),
              Expanded(
                child: Text(
                  'Step $_currentStep of 10',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF007A78),
                  ),
                ),
              ),
              if (_currentStep == 5)
                TextButton(
                  onPressed: _goToNextStep,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF007A78),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFCEF1EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007A78)),
            ),
          ),
        ],
      ),
    );
  }

  // Common Header Section for Each Screen
  Widget _buildScreenHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F2B32),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Name
  // ---------------------------------------------------------------------------
  Widget _buildStep1Name() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "What's your name?",
            subtitle: "Let's start with your name.",
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _nameController.text.trim().length >= 2
                    ? const Color(0xFF007A78)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF007A78),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F2B32),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your first name',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_nameController.text.trim().length >= 2)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF007A78), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how it will appear on your LinkUp profile.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Birthday
  // ---------------------------------------------------------------------------
  Widget _buildStep2Birthday() {
    final age = _calculatedAge;
    final isTooYoung = _selectedDob != null && age < 18;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "When's your birthday?",
            subtitle: "You must be at least 18 years old\nto use LinkUp.",
          ),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickBirthdayDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isTooYoung
                      ? const Color(0xFFEF4444)
                      : (_selectedDob != null ? const Color(0xFF007A78) : const Color(0xFFE5E7EB)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF007A78),
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _selectedDob != null
                          ? '${_formatDate(_selectedDob!)} ($age years old)'
                          : 'Select date of birth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _selectedDob != null
                            ? (isTooYoung ? const Color(0xFFEF4444) : const Color(0xFF0F2B32))
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF007A78)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isTooYoung)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You must be at least 18 years old to join LinkUp.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Your age will be calculated automatically',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }

  void _pickBirthdayDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 21, 8, 15),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007A78),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F2B32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
      _saveDraft();
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Gender
  // ---------------------------------------------------------------------------
  Widget _buildStep3Gender() {
    final genders = [
      {'label': 'Male', 'icon': Icons.male_rounded, 'color': const Color(0xFF0284C7)},
      {'label': 'Female', 'icon': Icons.female_rounded, 'color': const Color(0xFFEC4899)},
      {'label': 'Other', 'icon': Icons.person_outline_rounded, 'color': const Color(0xFF10B981)},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "What's your gender?",
            subtitle: "This helps us show you better\nsuggestions.",
          ),
          ...genders.map((g) {
            final isSelected = _selectedGender == g['label'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedGender = g['label'] as String);
                  _saveDraft();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FAF8) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        g['icon'] as IconData,
                        color: g['color'] as Color,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          g['label'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F2B32),
                          ),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007A78) : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                          color: isSelected ? const Color(0xFF007A78) : Colors.transparent,
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: Profile Photo
  // ---------------------------------------------------------------------------
  Widget _buildStep4ProfilePhoto() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "Add a profile photo",
            subtitle: "Add a clear photo of yourself.\nYou can take a photo or choose from gallery.",
          ),
          const SizedBox(height: 8),

          // Circular Photo Preview
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                    border: Border.all(
                      color: const Color(0xFFCEF1EB),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007A78).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selectedPhotoUrl.isNotEmpty
                        ? AppImage(
                            path: _selectedPhotoUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 36,
                                color: Color(0xFF007A78),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add Photo',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF007A78),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_isUploadingPhoto)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Two Action Buttons: Camera & Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPhotoPickerButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => _pickRealPhoto(isCamera: true),
              ),
              const SizedBox(width: 16),
              _buildPhotoPickerButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () => _pickRealPhoto(isCamera: false),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF007A78), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Real photos help build trust and get 3x more connections on LinkUp.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
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

  Widget _buildPhotoPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCEF1EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF007A78), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF007A78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickRealPhoto({required bool isCamera}) async {
    HapticFeedback.selectionClick();
    setState(() => _isUploadingPhoto = true);

    final pickedPath = isCamera
        ? await AppImagePickerService.pickFromCamera()
        : await AppImagePickerService.pickFromGallery();

    if (!mounted) return;
    setState(() => _isUploadingPhoto = false);

    if (pickedPath != null) {
      setState(() {
        _selectedPhotoUrl = pickedPath;
      });
      _saveDraft();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCamera ? 'Photo captured with Camera! 📸' : 'Photo selected from Gallery! 🖼️',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF007A78),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 5: Bio (Skippable)
  // ---------------------------------------------------------------------------
  Widget _buildStep5Bio() {
    final currentLength = _bioController.text.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "Tell us about yourself",
            subtitle: "Write a short bio to help others\nknow you better.",
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _bioController,
                  maxLines: 4,
                  maxLength: 150,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F2B32),
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'E.g. I love traveling, movies and meeting new people...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Text(
                  '$currentLength/150',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: currentLength > 140
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: _goToNextStep,
              child: Text(
                'Skip for now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007A78),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 6: Interests (Min 3, Max 8)
  // ---------------------------------------------------------------------------
  Widget _buildStep6Interests() {
    final count = _selectedInterests.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "What are your interests?",
            subtitle: "Pick at least 3 interests (max 8).",
          ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _kAllInterests.map((item) {
              final title = item['title']!;
              final icon = item['icon']!;
              final isSelected = _selectedInterests.contains(title);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(title);
                    } else {
                      if (_selectedInterests.length < 8) {
                        _selectedInterests.add(title);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maximum 8 interests allowed'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      }
                    }
                  });
                  _saveDraft();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007A78) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF007A78).withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$count selected',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: count >= 3 ? const Color(0xFF007A78) : const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  'Min 3 • Max 8',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 7: Languages
  // ---------------------------------------------------------------------------
  Widget _buildStep7Languages() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "Which languages\ndo you know?",
            subtitle: "Select the languages you're comfortable\nwith.",
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _kAllLanguages.map((lang) {
              final isSelected = _selectedLanguages.contains(lang);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedLanguages.remove(lang);
                    } else {
                      _selectedLanguages.add(lang);
                    }
                  });
                  _saveDraft();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007A78) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF007A78).withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        lang,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 8: Location
  // ---------------------------------------------------------------------------
  Widget _buildStep8Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _buildScreenHeader(
              title: "Where are you located?",
              subtitle: "This helps us show people near you.",
            ),
          ),

          // Auto-detect GPS button
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _selectedCity = 'Chennai';
                _selectedState = 'Tamil Nadu';
              });
              _saveDraft();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCEF1EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFF007A78), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use my current location',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ),
                  const Icon(Icons.my_location_rounded, color: Color(0xFF007A78), size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Or choose manually',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          // Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search city or state',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Selected Location Card
          if (_selectedCity.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF007A78)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF007A78), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_selectedCity, $_selectedState, $_selectedCountry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2B32),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6B7280)),
                    onPressed: () {
                      setState(() {
                        _selectedCity = '';
                        _selectedState = '';
                      });
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Suggested Cities List
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kPopularCities
                .where((item) {
                  final query = _locationSearchController.text.trim().toLowerCase();
                  if (query.isEmpty) return true;
                  return item['city']!.toLowerCase().contains(query) ||
                      item['state']!.toLowerCase().contains(query);
                })
                .take(6)
                .map((loc) {
                  final isSelected = _selectedCity == loc['city'];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCity = loc['city']!;
                        _selectedState = loc['state']!;
                      });
                      _saveDraft();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF007A78) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        '${loc['city']}, ${loc['state']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 9: Permissions
  // ---------------------------------------------------------------------------
  Widget _buildStep9Permissions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "Allow permissions",
            subtitle: "We need a few permissions to give you\nthe best experience.",
          ),
          _buildPermissionTile(
            icon: Icons.notifications_active_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: 'Notifications',
            subtitle: 'Get matches, messages and important updates',
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              _saveDraft();
            },
          ),
          const SizedBox(height: 12),
          _buildPermissionTile(
            icon: Icons.camera_alt_outlined,
            iconBg: const Color(0xFFFCE7F3),
            iconColor: const Color(0xFFDB2777),
            title: 'Camera',
            subtitle: 'Take photos and video calls',
            value: _cameraEnabled,
            onChanged: (val) {
              setState(() => _cameraEnabled = val);
              _saveDraft();
            },
          ),
          const SizedBox(height: 12),
          _buildPermissionTile(
            icon: Icons.mic_none_outlined,
            iconBg: const Color(0xFFEDE9FE),
            iconColor: const Color(0xFF7C3AED),
            title: 'Microphone',
            subtitle: 'For voice and video calls',
            value: _microphoneEnabled,
            onChanged: (val) {
              setState(() => _microphoneEnabled = val);
              _saveDraft();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F2B32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF007A78),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 10: You're all set! (Summary Card)
  // ---------------------------------------------------------------------------
  Widget _buildStep10AllSet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildScreenHeader(
            title: "You're all set!",
            subtitle: "Here's a quick look at your profile.",
          ),

          // Summary Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFCEF1EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007A78).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with Edit Pencil Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFFCEF1EB),
                      foregroundImage: _selectedPhotoUrl.isNotEmpty
                          ? getAppImageProvider(_selectedPhotoUrl)
                          : null,
                      onForegroundImageError: _selectedPhotoUrl.isNotEmpty ? (exception, stackTrace) {} : null,
                      child: const Icon(Icons.person, size: 40, color: Color(0xFF007A78)),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Go back to photo step
                        setState(() => _currentStep = 4);
                        _pageController.jumpToPage(3);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A78),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Name
                Text(
                  _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Pradeep',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F2B32),
                  ),
                ),

                const SizedBox(height: 2),

                // Age
                Text(
                  '$_calculatedAge years old',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 6),

                // Location
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF007A78)),
                    const SizedBox(width: 4),
                    Text(
                      '$_selectedCity, $_selectedState',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 14),

                // Selected Interest Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    ..._selectedInterests.take(3).map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAF8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCEF1EB)),
                        ),
                        child: Text(
                          item,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF007A78),
                          ),
                        ),
                      );
                    }),
                    if (_selectedInterests.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '+${_selectedInterests.length - 3}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Bar with Continue Button
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar() {
    final isValid = _isCurrentStepValid;
    final isFinalStep = _currentStep == 10;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isValid
                ? const LinearGradient(
                    colors: [Color(0xFF007A78), Color(0xFF005F5D)],
                  )
                : null,
            color: isValid ? null : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(18),
            boxShadow: isValid
                ? [
                    BoxShadow(
                      color: const Color(0xFF007A78).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isValid && !_isSavingFinalProfile ? _goToNextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _isSavingFinalProfile
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFinalStep ? 'Continue to Home' : 'Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isValid ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isValid ? Colors.white : const Color(0xFF9CA3AF),
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
