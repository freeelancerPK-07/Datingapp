import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/services/app_state.dart';

class BecomeCreatorScreen extends StatefulWidget {
  const BecomeCreatorScreen({super.key});

  @override
  State<BecomeCreatorScreen> createState() => _BecomeCreatorScreenState();
}

class _BecomeCreatorScreenState extends State<BecomeCreatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _categories = const [
    'Dance & Choreography',
    'Fitness & Yoga',
    'Fashion & Styling',
    'Music & Vocal',
    'Astrology & Tarot',
    'Tech Mentor',
    'Model',
    'Comedy & Acting',
    'Art & Design',
    'Lifestyle Influencer',
  ];

  final _allLanguages = const [
    'English',
    'Tamil',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];

  final _availableTags = const [
    'Dance',
    'Bollywood',
    'Fitness',
    'Yoga',
    'Music',
    'Lifestyle',
    'Workout',
    'Consulting',
    'Acoustic',
  ];

  late String _selectedCategory;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _videoPriceController;
  late final TextEditingController _voicePriceController;
  late final TextEditingController _photoPriceController;
  late final TextEditingController _socialHandleController;

  final Set<String> _selectedLanguages = {'English', 'Tamil'};
  final Set<String> _selectedTags = {'Creator', 'Lifestyle'};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appState = AppState.instance;
    _selectedCategory = _categories.first;
    _headlineController = TextEditingController(text: 'Dancer & Creator');
    _bioController = TextEditingController(text: appState.userBio);
    _videoPriceController = TextEditingController(text: '500');
    _voicePriceController = TextEditingController(text: '300');
    _photoPriceController = TextEditingController(text: '200');
    _socialHandleController = TextEditingController();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    _videoPriceController.dispose();
    _voicePriceController.dispose();
    _photoPriceController.dispose();
    _socialHandleController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppState.instance;
    final headline = _headlineController.text.trim();
    final bio = _bioController.text.trim();
    final videoPrice = int.tryParse(_videoPriceController.text.trim()) ?? 500;
    final voicePrice = int.tryParse(_voicePriceController.text.trim()) ?? 300;
    final photoPrice = int.tryParse(_photoPriceController.text.trim()) ?? 200;

    setState(() => _isLoading = true);

    final success = await appState.becomeCreator(
      profession: headline.isNotEmpty ? headline : _selectedCategory,
      videoCallPrice: videoPrice,
      voiceCallPrice: voicePrice,
      photoPrice: photoPrice,
      bio: bio,
      tags: _selectedTags.toList(),
      languages: _selectedLanguages.toList(),
      tier: 'VIP',
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration successful. You are now live as a Creator.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: LinkUpTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to register. Please check your network or sign-in status.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LinkUpTheme.darkSlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Become a Creator',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinkUpTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Creator Program',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Set your rates and earn LinkUp coins on live 1-on-1 sessions.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Category
              _buildSectionTitle('Category & Niche'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                          _headlineController.text = cat;
                        });
                      }
                    },
                    selectedColor: LinkUpTheme.primaryTeal,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? Colors.white : const Color(0xFF4B5563),
                    ),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Headline Input
              _buildSectionTitle('Profile Headline'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _headlineController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(
                  hint: 'e.g. Bollywood Dancer & Fitness Coach',
                  icon: Icons.badge_outlined,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a headline' : null,
              ),

              const SizedBox(height: 22),

              // Section 2: Calling Rates
              _buildSectionTitle('Session Pricing (LinkUp Coins)'),
              const SizedBox(height: 12),

              // Video Call Rate
              _buildRateCard(
                title: 'Video Call Rate (per minute)',
                controller: _videoPriceController,
                presets: [200, 300, 500, 800, 1000],
                icon: Icons.videocam_rounded,
              ),

              const SizedBox(height: 14),

              // Voice Call Rate
              _buildRateCard(
                title: 'Voice Call Rate (per minute)',
                controller: _voicePriceController,
                presets: [150, 200, 300, 500],
                icon: Icons.call_rounded,
              ),

              const SizedBox(height: 14),

              // Private Photo Unlock Price
              _buildRateCard(
                title: 'Pay-to-Unlock Photo Price',
                controller: _photoPriceController,
                presets: [100, 200, 300, 500],
                icon: Icons.lock_open_rounded,
              ),

              const SizedBox(height: 22),

              // Section 3: Bio
              _buildSectionTitle('About You (Creator Bio)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _inputDecoration(
                  hint: 'Describe your expertise, experience, and what users can expect during a 1-on-1 session.',
                  icon: Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 22),

              // Section 4: Languages Spoken
              _buildSectionTitle('Languages Spoken'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allLanguages.map((lang) {
                  final isSel = _selectedLanguages.contains(lang);
                  return FilterChip(
                    label: Text(lang),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedLanguages.add(lang);
                        } else if (_selectedLanguages.length > 1) {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFE6F4F1),
                    checkmarkColor: LinkUpTheme.primaryTeal,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFF4B5563),
                    ),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Section 5: Speciality Tags
              _buildSectionTitle('Speciality Tags'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSel = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else if (_selectedTags.length > 1) {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: const Color(0xFFE6F4F1),
                    checkmarkColor: LinkUpTheme.primaryTeal,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFF4B5563),
                    ),
                    backgroundColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // Section 6: Social Media Verification
              _buildSectionTitle('Social Media Profile (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _socialHandleController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(
                  hint: '@your_instagram_handle',
                  icon: Icons.alternate_email_rounded,
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LinkUpTheme.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Register as Official Creator',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: LinkUpTheme.darkSlate,
      ),
    );
  }

  Widget _buildRateCard({
    required String title,
    required TextEditingController controller,
    required List<int> presets,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: LinkUpTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                height: 38,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.primaryTeal,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: LinkUpTheme.primaryTeal, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: presets.map((p) {
              final isCurrent = controller.text.trim() == p.toString();
              return GestureDetector(
                onTap: () => setState(() => controller.text = p.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCurrent ? LinkUpTheme.primaryTeal : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    '$p Coins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9CA3AF)),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LinkUpTheme.primaryTeal, width: 1.5),
      ),
    );
  }
}

