import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

// =============================================================================
// User Settings & Security Center
// Includes:
// 1. Privacy & Safety (Online status, Blocked accounts, Dispute reporting)
// 2. Notification Preferences (Session alerts, Creator online alerts, Wallet deposits)
// 3. KYC & Limits Center (₹10,000 limit info, Aadhaar/PAN submission, Full KYC)
// 4. Support & Dispute Center (Contact support ticket raising, active tickets)
// =============================================================================

class UserSettingsScreen extends StatefulWidget {
  final int initialIndex;

  const UserSettingsScreen({super.key, this.initialIndex = 0});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Privacy & Safety',
      'icon': Icons.shield_rounded,
      'gradient': AppColors.gradientCyberCyan,
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_active_rounded,
      'gradient': AppColors.gradientVioletIndigo,
    },
    {
      'title': 'KYC & Limits',
      'icon': Icons.account_balance_rounded,
      'gradient': AppColors.gradientSunsetAmber,
    },
    {
      'title': 'Dispute & Support',
      'icon': Icons.headset_mic_rounded,
      'gradient': AppColors.gradientEmeraldTeal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, _tabs.length - 1),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = _tabs[_tabController.index];
    final activeGradient = activeTab['gradient'] as LinearGradient;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Glowing Gradient Top Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F7F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 17,
                            color: AppColors.pineDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings & Security',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pineDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Account safety, limits & customer care',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Active Tab Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: activeGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: activeGradient.colors.first
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(activeTab['icon'] as IconData,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Active',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Horizontal Gradient Tab Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        final isSelected = _tabController.index == index;
                        final grad = tab['gradient'] as LinearGradient;

                        return GestureDetector(
                          onTap: () => _switchTab(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8.5),
                            decoration: BoxDecoration(
                              gradient: isSelected ? grad : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.borderLight,
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: grad.colors.first
                                            .withValues(alpha: 0.28),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tab['icon'] as IconData,
                                  size: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tab['title'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.pineDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  PrivacySafetySection(
                    onNavigateToDispute: () => _switchTab(3),
                  ),
                  const NotificationPreferencesSection(),
                  const KycLimitsSection(),
                  const SupportDisputeSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 1. PRIVACY & SAFETY SECTION (PDF Page 12)
// Features:
// - Hide online status switch (Stealth mode)
// - Read receipts & profile visibility
// - Blocked accounts list with interactive unblock
// - Report a dispute quick action
// - 256-Bit SSL safety guarantee
// =============================================================================

class PrivacySafetySection extends StatefulWidget {
  final VoidCallback? onNavigateToDispute;

  const PrivacySafetySection({super.key, this.onNavigateToDispute});

  @override
  State<PrivacySafetySection> createState() => _PrivacySafetySectionState();
}

class _PrivacySafetySectionState extends State<PrivacySafetySection> {
  bool _hideOnlineStatus = false;
  bool _readReceipts = true;
  bool _stealthStoryView = false;
  String _blockedSearch = '';

  final List<Map<String, String>> _blockedAccounts = [
    {
      'id': 'b1',
      'name': 'Rahul Verma',
      'handle': '@rahul_v92',
      'date': 'Blocked on Aug 14, 2026',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    },
    {
      'id': 'b2',
      'name': 'Sneha Kapoor',
      'handle': '@sneha_k',
      'date': 'Blocked on Jul 29, 2026',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    },
    {
      'id': 'b3',
      'name': 'Arjun Dev',
      'handle': '@arjun_d',
      'date': 'Blocked on Jun 10, 2026',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    },
  ];

  void _unblockAccount(Map<String, String> account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Unblock ${account['name']}?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.pineDark,
          ),
        ),
        content: Text(
          'They will be able to see your profile, view stories, and initiate booking requests again.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientCyberCyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _blockedAccounts.removeWhere((a) => a['id'] == account['id']);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${account['name']} has been unblocked.'),
                    backgroundColor: AppColors.pineDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBlocked = _blockedAccounts.where((a) {
      if (_blockedSearch.isEmpty) return true;
      final query = _blockedSearch.toLowerCase();
      return a['name']!.toLowerCase().contains(query) ||
          a['handle']!.toLowerCase().contains(query);
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Radiant Hero Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientCyberCyan,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x280284C7),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: Color(0xFF0284C7),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy & Safety Shield',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manage your active presence, blocklist, and report suspicious activities.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section: Activity & Visibility
        Text(
          'Visibility & Presence',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.pineDark,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Hide Online Status
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  value: _hideOnlineStatus,
                  onChanged: (val) {
                    setState(() => _hideOnlineStatus = val);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Stealth Mode ON: Your online status is now hidden from everyone.'
                              : 'Online status is visible to active matches and creators.',
                        ),
                        backgroundColor: AppColors.pineDark,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeTrackColor: const Color(0xFF0284C7),
                  title: Text(
                    'Hide Online Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  subtitle: Text(
                    'When enabled, creators cannot see when you are active on Trylo.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _hideOnlineStatus
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFF1F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _hideOnlineStatus
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _hideOnlineStatus
                          ? const Color(0xFF0284C7)
                          : AppColors.pineDark,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: AppColors.borderLight),

              // Read Receipts
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  value: _readReceipts,
                  onChanged: (val) => setState(() => _readReceipts = val),
                  activeTrackColor: const Color(0xFF0284C7),
                  title: Text(
                    'Message Read Receipts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  subtitle: Text(
                    'Shows double blue checkmarks when you have read direct chat messages.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.done_all_rounded,
                      color: AppColors.pineDark,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: AppColors.borderLight),

              // Incognito Story Browsing
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  value: _stealthStoryView,
                  onChanged: (val) => setState(() => _stealthStoryView = val),
                  activeTrackColor: const Color(0xFF0284C7),
                  title: Text(
                    'Incognito Story Browsing',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  subtitle: Text(
                    'View creator stories without your name appearing in viewer list.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.pineDark,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section: Blocked Accounts List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Blocked Accounts (${_blockedAccounts.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            if (_blockedAccounts.isNotEmpty)
              Text(
                'Tap to unblock',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (_blockedAccounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF10B981), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'No Blocked Accounts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  Text(
                    'Your blocklist is clean. You have zero restricted users.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                // Quick Search Bar for Blocked Users
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _blockedSearch = v),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pineDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Filter blocked users...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_blockedSearch.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _blockedSearch = ''),
                            child: const Icon(Icons.clear_rounded,
                                size: 16, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderLight),

                // Blocked Users List
                ...filteredBlocked.map((acc) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(acc['avatar']!),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc['name']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.pineDark,
                                    ),
                                  ),
                                  Text(
                                    '${acc['handle']} • ${acc['date']}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Unblock Action Button
                            GestureDetector(
                              onTap: () => _unblockAccount(acc),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  'Unblock',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (acc != filteredBlocked.last)
                        const Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 14,
                            color: AppColors.borderLight),
                    ],
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Section: Report a Dispute Shortcut Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Report a Dispute or Misconduct',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF881337),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Experience harassment, unauthorized recording, or creator no-show? Raise an official dispute with our 24/7 trust committee.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9F1239),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.onNavigateToDispute,
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientRosePink,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33F43F5E),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flag_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Raise Safety Dispute Ticket',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. NOTIFICATION PREFERENCES SECTION (PDF Page 12)
// Features:
// - Push notification toggles for Session alerts
// - Creator online alerts
// - Wallet deposit success & refunds
// - Sound & In-app chimes
// - Save preferences confirmation
// =============================================================================

class NotificationPreferencesSection extends StatefulWidget {
  const NotificationPreferencesSection({super.key});

  @override
  State<NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<NotificationPreferencesSection> {
  // Notification States
  bool _sessionAlerts = true;
  bool _sessionCountdown5Min = true;
  bool _creatorOnlineAlerts = true;
  bool _creatorMediaDrops = false;
  bool _walletDepositSuccess = true;
  bool _walletRefundAlerts = true;
  bool _inAppSounds = true;
  bool _hapticFeedback = true;
  bool _promoCashbacks = false;

  void _savePreferences() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Notification preferences updated successfully.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pineDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Hero Gradient Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientVioletIndigo,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x284338CA),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF4338CA),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Hub',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Customize alert push notifications for sessions, creator status, and wallet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 1. Session Alerts Group
        _buildGroupTitle('Session Alerts (PDF Requirement)'),
        const SizedBox(height: 8),
        _buildGroupCard([
          SwitchListTile.adaptive(
            value: _sessionAlerts,
            onChanged: (val) => setState(() => _sessionAlerts = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Session Booking & Acceptance',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Alerts when a creator accepts, reschedules, or joins your booked call.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.phone_in_talk_rounded,
                color: AppColors.pineDark, size: 20),
          ),
          const Divider(
              height: 1, indent: 64, endIndent: 16, color: AppColors.borderLight),
          SwitchListTile.adaptive(
            value: _sessionCountdown5Min,
            onChanged: (val) => setState(() => _sessionCountdown5Min = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              '5-Minute Pre-Call Reminder',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Receive a heads-up push alert 5 minutes before scheduled voice/video dates.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.timer_outlined,
                color: AppColors.pineDark, size: 20),
          ),
        ]),
        const SizedBox(height: 20),

        // 2. Creator Online Alerts Group
        _buildGroupTitle('Creator Activity Alerts (PDF Requirement)'),
        const SizedBox(height: 8),
        _buildGroupCard([
          SwitchListTile.adaptive(
            value: _creatorOnlineAlerts,
            onChanged: (val) => setState(() => _creatorOnlineAlerts = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Creator Online Alerts',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Instant alert when creators you bookmark or frequent go live for calls.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.sensors_rounded,
                color: Color(0xFF10B981), size: 20),
          ),
          const Divider(
              height: 1, indent: 64, endIndent: 16, color: AppColors.borderLight),
          SwitchListTile.adaptive(
            value: _creatorMediaDrops,
            onChanged: (val) => setState(() => _creatorMediaDrops = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Exclusive Private Media Drops',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Notifies when subscribed hosts drop new paid photos or private voice notes.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.photo_library_outlined,
                color: AppColors.pineDark, size: 20),
          ),
        ]),
        const SizedBox(height: 20),

        // 3. Wallet Deposit & Transactions Group
        _buildGroupTitle('Wallet & Financial Alerts (PDF Requirement)'),
        const SizedBox(height: 8),
        _buildGroupCard([
          SwitchListTile.adaptive(
            value: _walletDepositSuccess,
            onChanged: (val) => setState(() => _walletDepositSuccess = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Wallet Deposit Success',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Instant notification on successful Razorpay UPI / Card top-ups.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF0D9488), size: 20),
          ),
          const Divider(
              height: 1, indent: 64, endIndent: 16, color: AppColors.borderLight),
          SwitchListTile.adaptive(
            value: _walletRefundAlerts,
            onChanged: (val) => setState(() => _walletRefundAlerts = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Session Refunds & Releases',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Notification when a creator rejects or misses a call and funds are unlocked.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.currency_rupee_rounded,
                color: AppColors.pineDark, size: 20),
          ),
        ]),
        const SizedBox(height: 20),

        // 4. Sounds & Haptics Group
        _buildGroupTitle('Audio & Vibration'),
        const SizedBox(height: 8),
        _buildGroupCard([
          SwitchListTile.adaptive(
            value: _inAppSounds,
            onChanged: (val) => setState(() => _inAppSounds = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'In-App Sound Effects',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Play audio chimes during call connection and balance updates.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.volume_up_outlined,
                color: AppColors.pineDark, size: 20),
          ),
          const Divider(
              height: 1, indent: 64, endIndent: 16, color: AppColors.borderLight),
          SwitchListTile.adaptive(
            value: _hapticFeedback,
            onChanged: (val) => setState(() => _hapticFeedback = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Haptic Vibration Feedback',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Subtle tactile tap response for buttons and booking actions.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.vibration_rounded,
                color: AppColors.pineDark, size: 20),
          ),
        ]),
        const SizedBox(height: 20),

        // 5. Special Offers & Cashbacks Group
        _buildGroupTitle('Offers & Rewards'),
        const SizedBox(height: 8),
        _buildGroupCard([
          SwitchListTile.adaptive(
            value: _promoCashbacks,
            onChanged: (val) => setState(() => _promoCashbacks = val),
            activeTrackColor: const Color(0xFF6366F1),
            title: Text(
              'Cashback & Festival Offers',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.pineDark,
              ),
            ),
            subtitle: Text(
              'Get notified about weekend cashback deals and discount coupons.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: const Icon(Icons.local_offer_outlined,
                color: AppColors.pineDark, size: 20),
          ),
        ]),
        const SizedBox(height: 24),

        // Save Preferences Gradient CTA
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.gradientVioletIndigo,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x336366F1),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_rounded, size: 19, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Save Notification Preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.pineDark,
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.map((child) => Material(color: Colors.transparent, child: child)).toList(),
      ),
    );
  }
}

