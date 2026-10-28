import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/screens/chat_room_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

/// Service Option model for Platform Standard Pricing
class ServiceOption {
  final String id;
  final String title;
  final String description;
  final int basePrice;
  final String baseDuration;
  final IconData icon;
  final List<DurationOption>? durationOptions;

  const ServiceOption({
    required this.id,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.baseDuration,
    required this.icon,
    this.durationOptions,
  });
}

class DurationOption {
  final String label;
  final int minutes;
  final int price;

  const DurationOption({
    required this.label,
    required this.minutes,
    required this.price,
  });
}

class CreatorDetailScreen extends StatefulWidget {
  final CreatorModel creator;

  const CreatorDetailScreen({super.key, required this.creator});

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  late final List<String> _gallery;

  // Platform Standard Services with Duration Options (PRD Section Pricing)
  late final List<ServiceOption> _services;

  @override
  void initState() {
    super.initState();
    _isFavorite = AppState.instance.isCreatorLiked(widget.creator.id);
    _gallery = [
      widget.creator.photoUrl.isNotEmpty
          ? widget.creator.photoUrl
          : 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    ];

    _services = [
      const ServiceOption(
        id: 'video_call',
        title: 'Video Call (10 Minutes)',
        description: 'Private 1-on-1 live HD video call interaction',
        basePrice: 500,
        baseDuration: '10 Minutes HD',
        icon: Icons.videocam_rounded,
        durationOptions: [
          DurationOption(label: '10 Mins', minutes: 10, price: 500),
          DurationOption(label: '20 Mins', minutes: 20, price: 1000),
          DurationOption(label: '30 Mins', minutes: 30, price: 1500),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openBookingFlow({String initialServiceId = 'video_call'}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookingFlowModal(
        creator: widget.creator,
        services: _services,
        initialServiceId: initialServiceId,
      ),
    );
  }

  void _showTierInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.creator.tier} Creator Status',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: LinkUpTheme.darkSlate,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Creators on LinkUp are categorized into Silver, Gold, Premium, and VIP tiers based on response speed, review rating, and interaction quality.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            _buildTierRow('VIP', '100% HD Quality • Under 5m Response • Top Rated', const Color(0xFFF59E0B)),
            _buildTierRow('Premium', 'High Definition • Fast Response • Certified Creator', const Color(0xFF8B5CF6)),
            _buildTierRow('Gold', 'Standard Pricing • Verified Identity', const Color(0xFF10B981)),
            _buildTierRow('Silver', 'Introductory Rates • Rising Talent', const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(String tier, String perks, Color color) {
    final isCurrent = widget.creator.tier.toUpperCase() == tier.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.12) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? color : const Color(0xFFE5E7EB),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tier,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              perks,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? LinkUpTheme.darkSlate : const Color(0xFF6B7280),
              ),
            ),
          ),
          if (isCurrent)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF007A78), size: 16),
        ],
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share ${widget.creator.name}\'s Profile',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: LinkUpTheme.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Invite friends to connect with ${widget.creator.name} on LinkUp.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: LinkUpTheme.primaryTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'https://linkup.app/creator/${widget.creator.id}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: 'https://linkup.app/creator/${widget.creator.id}',
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Profile link copied to clipboard!',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: LinkUpTheme.primaryTeal,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LinkUpTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Copy',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable Body
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding + 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Photo Carousel
                _buildPhotoCarousel(topPadding),

                // 2. Creator Info & Details Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Name, Age, Verified badge & Rating Chip
                      _buildHeader(),

                      const SizedBox(height: 6),

                      // Profession, Location & Tier Badge
                      _buildProfessionLocation(),

                      const SizedBox(height: 18),

                      // 3-Column Stats Card (Followers, Reviews, Response)
                      _buildStatsCard(),

                      const SizedBox(height: 20),

                      // Spoken Languages
                      _buildSpokenLanguages(),

                      const SizedBox(height: 20),

                      // About Creator & Hashtag Chips
                      _buildAboutCreator(),

                      const SizedBox(height: 24),

                      // Platform Standard Service Rate Card (All 4 Services)
                      _buildServiceRateCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Floating Navigation Bar (Back, Favorite, Share)
          _buildTopBar(topPadding),

          // Bottom Action Bar: "⚡ Book Service • From ₹200"
          _buildBottomBar(bottomPadding),
        ],
      ),
    );
  }

  // 1. Photo Carousel with online badge and indicator dots
  Widget _buildPhotoCarousel(double topPadding) {
    final imageHeight = MediaQuery.of(context).size.height * 0.44;

    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView for photos
          PageView.builder(
            controller: _pageController,
            itemCount: _gallery.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Image.network(
                _gallery[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF0F2B32),
                  child: const Center(
                    child: Icon(Icons.person, size: 80, color: Color(0xFF00A896)),
                  ),
                ),
              );
            },
          ),

          // Gradient overlay for bottom fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Online Status Badge (Bottom-left of image)
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.creator.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                      boxShadow: widget.creator.isOnline
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.creator.isOnline ? 'Online Now' : 'Offline',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Carousel Dot Indicators (Bottom-right of image)
          Positioned(
            right: 18,
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _gallery.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: _currentImageIndex == i ? 16 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top Floating Bar (Back, Favorite, Share)
  Widget _buildTopBar(double topPadding) {
    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),

          // Right action buttons (Heart & Share)
          Row(
            children: [
              _buildCircleIconButton(
                icon: _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor: _isFavorite
                    ? const Color(0xFFEF4444)
                    : Colors.white,
                onTap: () {
                  HapticFeedback.lightImpact();
                  AppState.instance.toggleLikeCreator(widget.creator.id);
                  final isFav = AppState.instance.isCreatorLiked(widget.creator.id);
                  setState(() => _isFavorite = isFav);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav ? 'Added to favorites ❤️' : 'Removed from favorites',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: LinkUpTheme.darkSlate,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildCircleIconButton(
                icon: Icons.share_rounded,
                onTap: _showShareSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  // Header: Name, Age, Verified badge & Star Rating Chip
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Name & Age
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  '${widget.creator.name}, ${widget.creator.age}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.darkSlate,
                    letterSpacing: -0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.creator.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified_rounded,
                  color: LinkUpTheme.mintAccent,
                  size: 20,
                ),
              ],
            ],
          ),
        ),

        // Rating Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3FBF9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCEF1EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF59E0B),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.creator.rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Profession, Location & Tier Badge
  Widget _buildProfessionLocation() {
    return Row(
      children: [
        Text(
          widget.creator.profession,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: LinkUpTheme.primaryTeal,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF9CA3AF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: Color(0xFF6B7280),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            widget.creator.location,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Tier Pricing Badge (Silver, Gold, Premium, VIP)
        InkWell(
          onTap: _showTierInfoSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👑', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  widget.creator.tier,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3-Column Stats Card
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCEF1EB)),
      ),
      child: Row(
        children: [
          // Followers
          Expanded(
            child: _buildStatItem(
              value: widget.creator.followers,
              label: 'Followers',
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: const Color(0xFFE2EAEF),
          ),
          // Reviews
          Expanded(
            child: _buildStatItem(
              value: '${widget.creator.reviewCount} Reviews',
              label: 'Reviews',
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: const Color(0xFFE2EAEF),
          ),
          // Response
          Expanded(
            child: _buildStatItem(
              value: widget.creator.responseTime,
              label: 'Response',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: LinkUpTheme.darkSlate,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // Spoken Languages
  Widget _buildSpokenLanguages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spoken Languages',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.creator.languages.map((lang) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2EAEF)),
              ),
              child: Text(
                lang,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // About Creator & Hashtag Chips
  Widget _buildAboutCreator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Creator',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.creator.bio,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.5,
            color: const Color(0xFF4A6B74),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.creator.tags.map((tag) {
            final tagText = tag.startsWith('#') ? tag : '#$tag';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tagText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.primaryTeal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Service Rate Card (All 4 Platform Standard Services)
  Widget _buildServiceRateCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Service Rate Card',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Platform Standard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 Standard Service Cards
        ..._services.map((service) {
          final isVideo = service.id == 'video_call';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openBookingFlow(initialServiceId: service.id),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isVideo ? LinkUpTheme.mintAccent : const Color(0xFFE5E7EB),
                    width: isVideo ? 1.5 : 1,
                  ),
                  boxShadow: isVideo
                      ? [
                          BoxShadow(
                            color: LinkUpTheme.primaryTeal.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Service Icon Container
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isVideo
                            ? const Color(0xFFE5F7F4)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        service.icon,
                        color: isVideo
                            ? LinkUpTheme.primaryTeal
                            : const Color(0xFF374151),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  service.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: LinkUpTheme.darkSlate,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CoinIcon(size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.basePrice}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isVideo
                                          ? LinkUpTheme.primaryTeal
                                          : const Color(0xFF0F2B32),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            service.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Duration: ${service.baseDuration}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: LinkUpTheme.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap to book →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: LinkUpTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Bottom Sticky Action Bar: Chat + "⚡ Book Video Call • ₹500"
  Widget _buildBottomBar(double bottomPadding) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding + 6 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Chat Action Button
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        creator: widget.creator,
                        conversationId: 'conv_${widget.creator.id}',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCEF1EB), width: 1.5),
                  backgroundColor: const Color(0xFFF0FAF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: LinkUpTheme.primaryTeal,
                  size: 18,
                ),
                label: Text(
                  'Chat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LinkUpTheme.primaryTeal,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Book Video Call CTA Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinkUpTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LinkUpTheme.primaryTeal.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    key: const ValueKey('video_call_btn'),
                    onPressed: () => _openBookingFlow(initialServiceId: 'video_call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        const CoinIcon(size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Book • 500 Coins',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}

// -----------------------------------------------------------------------------
// G. Booking Workflow — Full Flow (PDF Order Steps 1 to 11)
// -----------------------------------------------------------------------------
class _BookingFlowModal extends StatefulWidget {
  final CreatorModel creator;
  final List<ServiceOption> services;
  final String initialServiceId;

  const _BookingFlowModal({
    required this.creator,
    required this.services,
    required this.initialServiceId,
  });

  @override
  State<_BookingFlowModal> createState() => _BookingFlowModalState();
}

class _BookingFlowModalState extends State<_BookingFlowModal>
    with SingleTickerProviderStateMixin {
  // Steps: 1 = Confirm Booking Request, 2 = Creator Acceptance Engine (30s), 3 = Request Accepted!
  int _currentStep = 1;

  // Selected Service & Duration
  late ServiceOption _selectedService;
  DurationOption? _selectedDuration;
  late int _currentPrice;

  // 30-second Acceptance Engine Countdown (PRD Requirement: 30s timeout)
  int _countdownSeconds = 30;
  Timer? _countdownTimer;

  // Pulse animation for avatar ring & success checkmark
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.services.firstWhere(
      (s) => s.id == widget.initialServiceId,
      orElse: () => widget.services.last,
    );

    if (_selectedService.durationOptions != null &&
        _selectedService.durationOptions!.isNotEmpty) {
      _selectedDuration = _selectedService.durationOptions!.first;
      _currentPrice = _selectedDuration!.price;
    } else {
      _selectedDuration = null;
      _currentPrice = _selectedService.basePrice;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onServiceSelected(ServiceOption service) {
    setState(() {
      _selectedService = service;
      if (service.durationOptions != null && service.durationOptions!.isNotEmpty) {
        _selectedDuration = service.durationOptions!.first;
        _currentPrice = _selectedDuration!.price;
      } else {
        _selectedDuration = null;
        _currentPrice = service.basePrice;
      }
    });
  }

  void _onDurationSelected(DurationOption duration) {
    setState(() {
      _selectedDuration = duration;
      _currentPrice = duration.price;
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownSeconds = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
        } else {
          _countdownTimer?.cancel();
          _onTimedOut();
        }
      });
    });
  }

  /// Step 4: Money reserved -> Deduct from available balance, move to reserved bucket
  void _onConfirmAndReserve() {
    final appState = AppState.instance;

    // Step 3 validation check
    if (appState.walletBalance < _currentPrice) {
      Navigator.pop(context);
      RechargePackagesSheet.show(context);
      return;
    }

    HapticFeedback.heavyImpact();

    // Reserve money in Escrow Hold bucket
    appState.reserveBooking(
      serviceName: _selectedService.title,
      amount: _currentPrice.toDouble(),
      creatorName: widget.creator.name,
    );

    setState(() {
      _currentStep = 2; // Move to Creator Acceptance Engine
    });
    _startCountdown();
  }

  /// Step 5: Creator accepts -> Start session
  void _onSimulateAccept() {
    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _currentStep = 3; // Request Accepted!
    });

    // Step 6: Session starts after 1.2s
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pop(context); // close bottom sheet

      if (_selectedService.id == 'video_call') {
        final durationSecs = (_selectedDuration?.minutes ?? 10) * 60;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveCallScreen(
              creator: widget.creator,
              isVideoCall: true,
              initialDurationSeconds: durationSecs,
            ),
          ),
        );
      } else if (_selectedService.id == 'voice_call') {
        final durationSecs = (_selectedDuration?.minutes ?? 15) * 60;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveCallScreen(
              creator: widget.creator,
              isVideoCall: false,
              initialDurationSeconds: durationSecs,
            ),
          ),
        );
      } else {
        // Photo or Video Greeting -> Chat delivery room with settlement
        AppState.instance.completeBookingSettlement(
          serviceName: _selectedService.title,
          amount: _currentPrice.toDouble(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              creator: widget.creator,
              conversationId: 'conv_${widget.creator.id}',
            ),
          ),
        );
      }
    });
  }

  /// Step 5 Decline simulation -> 100% refund to available balance
  void _onSimulateDecline() {
    _countdownTimer?.cancel();
    HapticFeedback.mediumImpact();

    // Refund escrow
    AppState.instance.refundReservedBooking(
      serviceName: _selectedService.title,
      amount: _currentPrice.toDouble(),
      reason: 'Creator Unavailable',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.creator.name} is unable to take the request right now. $_currentPrice Coins instantly 100% refunded to your Available Balance!',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Step 5 User Cancel -> 100% refund to available balance
  void _onCancelRequest() {
    _countdownTimer?.cancel();
    HapticFeedback.lightImpact();

    // Refund escrow
    AppState.instance.refundReservedBooking(
      serviceName: _selectedService.title,
      amount: _currentPrice.toDouble(),
      reason: 'Cancelled by User',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Request cancelled. $_currentPrice Coins released back to your Available Balance.',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  /// Step 5 Timeout (30s) -> 100% auto refund to available balance
  void _onTimedOut() {
    // Refund escrow
    AppState.instance.refundReservedBooking(
      serviceName: _selectedService.title,
      amount: _currentPrice.toDouble(),
      reason: '30s Timeout',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Request timed out after 30 seconds. $_currentPrice Coins have been 100% refunded to your Available Balance.',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: const Color(0xFF6B7280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: LinkUpTheme.primaryTeal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Body Content based on Step
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentStep == 1
                    ? _buildStep1ConfirmContent()
                    : _currentStep == 2
                        ? _buildStep2AcceptanceEngineContent()
                        : _buildStep3AcceptedContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Confirm Booking Request (Choose Service, Duration & Payment Check)
  // ---------------------------------------------------------------------------
  Widget _buildStep1ConfirmContent() {
    final appState = AppState.instance;
    final isSufficient = appState.walletBalance >= _currentPrice;
    final shortage = _currentPrice - appState.walletBalance;

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title & Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Confirm Booking Request',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Creator Summary Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2B32), Color(0xFF005E5D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.creator.photoUrl),
                backgroundColor: LinkUpTheme.mintAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.creator.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2DD4BF),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        // Tier pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.creator.tier,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.creator.profession,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFFCEF1EB),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      widget.creator.rating.toStringAsFixed(1),
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
        ),

        const SizedBox(height: 16),

        // Select Service Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Service',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: LinkUpTheme.darkSlate,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Instant Connect',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 4 Service Selectable Cards
        ...widget.services.map((service) {
          final isSelected = _selectedService.id == service.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _onServiceSelected(service),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFFBEB) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        service.icon,
                        color: isSelected ? const Color(0xFFD97706) : const Color(0xFF4B5563),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  service.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: LinkUpTheme.darkSlate,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CoinIcon(size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.basePrice}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? const Color(0xFFD97706) : const Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Duration: ${service.baseDuration}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFFD97706) : const Color(0xFF9CA3AF),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Text(
                                  'Selected',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Duration Select (When Voice Call or Video Call has options)
        if (_selectedService.durationOptions != null) ...[
          const SizedBox(height: 10),
          Text(
            'Select Duration:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: LinkUpTheme.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: _selectedService.durationOptions!.map((dur) {
              final isDurSelected = _selectedDuration?.minutes == dur.minutes;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _onDurationSelected(dur),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDurSelected ? const Color(0xFFE5F7F4) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDurSelected ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                          width: isDurSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dur.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDurSelected ? LinkUpTheme.primaryTeal : const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CoinIcon(size: 11),
                              const SizedBox(width: 3),
                              Text(
                                '${dur.price}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDurSelected ? LinkUpTheme.primaryTeal : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 14),

        // Clean & Friendly Payment Summary Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: LinkUpTheme.primaryTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Payment Summary',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: LinkUpTheme.darkSlate,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSufficient ? const Color(0xFFE5F7F4) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isSufficient ? 'Ready to Book ✓' : 'Insufficient Coins ⚠️',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSufficient ? LinkUpTheme.primaryTeal : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Service & Cost Row (Wrapped with Expanded to prevent overflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedService.title}${_selectedDuration != null ? ' (${_selectedDuration!.label})' : ''}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF4A6B74),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentPrice Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: LinkUpTheme.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Available Coins Balance Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF4A6B74),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${appState.availableCoins} Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSufficient ? LinkUpTheme.primaryTeal : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isSufficient) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Short by',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CoinIcon(size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${shortage.toInt()} Coins',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 100% Refund Guarantee reassurance banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCEF1EB)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.security_rounded,
                color: LinkUpTheme.primaryTeal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '100% Refund Guarantee: Coins are held safely and only deducted once creator accepts your call.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF005E5D),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // CTA: Confirm & Request Button (or Recharge if Insufficient)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinkUpTheme.buttonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LinkUpTheme.primaryTeal.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _onConfirmAndReserve,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSufficient ? Icons.lock_outline_rounded : Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isSufficient
                          ? 'Confirm & Request ($_currentPrice Coins)'
                          : 'Recharge Coins (Short by ${shortage.toInt()})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Creator Acceptance Screen (30s Countdown)
  // ---------------------------------------------------------------------------
  Widget _buildStep2AcceptanceEngineContent() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        // Connecting Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radar_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Waiting for Acceptance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Request Sent to Creator...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Waiting for acceptance (30s timer)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),

        const SizedBox(height: 22),

        // Circular Avatar with Animated Radial Progress Ring & Countdown Timer
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Progress / Pulse Ring
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: 126,
                  height: 126,
                  child: CircularProgressIndicator(
                    value: _countdownSeconds / 30,
                    strokeWidth: 4.5,
                    backgroundColor: const Color(0xFFCEF1EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      LinkUpTheme.primaryTeal,
                    ),
                  ),
                ),
              ),
              // Creator Avatar
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(widget.creator.photoUrl),
                backgroundColor: LinkUpTheme.mintAccent,
              ),
              // Countdown Pill overlapping bottom of avatar
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: LinkUpTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${_countdownSeconds}s',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Escrow Hold Notice Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCEF1EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LinkUpTheme.primaryTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: LinkUpTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_currentPrice Coins Locked in Escrow',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alert sent to ${widget.creator.name}. If declined or timed out (30s), 100% instant refund to Available Balance.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF4A6B74),
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

        // Action Buttons Row: Cancel Request & Simulate Accept
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _onCancelRequest,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Cancel Request',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinkUpTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: LinkUpTheme.primaryTeal.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onSimulateAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Simulate Accept',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Decline Test Simulation Link
        Center(
          child: TextButton.icon(
            onPressed: _onSimulateDecline,
            icon: const Icon(
              Icons.cancel_outlined,
              color: Color(0xFFEF4444),
              size: 14,
            ),
            label: Text(
              'Simulate Creator Decline (Test 100% Refund)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Request Accepted! (Auto Launch Session - PDF Step 6)
  // ---------------------------------------------------------------------------
  Widget _buildStep3AcceptedContent() {
    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 18),

        // Big Checkmark in Teal Pulse Circle
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF007A78), Color(0xFF00A896)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x5500A896),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Request Accepted!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.creator.name} accepted your ${_selectedService.title}. Connecting secure session now...',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF4A6B74),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        // Loading Spinner
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(LinkUpTheme.primaryTeal),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
