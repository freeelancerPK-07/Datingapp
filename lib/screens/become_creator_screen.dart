import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/services/api_service.dart';
import 'package:version1/services/app_state.dart';

class BecomeCreatorScreen extends StatefulWidget {
  const BecomeCreatorScreen({super.key});

  @override
  State<BecomeCreatorScreen> createState() => _BecomeCreatorScreenState();
}

class _BecomeCreatorScreenState extends State<BecomeCreatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Application Status State
  bool _isLoadingStatus = true;
  String _applicationStatus = 'NOT_APPLIED'; // NOT_APPLIED, PENDING_VERIFICATION, APPROVED, REJECTED
  Map<String, dynamic>? _applicationData;
  String? _rejectionReason;

  // Form Controllers
  late final TextEditingController _legalNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _payoutUpiController;
  late final TextEditingController _socialHandleController;
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  late final TextEditingController _videoPriceController;
  late final TextEditingController _voicePriceController;
  late final TextEditingController _photoPriceController;

  // Plan Selection
  String _selectedPlan = 'MONTHLY_299'; // MONTHLY_299 or YEARLY_2499

  // Govt ID Selection
  String _selectedGovtIdType = 'Aadhaar Card';
  final List<String> _govtIdTypes = const [
    'Aadhaar Card',
    'PAN Card',
    'Voter ID',
    'Passport',
  ];

  final List<String> _categories = const [
    'Lifestyle & Dating',
    'Dance & Choreography',
    'Fitness & Yoga',
    'Fashion & Styling',
    'Music & Vocal',
    'Astrology & Tarot',
    'Tech Mentor',
    'Model',
    'Comedy & Acting',
    'Art & Design',
  ];

  final List<String> _allLanguages = const [
    'English',
    'Tamil',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];

  final List<String> _availableTags = const [
    'Lifestyle',
    'Creator',
    'Dance',
    'Bollywood',
    'Fitness',
    'Yoga',
    'Music',
    'Workout',
    'Consulting',
    'Acoustic',
  ];

  late String _selectedCategory;
  final Set<String> _selectedLanguages = {'English', 'Tamil'};
  final Set<String> _selectedTags = {'Lifestyle', 'Creator'};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final appState = AppState.instance;

    _selectedCategory = _categories.first;
    _legalNameController = TextEditingController(text: appState.userName.isNotEmpty ? appState.userName : '');
    _ageController = TextEditingController(text: '22');
    _payoutUpiController = TextEditingController(text: '');
    _socialHandleController = TextEditingController(text: '@');
    _headlineController = TextEditingController(text: 'Lifestyle Creator');
    _bioController = TextEditingController(text: appState.userBio.isNotEmpty ? appState.userBio : 'Passionate creator ready to connect 1-on-1.');
    _videoPriceController = TextEditingController(text: '500');
    _voicePriceController = TextEditingController(text: '300');
    _photoPriceController = TextEditingController(text: '200');

    _checkApplicationStatus();
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _ageController.dispose();
    _payoutUpiController.dispose();
    _socialHandleController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _videoPriceController.dispose();
    _voicePriceController.dispose();
    _photoPriceController.dispose();
    super.dispose();
  }

  Future<String> _resolveUserId() async {
    final appState = AppState.instance;
    if (appState.backendUserId != null && appState.backendUserId!.isNotEmpty) {
      return appState.backendUserId!;
    }

    try {
      const storage = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: true));
      final storedId = await storage.read(key: 'user_id');
      if (storedId != null && storedId.isNotEmpty) {
        appState.setBackendUserId(storedId);
        return storedId;
      }
    } catch (_) {}

    // Fallback: Use or generate stable test user id
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    appState.setBackendUserId(newId);
    return newId;
  }

  Future<void> _checkApplicationStatus() async {
    setState(() => _isLoadingStatus = true);

    try {
      final userId = await _resolveUserId();
      final res = await ApiService.instance.getCreatorApplicationStatus(userId);

      if (mounted) {
        if (res['success'] == true && res['status'] != null) {
          setState(() {
            _applicationStatus = res['status'] as String;
            _applicationData = res['application'] as Map<String, dynamic>?;
            _rejectionReason = res['rejectionReason'] as String?;
            _isLoadingStatus = false;
          });
        } else {
          setState(() {
            _applicationStatus = 'NOT_APPLIED';
            _isLoadingStatus = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _applicationStatus = 'NOT_APPLIED';
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final legalName = _legalNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 21;
    final payoutUpi = _payoutUpiController.text.trim();
    final social = _socialHandleController.text.trim();
    final headline = _headlineController.text.trim();
    final bio = _bioController.text.trim();
    final videoPrice = int.tryParse(_videoPriceController.text.trim()) ?? 500;
    final voicePrice = int.tryParse(_voicePriceController.text.trim()) ?? 300;

    setState(() => _isSubmitting = true);

    final userId = await _resolveUserId();

    final res = await ApiService.instance.applyForCreator(
      userId: userId,
      legalName: legalName,
      age: age,
      profession: headline.isNotEmpty ? headline : _selectedCategory,
      videoCallPrice: videoPrice,
      voiceCallPrice: voicePrice,
      bio: bio,
      govtIdType: _selectedGovtIdType,
      socialHandle: social,
      payoutUpiId: payoutUpi,
      tags: _selectedTags.toList(),
      languages: _selectedLanguages.toList(),
      subscriptionPlan: _selectedPlan,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _applicationStatus = 'PENDING_VERIFICATION';
        _applicationData = res['application'] as Map<String, dynamic>?;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Application submitted! Sent to Admin Web Dashboard for verification.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: LinkUpTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final errorMsg = res['error'] ?? 'Unable to connect to server. Ensure backend is running.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg.toString(),
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
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
        actions: [
          if (!_isLoadingStatus && _applicationStatus != 'NOT_APPLIED')
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: LinkUpTheme.primaryTeal),
              onPressed: _checkApplicationStatus,
              tooltip: 'Check Status',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingStatus
            ? const Center(child: CircularProgressIndicator(color: LinkUpTheme.primaryTeal))
            : _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_applicationStatus == 'PENDING_VERIFICATION') {
      return _buildPendingReviewView();
    } else if (_applicationStatus == 'APPROVED') {
      return _buildApprovedView();
    } else if (_applicationStatus == 'REJECTED') {
      return _buildRejectedView();
    }

    return _buildApplicationForm();
  }

  // ---------------------------------------------------------------------------
  // View 1: Application Under Review (Real-Time Admin Queue Gate)
  // ---------------------------------------------------------------------------
  Widget _buildPendingReviewView() {
    final planName = _selectedPlan == 'MONTHLY_299' ? 'Monthly Creator Pass (₹299/mo)' : 'Annual VIP Creator (₹2,499/yr)';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Pulsing / Glowing Badge
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFFD97706),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Application Under Review',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: LinkUpTheme.darkSlate,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AWAITING ADMIN APPROVAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Informational Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submitted KYC Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
                const SizedBox(height: 14),
                _buildReviewRow('Full Legal Name', _applicationData?['legalName'] ?? _legalNameController.text),
                _buildReviewRow('Govt ID Type', _applicationData?['govtIdType'] ?? _selectedGovtIdType),
                _buildReviewRow('Payout UPI ID', _applicationData?['payoutUpiId'] ?? _payoutUpiController.text),
                _buildReviewRow('Subscription Plan', planName),
                _buildReviewRow('Calling Rates', '${_videoPriceController.text} Coins / min (Video)'),
                _buildReviewRow('Status', 'Pending Verification', isStatus: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Explanatory Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your application is waiting in the Admin Web Dashboard queue. As soon as Admin clicks "Approve & Make Live", your profile will instantly appear on the LinkUp Home Screen feed.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E40AF),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Check Status Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _checkApplicationStatus,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              label: Text(
                'Check Approval Status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Edit/Re-apply Button
          TextButton(
            onPressed: () {
              setState(() {
                _applicationStatus = 'NOT_APPLIED';
              });
            },
            child: Text(
              'Edit Submitted Information',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View 2: Creator Approved View
  // ---------------------------------------------------------------------------
  Widget _buildApprovedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 56),
            ),
            const SizedBox(height: 24),
            Text(
              'You Are an Official Creator!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: LinkUpTheme.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your profile has been verified and approved by the Administrator. You are now live on the LinkUp Home feed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  AppState.instance.syncCreatorsFromBackend();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinkUpTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Go to Home / View Live Profile',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View 3: Application Rejected View
  // ---------------------------------------------------------------------------
  Widget _buildRejectedView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Application Needs Attention',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: LinkUpTheme.darkSlate,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason from Administrator:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _rejectionReason ?? 'Government ID or account details could not be verified. Please review and re-apply.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _applicationStatus = 'NOT_APPLIED');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Re-Apply with Updated Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // View 4: Full Creator Application Form
  // ---------------------------------------------------------------------------
  Widget _buildApplicationForm() {
    return Form(
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
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator Onboarding & Verification',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Submit your KYC details for Admin verification & activate your Creator pass.',
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

          // Subscription Plan Selector
          _buildSectionTitle('Creator Subscription Plan'),
          const SizedBox(height: 10),
          _buildPlanOption(
            id: 'MONTHLY_299',
            title: 'Monthly Creator Pass',
            price: '₹299 / month',
            subtitle: 'Direct onboarding & 70% caller earnings split',
            badge: 'POPULAR',
          ),
          const SizedBox(height: 10),
          _buildPlanOption(
            id: 'YEARLY_2499',
            title: 'Annual VIP Creator',
            price: '₹2,499 / year',
            subtitle: 'Priority verification queue + VIP verified badge on feed',
            badge: 'SAVE 30%',
          ),

          const SizedBox(height: 24),

          // Section: KYC & Background Verification
          _buildSectionTitle('Background Verification (KYC)'),
          const SizedBox(height: 12),

          // Legal Name
          TextFormField(
            controller: _legalNameController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              hint: 'Full Legal Name (as per Govt ID)',
              icon: Icons.person_outline_rounded,
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Full legal name is required' : null,
          ),
          const SizedBox(height: 12),

          // Age and Govt ID Type row
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration(
                    hint: 'Age (18+)',
                    icon: Icons.cake_outlined,
                  ),
                  validator: (val) {
                    final a = int.tryParse(val ?? '');
                    if (a == null || a < 18) return 'Must be 18+';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGovtIdType,
                  items: _govtIdTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGovtIdType = val);
                  },
                  decoration: _inputDecoration(
                    hint: 'Govt ID Type',
                    icon: Icons.credit_card_rounded,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payout UPI ID
          TextFormField(
            controller: _payoutUpiController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              hint: 'Payout UPI ID (e.g. yourname@ybl)',
              icon: Icons.account_balance_wallet_outlined,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Payout UPI ID is required';
              if (!val.contains('@')) return 'Enter valid UPI ID with @';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Social Media Profile
          TextFormField(
            controller: _socialHandleController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              hint: 'Social Media Handle (e.g. @_pkhere_)',
              icon: Icons.alternate_email_rounded,
            ),
          ),

          const SizedBox(height: 24),

          // Category & Niche
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
              hint: 'e.g. Lifestyle Influencer & Content Creator',
              icon: Icons.badge_outlined,
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a headline' : null,
          ),

          const SizedBox(height: 22),

          // Session Pricing
          _buildSectionTitle('Session Pricing (LinkUp Coins)'),
          const SizedBox(height: 12),
          _buildRateCard(
            title: 'Video Call Rate (per minute)',
            controller: _videoPriceController,
            presets: [200, 300, 500, 800, 1000],
            icon: Icons.videocam_rounded,
          ),
          const SizedBox(height: 12),
          _buildRateCard(
            title: 'Voice Call Rate (per minute)',
            controller: _voicePriceController,
            presets: [150, 200, 300, 500],
            icon: Icons.call_rounded,
          ),

          const SizedBox(height: 22),

          // Bio
          _buildSectionTitle('About You (Creator Bio)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: _inputDecoration(
              hint: 'Describe your expertise, personality, and what callers can expect during 1-on-1 sessions.',
              icon: Icons.description_outlined,
            ),
          ),

          const SizedBox(height: 22),

          // Languages Spoken
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

          // Speciality Tags
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

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _selectedPlan == 'MONTHLY_299'
                          ? 'Submit for Admin Verification (₹299)'
                          : 'Submit for Admin Verification (₹2,499)',
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
    );
  }

  Widget _buildPlanOption({
    required String id,
    required String title,
    required String price,
    required String subtitle,
    required String badge,
  }) {
    final isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4F1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFF9CA3AF),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: LinkUpTheme.darkSlate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? LinkUpTheme.primaryTeal : LinkUpTheme.darkSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isStatus ? const Color(0xFFD97706) : LinkUpTheme.darkSlate,
              ),
            ),
          ),
        ],
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