// =============================================================================
// 3. KYC & LIMITS CENTER SECTION (PDF Page 12)
// Features:
// - Explanation of current ₹10,000 monthly limit (RBI PPI regulation)
// - Aadhaar & PAN details input form with validation
// - Full KYC upgrade simulation to ₹1,00,000 limit
// - DigiLocker one-tap e-KYC integration
// =============================================================================

class KycLimitsSection extends StatefulWidget {
  const KycLimitsSection({super.key});

  @override
  State<KycLimitsSection> createState() => _KycLimitsSectionState();
}

class _KycLimitsSectionState extends State<KycLimitsSection> {
  bool _isFullKycVerified = false;
  bool _isSubmittingKyc = false;

  final TextEditingController _fullNameController =
      TextEditingController(text: 'Alex Morgan');
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _handleKycSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmittingKyc = true);

    // Simulate verification delay with UIDAI / NSDL DigiLocker
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    setState(() {
      _isSubmittingKyc = false;
      _isFullKycVerified = true;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientEmeraldTeal,
              ),
              child: const Icon(Icons.verified_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Full KYC Approved! 🎉',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.pineDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Your Aadhaar and PAN have been verified via DigiLocker. Your Trylo Wallet limit is upgraded from ₹10,000 to ₹1,00,000 (1 Lakh). Bank withdrawals are now unlocked!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientEmeraldTeal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Awesome!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Hero Gradient Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _isFullKycVerified
                ? AppColors.gradientEmeraldTeal
                : AppColors.gradientSunsetAmber,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isFullKycVerified
                    ? const Color(0x3310B981)
                    : const Color(0x33F59E0B),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFullKycVerified
                      ? Icons.verified_user_rounded
                      : Icons.account_balance_rounded,
                  color: _isFullKycVerified
                      ? const Color(0xFF0D9488)
                      : const Color(0xFFEA580C),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFullKycVerified
                          ? 'Full KYC Verified Tier 2'
                          : 'KYC & Limits Center',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isFullKycVerified
                          ? 'Limit upgraded to ₹1,00,000 with instant bank settlement.'
                          : 'Compliant with Reserve Bank of India (RBI) PPI Master Directions.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 1. Current Limit Status & Regulatory Explanation
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Wallet Tier',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: _isFullKycVerified
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isFullKycVerified
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Text(
                      _isFullKycVerified
                          ? '₹1,00,000 Limit (Full KYC)'
                          : '₹10,000 Limit (Minimum KYC)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _isFullKycVerified
                            ? const Color(0xFF047857)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _isFullKycVerified ? 0.12 : 0.45,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isFullKycVerified
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Utilized: ₹3,450',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pineDark,
                    ),
                  ),
                  Text(
                    _isFullKycVerified
                        ? 'Remaining: ₹96,550'
                        : 'Remaining: ₹6,550',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Detailed RBI PPI Clause Explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RBI Master Direction on PPIs: Small minimum-detail wallets can hold and transact up to ₹10,000 per month. To unlock high-value sessions and direct bank refunds, complete your Aadhaar/PAN verification.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Full KYC Benefits Comparison Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      color: Color(0xFF059669), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Full KYC Unlocks:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBenefitRow(
                  '₹1,00,000 monthly wallet balance & reload ceiling'),
              _buildBenefitRow(
                  'Instant UPI withdrawal back to your personal bank account'),
              _buildBenefitRow(
                  'Verified Gold User badge visible across creator profiles'),
              _buildBenefitRow(
                  'Priority booking routing during high-demand creator slots'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Aadhaar / PAN Verification Form
        if (!_isFullKycVerified) ...[
          Text(
            'Submit Government ID Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.pineDark,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  Text(
                    'Full Name (as per PAN Card)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pineDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _fullNameController,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pineDark,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          size: 18, color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF8FCFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 12-Digit Aadhaar Number
                  Text(
                    '12-Digit Aadhaar Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pineDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().length != 12) {
                        return 'Enter a valid 12-digit Aadhaar number';
                      }
                      return null;
                    },
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.pineDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '5421 8934 1029',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                      prefixIcon: const Icon(Icons.credit_card_rounded,
                          size: 18, color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF8FCFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 10-Character PAN Card Number
                  Text(
                    '10-Character PAN Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pineDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _panController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().length != 10) {
                        return 'Enter a valid 10-character PAN number (e.g. ABCDE1234F)';
                      }
                      return null;
                    },
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.pineDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ABCDE1234F',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                      prefixIcon: const Icon(Icons.badge_outlined,
                          size: 18, color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF8FCFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Verification Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientSunsetAmber,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33F59E0B),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSubmittingKyc ? null : _handleKycSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmittingKyc
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_outline_rounded,
                                    size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Verify via DigiLocker (Instant)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Verified State Celebration Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF10B981), size: 48),
                const SizedBox(height: 12),
                Text(
                  'Full KYC Active & Compliant',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aadhaar: •••• •••• 1029  |  PAN: •••••1234F\nVerified via DigiLocker India Stack',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF059669), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF047857),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. SUPPORT & DISPUTE CENTER SECTION (PDF Page 12)
// Features:
// - Contact Support ticket raising screen
// - Issue category selection
// - Transaction/Session ID selector
// - Detailed description & proof attachments
// - Active tickets tracker with live status
// =============================================================================

class SupportDisputeSection extends StatefulWidget {
  const SupportDisputeSection({super.key});

  @override
  State<SupportDisputeSection> createState() => _SupportDisputeSectionState();
}

class _SupportDisputeSectionState extends State<SupportDisputeSection> {
  final _disputeFormKey = GlobalKey<FormState>();

  String _selectedCategory = 'Session Disconnection / Technical Drop';
  String _selectedPriority = 'Normal (Within 2 Hours)';
  final TextEditingController _sessionIdController =
      TextEditingController(text: 'SES-20260908-4819 (Video Call • ₹500)');
  final TextEditingController _issueDescriptionController =
      TextEditingController();

  bool _isSubmittingTicket = false;
  bool _hasAttachment = false;

  final List<String> _categories = [
    'Session Disconnection / Technical Drop',
    'Audio / Video Quality Issue',
    'Host No-Show / Unresponsive Creator',
    'Wallet Amount Deducted Twice',
    'Inappropriate Behavior / Content Violation',
    'Refund Inquiry',
    'Other Technical Dispute',
  ];

  final List<Map<String, dynamic>> _activeTickets = [
    {
      'id': 'TK-84920',
      'title': 'Voice Call Audio Cut-off',
      'category': 'Audio Quality',
      'status': 'Under Review',
      'statusColor': Color(0xFFF59E0B),
      'date': 'Today, 2:45 PM',
      'amount': '₹300',
    },
    {
      'id': 'TK-79102',
      'title': 'Duplicate Razorpay UPI Top-up',
      'category': 'Wallet Billing',
      'status': 'Resolved & Refunded',
      'statusColor': Color(0xFF10B981),
      'date': 'Yesterday, 6:12 PM',
      'amount': '₹500',
    },
  ];

  @override
  void dispose() {
    _sessionIdController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitTicket() async {
    if (!_disputeFormKey.currentState!.validate()) return;

    setState(() => _isSubmittingTicket = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    final newTicketId = 'TK-${DateTime.now().millisecondsSinceEpoch % 100000}';

    if (!mounted) return;
    setState(() {
      _isSubmittingTicket = false;
      _activeTickets.insert(0, {
        'id': newTicketId,
        'title': _selectedCategory,
        'category': 'Dispute • $_selectedPriority',
        'status': 'Investigating',
        'statusColor': const Color(0xFF0284C7),
        'date': 'Just now',
        'amount': '₹500',
      });
      _issueDescriptionController.clear();
      _hasAttachment = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ticket $newTicketId created! Our trust team will contact you.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pineDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Hero Gradient Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientEmeraldTeal,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x280D9488),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: Color(0xFF0F766E),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispute & Support Desk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Raise session concerns, claim transaction refunds, or contact 24/7 concierge.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 1. Raise a Dispute / Contact Support Form
        Text(
          'Raise a Support Ticket (PDF Requirement)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.pineDark,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _disputeFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue Category Dropdown
                Text(
                  'Issue Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FCFA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.pineDark),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pineDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Related Session / Transaction
                Text(
                  'Related Session or Transaction',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _sessionIdController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pineDark,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.receipt_long_rounded,
                        size: 18, color: AppColors.textMuted),
                    filled: true,
                    fillColor: const Color(0xFFF8FCFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 14),

                // Detailed Issue Description
                Text(
                  'Explain What Happened',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _issueDescriptionController,
                  maxLines: 3,
                  maxLength: 500,
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Please describe the issue in at least 10 characters';
                    }
                    return null;
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pineDark,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Provide details about call drop, payment discrepancy, or host behavior...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FCFA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                // Priority Level Selector
                Text(
                  'Urgency Level',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    'Normal (Within 2 Hours)',
                    'Urgent (Within 30 Mins)',
                  ].map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: priority.startsWith('Normal') ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            gradient:
                                isSelected ? AppColors.gradientEmeraldTeal : null,
                            color: isSelected ? null : const Color(0xFFF1F7F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              priority,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.pineDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Attachment Simulator
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _hasAttachment = !_hasAttachment);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _hasAttachment
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFF1F7F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasAttachment
                                  ? const Color(0xFF10B981)
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasAttachment
                                    ? Icons.check_circle_rounded
                                    : Icons.attach_file_rounded,
                                size: 16,
                                color: _hasAttachment
                                    ? const Color(0xFF10B981)
                                    : AppColors.pineDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _hasAttachment
                                    ? 'Log Attached'
                                    : 'Attach Proof',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _hasAttachment
                                      ? const Color(0xFF047857)
                                      : AppColors.pineDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientEmeraldTeal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3310B981),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmittingTicket ? null : _handleSubmitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmittingTicket
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Submit Support Ticket',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Active & Past Dispute Tickets
        Text(
          'Your Tickets & Disputes (${_activeTickets.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.pineDark,
          ),
        ),
        const SizedBox(height: 10),

        ..._activeTickets.map((ticket) {
          final color = ticket['statusColor'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_number_outlined,
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ticket['id'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket['status'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ticket['date']} • Value: ${ticket['amount']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        // 3. Instant Helpline Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded,
                  color: Color(0xFF334155), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Concierge Hotline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Toll-free 1800-TRYLO-CARE (24x7 India Support)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
