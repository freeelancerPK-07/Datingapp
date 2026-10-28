import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 6 Photos list (guaranteed 6 slots: URLs or empty strings)
  late List<String> _photos;

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _heightController;
  late TextEditingController _jobController;
  late TextEditingController _educationController;
  late TextEditingController _instagramController;

  late DateTime? _dob;
  late String _gender;
  late String _lookingFor;
  late List<String> _interests;
  late List<String> _languages;
  late List<Map<String, String>> _prompts;

  // Available Prompts list for profile picker
  static const List<String> _availablePromptQuestions = [
    'My perfect weekend is...',
    'The quickest way to my heart is...',
    'A non-negotiable for me is...',
    'Together, we could...',
    'I nerd out on...',
    'Two truths and a lie...',
    'Best travel story...',
    'My simple pleasures in life...',
    'I will never stop talking about...',
  ];

  // Available Interests chips
  static const List<String> _allAvailableInterests = [
    'Music',
    'Dance',
    'Travel',
    'Fitness',
    'Coffee',
    'Art',
    'Photography',
    'Gaming',
    'Foodie',
    'Movies',
    'Fashion',
    'Reading',
    'Design',
    'Startups',
  ];

  // Available Languages chips
  static const List<String> _allAvailableLanguages = [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];


  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.userProfile;

    // Initialize 6 slots
    _photos = List<String>.filled(6, '');
    for (int i = 0; i < 6; i++) {
      if (i < profile.galleryPhotos.length) {
        _photos[i] = profile.galleryPhotos[i];
      }
    }
    // Fallback if slot 0 is empty
    if (_photos[0].isEmpty && profile.photoUrl.isNotEmpty) {
      _photos[0] = profile.photoUrl;
    }

    _nameController = TextEditingController(text: AppState.instance.userName);
    _bioController = TextEditingController(text: AppState.instance.userBio);
    _cityController = TextEditingController(text: profile.city.isNotEmpty ? profile.city : 'Chennai');
    _heightController = TextEditingController(text: profile.height);
    _jobController = TextEditingController(text: profile.job);
    _educationController = TextEditingController(text: profile.education);
    _instagramController = TextEditingController(text: profile.instagram);

    _dob = profile.dob ?? DateTime(2002, 5, 12);
    _gender = profile.gender.isNotEmpty ? profile.gender : 'Male';
    _lookingFor = profile.lookingFor.isNotEmpty ? profile.lookingFor : 'Dating & Chat';
    _interests = List<String>.from(profile.interests.isNotEmpty ? profile.interests : ['Music', 'Travel', 'Fitness']);
    _languages = List<String>.from(profile.languages.isNotEmpty ? profile.languages : ['Tamil', 'English', 'Hindi']);

    _prompts = profile.prompts.isNotEmpty
        ? profile.prompts.map((p) => Map<String, String>.from(p)).toList()
        : [
            {
              'question': 'My perfect weekend is...',
              'answer': 'Rooftop cafe hopping, sketching minimalist UI screens, and acoustic live music gigs.',
            },
            {
              'question': 'The quickest way to my heart is...',
              'answer': 'Deep late-night conversations, good filter coffee, and spontaneous city drives.',
            },
            {
              'question': 'A non-negotiable for me is...',
              'answer': 'Honesty, emotional maturity, kindness, and being passionate about whatever you do.',
            },
          ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _heightController.dispose();
    _jobController.dispose();
    _educationController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    if (_dob == null) return 24;
    final now = DateTime.now();
    int age = now.year - _dob!.year;
    if (now.month < _dob!.month || (now.month == _dob!.month && now.day < _dob!.day)) {
      age--;
    }
    return age;
  }

  // -------------------------------------------------------------
  // Photo Slot Upload Bottom Sheet (Real Camera / Real Gallery)
  // -------------------------------------------------------------
  void _openPhotoUploadSheet(int slotIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final hasPhoto = _photos[slotIndex].isNotEmpty;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Photo #${slotIndex + 1}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Slot 1 is your main photo shown to all creators.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),

              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF007A78)),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Live selfie or portrait with device camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedPath = await AppImagePickerService.pickFromCamera();
                  if (pickedPath != null && mounted) {
                    setState(() {
                      _photos[slotIndex] = pickedPath;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo #${slotIndex + 1} captured with Camera successfully! 📸',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF007A78),
                      ),
                    );
                  }
                },
              ),

              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF007A78)),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Select from phone library or camera roll'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedPath = await AppImagePickerService.pickFromGallery();
                  if (pickedPath != null && mounted) {
                    setState(() {
                      _photos[slotIndex] = pickedPath;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo #${slotIndex + 1} chosen from Gallery successfully! 🖼️',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF007A78),
                      ),
                    );
                  }
                },
              ),

              if (hasPhoto) ...[
                const Divider(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                  ),
                  title: Text(
                    'Remove Photo #${slotIndex + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _photos[slotIndex] = '';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo #${slotIndex + 1} removed.',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }


  // -------------------------------------------------------------
  // Prompt Question Picker Dialog
  // -------------------------------------------------------------
  void _openPromptQuestionPicker(int promptIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Prompt Question',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2B32),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _availablePromptQuestions.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFE5E7EB)),
                itemBuilder: (context, i) {
                  final q = _availablePromptQuestions[i];
                  final isSelected = _prompts.length > promptIndex && _prompts[promptIndex]['question'] == q;
                  return ListTile(
                    title: Text(
                      q,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF007A78) : const Color(0xFF111111),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF007A78))
                        : null,
                    onTap: () {
                      setState(() {
                        if (promptIndex < _prompts.length) {
                          _prompts[promptIndex]['question'] = q;
                        } else {
                          _prompts.add({'question': q, 'answer': ''});
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Birthday Picker
  // -------------------------------------------------------------
  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2002, 5, 12),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18+ enforcement
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  // -------------------------------------------------------------
  // Save All Changes
  // -------------------------------------------------------------
  void _saveProfile() {
    // Collect non-empty photos
    final validPhotos = _photos.where((p) => p.isNotEmpty).toList();
    if (validPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least 1 profile photo.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Save to AppState
    AppState.instance.updateFullProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      city: _cityController.text.trim(),
      dob: _dob,
      gender: _gender,
      height: _heightController.text.trim(),
      job: _jobController.text.trim(),
      education: _educationController.text.trim(),
      instagram: _instagramController.text.trim().replaceAll('@', ''),
      lookingFor: _lookingFor,
      galleryPhotos: validPhotos,
      interests: _interests,
      languages: _languages,
      prompts: _prompts,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully! ✨',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF007A78),
      ),
    );

    Navigator.pop(context);
  }

  // -------------------------------------------------------------
  // Main UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F2B32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F2B32),
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF007A78),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // ==========================================
                  // 1. 6 PHOTOS GRID (MANDATORY 6 SLOTS)
                  // ==========================================
                  _buildSectionHeader(
                    title: 'My Photos (6 Slots)',
                    subtitle: 'Add 6 photos to complete your profile. First slot is your Main photo.',
                  ),
                  const SizedBox(height: 12),

                  // 3 columns x 2 rows
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, i) {
                      final photoUrl = _photos[i];
                      final isMain = i == 0;
                      final hasPhoto = photoUrl.isNotEmpty;

                      return GestureDetector(
                        onTap: () => _openPhotoUploadSheet(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasPhoto ? Colors.black : const Color(0xFFF0FAF8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isMain
                                  ? const Color(0xFF007A78)
                                  : (hasPhoto ? const Color(0xFFE5E7EB) : const Color(0xFFCEF1EB)),
                              width: isMain ? 2.2 : 1.2,
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (hasPhoto)
                                AppImage(
                                  path: photoUrl,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(14),
                                )
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFCEF1EB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 18,
                                        color: Color(0xFF007A78),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Slot #${i + 1}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF007A78),
                                      ),
                                    ),
                                  ],
                                ),

                              // MAIN Photo Badge
                              if (isMain)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007A78),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '★ MAIN',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              // Delete (X) or Camera Icon
                              if (hasPhoto)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _photos[i] = '';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xCC000000),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 2. ABOUT ME (BIO)
                  // ==========================================
                  _buildSectionHeader(
                    title: 'About Me',
                    subtitle: 'Write a catchy bio for your profile (up to 150 characters).',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _bioController,
                          maxLength: 150,
                          maxLines: 3,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Share what you enjoy doing, what you look for, or an interesting fact...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF9CA3AF),
                            ),
                            counterText: '',
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF111111),
                            height: 1.4,
                          ),
                        ),
                        Text(
                          '${_bioController.text.length} / 150',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 3. LOOKING FOR (INTENT)
                  // ==========================================
                  _buildSectionHeader(
                    title: 'Looking For (Intent)',
                    subtitle: 'Be transparent about what you are seeking on LinkUp.',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Dating & Chat',
                      'Friendship',
                      'Serious Relationship',
                      'Casual & Fun',
                    ].map((intent) {
                      final isSelected = _lookingFor == intent;
                      return ChoiceChip(
                        label: Text(intent),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _lookingFor = intent);
                        },
                        selectedColor: const Color(0xFFF0FAF8),
                        backgroundColor: const Color(0xFFF9FAFB),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFF4B5563),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 4. THE BASICS (PERSONAL OVERVIEW)
                  // ==========================================
                  _buildSectionHeader(
                    title: 'The Basics',
                    subtitle: 'Your personal details to stand out on LinkUp.',
                  ),
                  const SizedBox(height: 12),

                  _buildInputCard(
                    icon: Icons.person_outline_rounded,
                    label: 'First Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 10),

                  // Birthday & Age
                  InkWell(
                    onTap: _pickBirthday,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined, color: Color(0xFF007A78), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Birthday & Age',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _dob != null
                                      ? '${_dob!.day}/${_dob!.month}/${_dob!.year} ($_calculatedAge years old)'
                                      : 'Tap to select birthday',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gender Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.transgender_rounded, color: Color(0xFF007A78), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Gender',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: ['Male', 'Female', 'Other'].map((g) {
                            final isSelected = _gender == g;
                            return ChoiceChip(
                              label: Text(g),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) setState(() => _gender = g);
                              },
                              selectedColor: const Color(0xFF007A78),
                              backgroundColor: Colors.white,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildInputCard(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    hintText: 'e.g. 5\' 10" (178 cm)',
                    controller: _heightController,
                  ),
                  const SizedBox(height: 10),

                  _buildInputCard(
                    icon: Icons.work_outline_rounded,
                    label: 'Job / Profession',
                    hintText: 'e.g. UI/UX Designer, Architect',
                    controller: _jobController,
                  ),
                  const SizedBox(height: 10),

                  _buildInputCard(
                    icon: Icons.school_outlined,
                    label: 'Education / College',
                    hintText: 'e.g. B.Tech Anna University',
                    controller: _educationController,
                  ),
                  const SizedBox(height: 10),

                  _buildInputCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location / City',
                    hintText: 'e.g. Chennai, Tamil Nadu',
                    controller: _cityController,
                  ),
                  const SizedBox(height: 10),

                  _buildInputCard(
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram Username',
                    hintText: 'e.g. pradeep.design',
                    prefixText: '@ ',
                    controller: _instagramController,
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 5. PROFILE PROMPTS (QUESTION + ANSWER)
                  // ==========================================
                  _buildSectionHeader(
                    title: 'Profile Prompts (Q & A)',
                    subtitle: 'Answer 3 prompts to show your personality and humor.',
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(_prompts.length, (i) {
                    final item = _prompts[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCEF1EB), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FAF8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PROMPT #${i + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF007A78),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openPromptQuestionPicker(i),
                                icon: const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF007A78)),
                                label: Text(
                                  'Change Prompt',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF007A78),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['question'] ?? 'Select a question...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F2B32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: item['answer'],
                            maxLines: 2,
                            onChanged: (val) => item['answer'] = val,
                            decoration: InputDecoration(
                              hintText: 'Type your answer here...',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9CA3AF)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF007A78)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF111111)),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ==========================================
                  // 6. INTERESTS & PASSIONS
                  // ==========================================
                  _buildSectionHeader(
                    title: 'Interests & Passions',
                    subtitle: 'Pick what you love (min 3, max 8).',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allAvailableInterests.map((interest) {
                      final isSelected = _interests.contains(interest);
                      return FilterChip(
                        label: Text('#$interest'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              if (_interests.length < 8) _interests.add(interest);
                            } else {
                              if (_interests.length > 3) _interests.remove(interest);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFF0FAF8),
                        backgroundColor: const Color(0xFFF9FAFB),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFF4B5563),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 7. SPOKEN LANGUAGES
                  // ==========================================
                  _buildSectionHeader(
                    title: 'Spoken Languages',
                    subtitle: 'Select the languages you speak comfortably.',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allAvailableLanguages.map((lang) {
                      final isSelected = _languages.contains(lang);
                      return FilterChip(
                        label: Text(lang),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _languages.add(lang);
                            } else {
                              if (_languages.length > 1) _languages.remove(lang);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFF0FAF8),
                        backgroundColor: const Color(0xFFF9FAFB),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? const Color(0xFF007A78) : const Color(0xFF4B5563),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ==========================================
            // BOTTOM STICKY SAVE BUTTON
            // ==========================================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinkUpTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007A78).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Save Profile Changes',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F2B32),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? prefixText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF007A78), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    hintText: hintText,
                    prefixText: prefixText,
                    prefixStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF007A78),
                    ),
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
