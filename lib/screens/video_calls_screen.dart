import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/models/call_record_model.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/calling_screen.dart';
import 'package:version1/screens/creator_detail_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

class VideoCallsScreen extends StatefulWidget {
  final VoidCallback? onDiscoverTapped;

  const VideoCallsScreen({
    super.key,
    this.onDiscoverTapped,
  });

  @override
  State<VideoCallsScreen> createState() => _VideoCallsScreenState();
}

class _VideoCallsScreenState extends State<VideoCallsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Design Tokens (PRD Section 2)
  static const Color _primaryTeal = Color(0xFF006B6B);
  static const Color _darkTeal = Color(0xFF003F46);
  static const Color _surfaceBg = Color(0xFFF8FAFC);
  static const Color _borderGrey = Color(0xFFE5E7EB);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _onlineGreen = Color(0xFF22C55E);
  static const Color _missedRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // Video Call Initiation Flow (PRD Section 5 & 7)
  // -------------------------------------------------------------
  void _initiateVideoCall(CreatorModel creator) {
    final appState = AppState.instance;

    // 1. Availability validation
    if (!creator.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${creator.name} is currently offline and unavailable for video calls.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1F2937),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Wallet Balance Check (LinkUp Coins)
    const int requiredCoins = 500; // 10 minutes HD session
    if (appState.availableCoins < requiredCoins) {
      _showInsufficientBalanceSheet(creator, requiredCoins);
      return;
    }

    // 3. Navigate to Outgoing Call Screen (CallingScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallingScreen(
          creator: creator,
          isVideoCall: true,
        ),
      ),
    );
  }

  void _showInsufficientBalanceSheet(CreatorModel creator, int requiredCoins) {
    final appState = AppState.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: _borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCEF1EB), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.videocam_rounded, color: _primaryTeal, size: 30),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Coins Required for Video Call',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '10-Minute live HD video call with ${creator.name} requires $requiredCoins LinkUp Coins.\nYour available balance: ${appState.availableCoins} Coins.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  RechargePackagesSheet.show(context);
                },
                icon: const Icon(Icons.bolt_rounded, color: Colors.white),
                label: Text(
                  'Recharge LinkUp Coins',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Call History?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all previous call records? This cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: _textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppState.instance.clearCallHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Call history cleared.',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _darkTeal,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _missedRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Main Build
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allCreators = appState.activeCreators;

        // Filter Creators based on search
        final filteredCreators = allCreators.where((c) {
          if (_searchQuery.isEmpty) return true;
          return c.name.toLowerCase().contains(_searchQuery) ||
              c.bio.toLowerCase().contains(_searchQuery) ||
              c.tags.any((t) => t.toLowerCase().contains(_searchQuery));
        }).toList();

        final onlineCreators = filteredCreators.where((c) => c.isOnline).toList();
        final suggestedCreators = filteredCreators.toList();

        // Filter Call History
        final callHistory = appState.callHistory.where((call) {
          if (_searchQuery.isEmpty) return true;
          return call.name.toLowerCase().contains(_searchQuery);
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildTopBrandAppBar(context, appState),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              // ==========================================
              // 1. SCREEN HEADER (PRD Section 4)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Calls',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Meet someone new, face to face.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (callHistory.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined, color: _textSecondary),
                      tooltip: 'Clear Call History',
                      onPressed: _showClearHistoryConfirmDialog,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. SEARCH BAR (PRD Section 4)
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: _surfaceBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _borderGrey),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: _primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search people...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. ONLINE CREATORS (Horizontal Scrolling Cards)
              // ==========================================
              _buildSectionTitle(
                title: 'Online Creators',
                count: onlineCreators.length,
                showPulse: true,
              ),
              const SizedBox(height: 10),

              if (onlineCreators.isEmpty)
                Container(
                  height: 110,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: Center(
                    child: Text(
                      'No online creators matching search right now.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 195,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: onlineCreators.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final creator = onlineCreators[i];
                      return _buildOnlineCreatorCard(creator);
                    },
                  ),
                ),

              const SizedBox(height: 26),

              // ==========================================
              // 4. RECENT CALLS (PRD Section 4)
              // ==========================================
              _buildSectionTitle(
                title: 'Recent Calls',
                count: callHistory.length,
              ),
              const SizedBox(height: 10),

              if (callHistory.isEmpty)
                _buildEmptyCallsState()
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: callHistory.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: _borderGrey,
                    ),
                    itemBuilder: (context, i) {
                      final call = callHistory[i];
                      return _buildCallHistoryTile(call, allCreators);
                    },
                  ),
                ),

              const SizedBox(height: 26),

              // ==========================================
              // 5. SUGGESTED PEOPLE (PRD Section 4)
              // ==========================================
              _buildSectionTitle(
                title: 'Suggested People',
                count: suggestedCreators.length,
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestedCreators.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final creator = suggestedCreators[i];
                  return _buildSuggestedPersonCard(creator);
                },
              ),

              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Header with LinkUp App Logo & Proper Branding (User Request)
  // -------------------------------------------------------------
  PreferredSizeWidget _buildTopBrandAppBar(BuildContext context, AppState appState) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 18,
      title: Row(
        children: [
          // Official LinkUp App Icon (Logo on Mobile top)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCEF1EB)),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.memory(
              kAppIconTealBytes,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),

          // LinkUp Name Branding
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Link',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _primaryTeal,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Up',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF59E0B),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Coin Balance Card Shortcut
        GestureDetector(
          onTap: () => RechargePackagesSheet.show(context),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCEF1EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 14),
                const SizedBox(width: 4),
                Text(
                  '${appState.availableCoins}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.settings_outlined, color: _textPrimary, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Audio & Video Settings: HD Stream • Auto-Echo Cancellation Enabled',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                backgroundColor: _darkTeal,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // -------------------------------------------------------------
  // Online Creator Card (Horizontal)
  // -------------------------------------------------------------
  Widget _buildOnlineCreatorCard(CreatorModel creator) {
    return Container(
      width: 125,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        children: [
          // Photo with Online indicator
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatorDetailScreen(creator: creator),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    creator.photoUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: _darkTeal,
                      child: const Icon(Icons.person, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _onlineGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Name & Age
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  creator.name.split(' ').first,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${creator.age}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Availability Chip
          Text(
            creator.isOnline ? 'Available' : 'Busy',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: creator.isOnline ? _onlineGreen : _textSecondary,
            ),
          ),

          const Spacer(),

          // Video Call Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: creator.isOnline ? () => _initiateVideoCall(creator) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryTeal,
                disabledBackgroundColor: _borderGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Call History Tile
  // -------------------------------------------------------------
  Widget _buildCallHistoryTile(CallRecord call, List<CreatorModel> creators) {
    // Determine status badge & icon
    IconData statusIcon;
    Color statusColor;
    String statusLabel;

    switch (call.type) {
      case CallType.completed:
        statusIcon = Icons.call_made_rounded;
        statusColor = _onlineGreen;
        statusLabel = 'Completed • ${call.durationText} • ${call.coinsUsed} Coins';
        break;
      case CallType.missed:
        statusIcon = Icons.call_missed_rounded;
        statusColor = _missedRed;
        statusLabel = 'Missed Call';
        break;
      case CallType.rejected:
        statusIcon = Icons.phone_disabled_rounded;
        statusColor = const Color(0xFFF97316);
        statusLabel = 'Declined';
        break;
      case CallType.outgoing:
        statusIcon = Icons.call_made_rounded;
        statusColor = _primaryTeal;
        statusLabel = 'Outgoing • ${call.durationText}';
        break;
      case CallType.incoming:
        statusIcon = Icons.call_received_rounded;
        statusColor = _onlineGreen;
        statusLabel = 'Incoming • ${call.durationText}';
        break;
    }

    final matchedCreator = creators.firstWhere(
      (c) => c.id == call.creatorId || c.name == call.name,
      orElse: () => CreatorModel(
        id: call.creatorId,
        name: call.name,
        age: call.age,
        photoUrl: call.photoUrl,
        isOnline: call.isOnline,
        isVerified: true,
        isActive: true,
        bio: 'LinkUp Creator',
        diamondsPerMin: 50,
      ),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: _surfaceBg,
            foregroundImage: call.photoUrl.isNotEmpty ? NetworkImage(call.photoUrl) : null,
            onForegroundImageError: call.photoUrl.isNotEmpty ? (exception, stackTrace) {} : null,
            child: const Icon(Icons.person, color: _primaryTeal),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 13),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Text(
            call.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${call.age}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              statusLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            ' • ${call.timeFormatted}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCEF1EB)),
          ),
          child: const Icon(Icons.videocam_rounded, color: _primaryTeal, size: 18),
        ),
        tooltip: 'Call Again',
        onPressed: () => _initiateVideoCall(matchedCreator),
      ),
    );
  }

  // -------------------------------------------------------------
  // Suggested Person Card (Responsive)
  // -------------------------------------------------------------
  Widget _buildSuggestedPersonCard(CreatorModel creator) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Photo with Verified badge
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatorDetailScreen(creator: creator),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    creator.photoUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: _darkTeal,
                      child: const Icon(Icons.person, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: creator.isOnline ? _onlineGreen : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Details & Bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${creator.name}, ${creator.age}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (creator.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 15),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  creator.bio,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CoinIcon(size: 11),
                          const SizedBox(width: 3),
                          Text(
                            '${creator.diamondsPerMin} Coins/min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      creator.location.split(',').first,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Start Video Call Action
          ElevatedButton(
            onPressed: () => _initiateVideoCall(creator),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Call',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Empty State (PRD Section 4)
  // -------------------------------------------------------------
  Widget _buildEmptyCallsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: _surfaceBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGrey),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCEF1EB)),
            ),
            child: const Icon(
              Icons.videocam_outlined,
              color: _primaryTeal,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No calls yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your next connection could start with a video call.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: widget.onDiscoverTapped,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCEF1EB), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: Text(
              'Discover Available People',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, int? count, bool showPulse = false}) {
    return Row(
      children: [
        if (showPulse) ...[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _onlineGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
