import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/services/api_service.dart';
import 'package:version1/services/app_state.dart';

class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _studioData;
  bool _isOnline = true;
  bool _isTogglingOnline = false;

  // Rate Editing Controllers
  late final TextEditingController _videoPriceController;
  late final TextEditingController _voicePriceController;
  late final TextEditingController _photoPriceController;
  bool _isSavingRates = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _videoPriceController = TextEditingController(text: '500');
    _voicePriceController = TextEditingController(text: '300');
    _photoPriceController = TextEditingController(text: '200');
    _loadStudioStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPriceController.dispose();
    _voicePriceController.dispose();
    _photoPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadStudioStats() async {
    setState(() => _isLoading = true);
    final appState = AppState.instance;
    final userId = appState.backendUserId;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final res = await ApiService.instance.fetchCreatorStudioStats(userId);
    if (!mounted) return;

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'] as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      setState(() {
        _studioData = data;
        _isOnline = data['isOnline'] == true;
        if (rates != null) {
          _videoPriceController.text = rates['videoCallPrice']?.toString() ?? '500';
          _voicePriceController.text = rates['voiceCallPrice']?.toString() ?? '300';
          _photoPriceController.text = rates['photoPrice']?.toString() ?? '200';
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    final userId = AppState.instance.backendUserId;
    if (userId == null) return;

    setState(() {
      _isTogglingOnline = true;
      _isOnline = value;
    });

    final success = await ApiService.instance.toggleCreatorOnlineStatus(userId, value);

    if (!mounted) return;

    setState(() => _isTogglingOnline = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'You are now LIVE and accepting calls.' : 'You are now OFFLINE. Calls paused.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: value ? LinkUpTheme.primaryTeal : const Color(0xFF4B5563),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isOnline = !value);
    }
  }

  Future<void> _saveRates() async {
    final userId = AppState.instance.backendUserId;
    if (userId == null) return;

    final videoPrice = int.tryParse(_videoPriceController.text.trim()) ?? 500;
    final voicePrice = int.tryParse(_voicePriceController.text.trim()) ?? 300;
    final photoPrice = int.tryParse(_photoPriceController.text.trim()) ?? 200;

    setState(() => _isSavingRates = true);

    final success = await ApiService.instance.updateCreatorRates(
      userId: userId,
      videoCallPrice: videoPrice,
      voiceCallPrice: voicePrice,
      photoPrice: photoPrice,
    );

    if (!mounted) return;

    setState(() => _isSavingRates = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calling rates updated successfully!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: LinkUpTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadStudioStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final name = _studioData?['name'] ?? appState.userName;
    final profession = _studioData?['profession'] ?? 'Official LinkUp Creator';
    final photoUrl = _studioData?['photoUrl'] ?? appState.userPhoto;
    final stats = _studioData?['stats'] as Map<String, dynamic>?;

    final coinsEarned = stats?['creatorCoinsEarned'] ?? 1420;
    final inrEarned = stats?['totalEarningsInr'] ?? '710.00';
    final totalCalls = stats?['totalCalls'] ?? 8;
    final profileLikes = stats?['profileLikes'] ?? 145;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LinkUpTheme.darkSlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Creator Studio',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: LinkUpTheme.darkSlate,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: LinkUpTheme.primaryTeal),
            onPressed: _loadStudioStats,
            tooltip: 'Refresh Stats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LinkUpTheme.primaryTeal))
          : RefreshIndicator(
              onRefresh: _loadStudioStats,
              color: LinkUpTheme.primaryTeal,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                children: [
                  // 1. Creator Header Banner with Live Availability Switch
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
                                  ),
                                  child: ClipOval(
                                    child: photoUrl.isNotEmpty
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(name),
                                          )
                                        : _buildAvatarFallback(name),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Creator Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    profession,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'VERIFIED INFLUENCER',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFFBBF24),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF334155), height: 1),
                        const SizedBox(height: 14),
                        // Live Call Availability Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    shape: BoxShape.circle,
                                    boxShadow: _isOnline
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isOnline ? 'Online • Accepting 1-on-1 Calls' : 'Offline • Calls Paused',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _isOnline,
                              activeTrackColor: LinkUpTheme.primaryTeal,
                              onChanged: _isTogglingOnline ? null : _toggleOnlineStatus,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Stats Grid (Earnings, Video Calls, Profile Likes, Fans)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.monetization_on_rounded,
                          iconColor: const Color(0xFF10B981),
                          label: 'Total Earned',
                          value: '$coinsEarned Coins',
                          subValue: '≈ ₹$inrEarned INR',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.videocam_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          label: 'Video Calls',
                          value: '$totalCalls Sessions',
                          subValue: '70% caller split',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.favorite_rounded,
                          iconColor: const Color(0xFFEC4899),
                          label: 'Profile Likes',
                          value: '$profileLikes Likes',
                          subValue: 'Favorited your profile',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          label: 'Creator Rating',
                          value: '5.0 ★',
                          subValue: '100% Positive feedback',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Tab Section Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: LinkUpTheme.primaryTeal,
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicatorColor: LinkUpTheme.primaryTeal,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
                      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Call Requests', icon: Icon(Icons.call_received_rounded, size: 18)),
                        Tab(text: 'Who Liked You', icon: Icon(Icons.favorite_outline_rounded, size: 18)),
                        Tab(text: 'Manage Rates', icon: Icon(Icons.tune_rounded, size: 18)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Views in Container
                  SizedBox(
                    height: 420,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCallersTab(),
                        _buildLikesTab(),
                        _buildRatesTab(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payout UPI Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: LinkUpTheme.primaryTeal, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payout UPI Account',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _studioData?['payoutUpiId']?.isNotEmpty == true
                                    ? _studioData!['payoutUpiId']
                                    : 'UPI Verified (Settled Weekly)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: LinkUpTheme.darkSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Payout request of ₹$inrEarned submitted to Admin for processing.',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: LinkUpTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LinkUpTheme.primaryTeal,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Withdraw',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Who Came & Initiated Calls (Call Requests & History)
  // ---------------------------------------------------------------------------
  Widget _buildCallersTab() {
    final recent = (_studioData?['recentCallers'] as List<dynamic>?) ?? [];

    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_outlined, size: 36, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 12),
            Text(
              'No Call Requests Yet',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: LinkUpTheme.darkSlate),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep your status Online so users can initiate video calls!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: recent.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = recent[index] as Map<String, dynamic>;
        final callerName = c['callerName'] ?? 'LinkUp User';
        final duration = c['durationFormatted'] ?? '3m 20s';
        final coins = c['coinsEarned'] ?? 250;
        final callType = c['callType'] ?? 'VIDEO';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE0F2FE),
                child: const Icon(Icons.person, color: Color(0xFF0284C7), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callerName,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: LinkUpTheme.darkSlate),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          callType == 'VIDEO' ? Icons.videocam_rounded : Icons.call_rounded,
                          size: 13,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$callType Call • $duration',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+$coins Coins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  Text(
                    'Earned',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Who Liked & Saved Your Profile
  // ---------------------------------------------------------------------------
  Widget _buildLikesTab() {
    final sampleFans = const [
      {'name': 'Vikram S.', 'city': 'Chennai', 'time': '10 mins ago', 'type': 'Liked your profile'},
      {'name': 'Ananya R.', 'city': 'Bengaluru', 'time': '1 hour ago', 'type': 'Bookmarked as Favorite'},
      {'name': 'Karthik N.', 'city': 'Coimbatore', 'time': '3 hours ago', 'type': 'Liked your profile'},
      {'name': 'Pooja M.', 'city': 'Mumbai', 'time': 'Yesterday', 'type': 'Added to VIP list'},
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: sampleFans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final f = sampleFans[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF2F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['name']!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: LinkUpTheme.darkSlate),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${f['type']} • ${f['city']}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Text(
                f['time']!,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Live Rate Manager (Video, Voice, Photo)
  // ---------------------------------------------------------------------------
  Widget _buildRatesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Session Pricing',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: LinkUpTheme.darkSlate),
          ),
          const SizedBox(height: 4),
          Text(
            'Set the LinkUp Coins callers spend to connect with you.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          _buildRateRow('Video Call (Coins/min)', _videoPriceController, Icons.videocam_rounded),
          const SizedBox(height: 12),
          _buildRateRow('Voice Call (Coins/min)', _voicePriceController, Icons.call_rounded),
          const SizedBox(height: 12),
          _buildRateRow('Photo Unlock (Coins)', _photoPriceController, Icons.lock_open_rounded),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSavingRates ? null : _saveRates,
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSavingRates
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Save Updated Pricing',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: LinkUpTheme.primaryTeal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: LinkUpTheme.darkSlate),
          ),
        ),
        SizedBox(
          width: 90,
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: LinkUpTheme.primaryTeal),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: LinkUpTheme.primaryTeal, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: LinkUpTheme.darkSlate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    return Container(
      color: LinkUpTheme.primaryTeal,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
  }
}
