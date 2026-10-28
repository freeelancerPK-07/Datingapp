import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/creator_detail_screen.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

class LikedSavedScreen extends StatefulWidget {
  final int initialTabIndex;
  const LikedSavedScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LikedSavedScreen> createState() => _LikedSavedScreenState();
}

class _LikedSavedScreenState extends State<LikedSavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatorProfile(CreatorModel creator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatorDetailScreen(creator: creator),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final likedList = appState.likedCreators;
        final savedList = appState.savedCreators;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FEFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: LinkUpTheme.darkSlate, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Favorites & Saved',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: LinkUpTheme.darkSlate,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCEF1EB)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: LinkUpTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: LinkUpTheme.primaryTeal.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF4A6B74),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text('Liked (${likedList.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text('Saved (${savedList.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildListOrEmpty(
                creators: likedList,
                isLikedTab: true,
                emptyTitle: 'No Liked Profiles Yet',
                emptySubtitle:
                    'Tap the heart icon on any creator card to save your favorite matches here for quick access.',
              ),
              _buildListOrEmpty(
                creators: savedList,
                isLikedTab: false,
                emptyTitle: 'No Saved Bookmarks',
                emptySubtitle:
                    'Bookmark creator profiles to revisit their stories, reviews, and services anytime.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListOrEmpty({
    required List<CreatorModel> creators,
    required bool isLikedTab,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (creators.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F7F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCEF1EB), width: 2),
                ),
                child: Center(
                  child: Icon(
                    isLikedTab ? Icons.favorite_border_rounded : Icons.bookmark_border_rounded,
                    size: 38,
                    color: LinkUpTheme.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emptyTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinkUpTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
                        color: LinkUpTheme.primaryTeal.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Discover Creators',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.64,
      ),
      itemCount: creators.length,
      itemBuilder: (context, index) {
        final creator = creators[index];
        return _buildCreatorGridCard(creator, isLikedTab);
      },
    );
  }

  Widget _buildCreatorGridCard(CreatorModel creator, bool isLikedTab) {
    final appState = AppState.instance;

    return GestureDetector(
      onTap: () => _openCreatorProfile(creator),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with Overlay Badges
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      creator.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5F7F4),
                        child: const Icon(Icons.person, color: LinkUpTheme.primaryTeal, size: 48),
                      ),
                    ),
                    // Gradient Bottom Shade
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Online Badge
                    if (creator.isOnline)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Toggle Action Button (Heart or Bookmark)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (isLikedTab) {
                            appState.toggleLikeCreator(creator.id);
                          } else {
                            appState.toggleSaveCreator(creator.id);
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isLikedTab
                                  ? (appState.isCreatorLiked(creator.id)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded)
                                  : (appState.isCreatorSaved(creator.id)
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded),
                              size: 18,
                              color: isLikedTab
                                  ? const Color(0xFFEF4444)
                                  : LinkUpTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Star Rating on Photo Bottom Left
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              creator.rating.toStringAsFixed(1),
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
                ),
              ),

              // Bottom Details
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${creator.name}, ${creator.age}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: LinkUpTheme.darkSlate,
                            ),
                          ),
                        ),
                        if (creator.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF007A78),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      creator.profession,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price & Connect Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CoinIcon(size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${creator.diamondsPerMin}/m',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: LinkUpTheme.darkSlate,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () => _openCreatorProfile(creator),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LinkUpTheme.primaryTeal,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Connect',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
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
        ),
      ),
    );
  }
}
