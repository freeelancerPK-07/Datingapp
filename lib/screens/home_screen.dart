import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/screens/become_creator_screen.dart';
import 'package:version1/screens/creator_detail_screen.dart';
import 'package:version1/screens/creator_profile_sheet.dart';
import 'package:version1/screens/liked_saved_screen.dart';
import 'package:version1/screens/profile_self_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/screens/video_calls_screen.dart';
import 'package:version1/screens/creator_studio_screen.dart';
import 'package:version1/screens/wallet_screen.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCountry = 'All Countries';
  String _selectedCategory = 'Featured';
  final List<String> _selectedLanguages = [];
  String _selectedGender = 'All';
  RangeValues _ageRange = const RangeValues(18, 50);
  bool _verifiedOnly = false;
  bool _onlineOnly = false;










  static const List<String> _categories = [
    'Featured',
    'Top Rated',
    'Trending',
    'Recommended',
    'Live Now',
  ];

  static const List<String> _availableLanguages = [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];


  Map<String, dynamic> _buildCreatorMap(CreatorModel c) {
    return {
      'id': c.id,
      'name': c.name,
      'age': c.age,
      'profession': c.profession,
      'location': c.location,
      'country': 'India',
      'distance': '2km',
      'diamondsPerMin': c.diamondsPerMin,
      'image': c.photoUrl.isNotEmpty
          ? c.photoUrl
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80',
      'galleryPhotos': c.galleryPhotos.isNotEmpty ? c.galleryPhotos : [c.photoUrl],
      'avatar': c.photoUrl.isNotEmpty
          ? c.photoUrl
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      'caption': c.bio,
      'bio': c.bio,
      'followers': c.followers,
      'rating': c.rating.toString(),
      'reviewCount': c.reviewCount,
      'likes': 100,
      'comments': 10,
      'tags': c.tags,
      'categories': ['Featured', 'Trending', 'Recommended'],
      'languages': c.languages,
      'gender': 'Female',
      'isVerified': c.isVerified,
      'isOnline': c.isOnline,
      'isLiked': AppState.instance.isCreatorLiked(c.id),
      'isFollowing': false,
      'isSaved': AppState.instance.isCreatorSaved(c.id),
    };
  }

  @override
  void initState() {
    super.initState();
    AppState.instance.syncCreatorsFromBackend();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCountry != 'All Countries') count++;
    if (_selectedCategory != 'Featured') count++;
    if (_selectedLanguages.isNotEmpty) count += _selectedLanguages.length;
    if (_selectedGender != 'All') count++;
    if (_ageRange.start > 18 || _ageRange.end < 50) count++;
    if (_verifiedOnly) count++;
    if (_onlineOnly) count++;
    if (_searchController.text.trim().isNotEmpty) count++;
    return count;
  }

  List<Map<String, dynamic>> get _filteredCreators {
    final query = _searchController.text.trim().toLowerCase();
    final liveModels = AppState.instance.allCreators;
    final sourceList = liveModels.map(_buildCreatorMap).toList();
    return sourceList.where((creator) {
      // 1. Search Query Filter
      if (query.isNotEmpty) {
        final name = (creator['name'] as String? ?? '').toLowerCase();
        final profession = (creator['profession'] as String? ?? '').toLowerCase();
        final bio = (creator['bio'] as String? ?? '').toLowerCase();
        final location = (creator['location'] as String? ?? '').toLowerCase();
        final tags = ((creator['tags'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().toLowerCase())
            .toList();
        final languages = ((creator['languages'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().toLowerCase())
            .toList();

        final matchesName = name.contains(query);
        final matchesProfession = profession.contains(query);
        final matchesBio = bio.contains(query);
        final matchesLocation = location.contains(query);
        final matchesTags = tags.any((t) => t.contains(query));
        final matchesLangs = languages.any((l) => l.contains(query));

        if (!matchesName &&
            !matchesProfession &&
            !matchesBio &&
            !matchesLocation &&
            !matchesTags &&
            !matchesLangs) {
          return false;
        }
      }

      // 2. Country Filter
      if (_selectedCountry != 'All Countries') {
        final country = creator['country'] as String? ?? 'India';
        if (country.toLowerCase() != _selectedCountry.toLowerCase()) {
          return false;
        }
      }

      // 3. Category Filter
      if (_selectedCategory != 'Featured') {
        if (_selectedCategory == 'Live Now') {
          if ((creator['isOnline'] as bool? ?? false) != true) return false;
        } else if (_selectedCategory == 'Top Rated') {
          final rating = double.tryParse(creator['rating']?.toString() ?? '0') ?? 0;
          if (rating < 4.9) return false;
        } else {
          final categories = ((creator['categories'] as List<dynamic>?) ?? [])
              .map((c) => c.toString())
              .toList();
          if (!categories.contains(_selectedCategory)) return false;
        }
      }

      // 4. Gender Filter
      if (_selectedGender != 'All') {
        final gender = creator['gender'] as String? ?? '';
        if (gender.toLowerCase() != _selectedGender.toLowerCase()) return false;
      }

      // 5. Age Range
      final age = (creator['age'] as num?)?.toInt() ?? 20;
      if (age < _ageRange.start || age > _ageRange.end) return false;

      // 6. Verified Only
      if (_verifiedOnly && (creator['isVerified'] as bool? ?? false) != true) {
        return false;
      }

      // 7. Online Only
      if (_onlineOnly && (creator['isOnline'] as bool? ?? false) != true) {
        return false;
      }

      // 8. Language Filter
      if (_selectedLanguages.isNotEmpty) {
        final langs = ((creator['languages'] as List<dynamic>?) ?? [])
            .map((l) => l.toString())
            .toList();
        final hasAnyLang = _selectedLanguages.any((l) => langs.contains(l));
        if (!hasAnyLang) return false;
      }

      return true;
    }).toList();
  }

  CreatorModel _convertToCreatorModel(Map<String, dynamic> c) {
    final isOnline = c['isOnline'] == true;
    final rating = double.tryParse(c['rating']?.toString() ?? '4.9') ?? 4.9;
    final reviewCount = (c['reviewCount'] as num?)?.toInt() ?? 128;
    final langs = ((c['languages'] as List<dynamic>?) ?? ['Tamil', 'English', 'Hindi'])
        .map((e) => e.toString())
        .toList();

    return CreatorModel(
      id: c['id'] ?? 'c1',
      name: c['name'] ?? 'Creator',
      age: (c['age'] as num?)?.toInt() ?? 22,
      photoUrl: c['image'] ?? c['avatar'] ?? '',
      isOnline: isOnline,
      isVerified: c['isVerified'] == true,
      isActive: true,
      bio: c['bio'] ?? c['caption'] ?? '',
      diamondsPerMin: (c['diamondsPerMin'] as num?)?.toInt() ?? 50,
      location: c['location'] ?? 'India',
      tags: ((c['tags'] as List<dynamic>?) ?? ['Creator']).map((e) => e.toString()).toList(),
      languages: langs,
      rating: rating,
      reviewCount: reviewCount,
      statusText: isOnline ? 'Online' : 'Offline, last seen 2h ago',
      profession: c['profession'] ?? 'Fashion Designer',
      followers: c['followers'] ?? '128K',
      responseTime: c['responseTime'] ?? 'Under 5m',
    );
  }

  void _openCreatorProfile(Map<String, dynamic> c) {
    final creatorModel = _convertToCreatorModel(c);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatorDetailScreen(creator: creatorModel),
      ),
    );
  }
  void _showAdvancedFiltersSheet() {
    List<String> tempLanguages = List.from(_selectedLanguages);
    String tempGender = _selectedGender;
    RangeValues tempAgeRange = _ageRange;
    bool tempVerifiedOnly = _verifiedOnly;
    bool tempOnlineOnly = _onlineOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Creators',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempLanguages.clear();
                              tempGender = 'All';
                              tempAgeRange = const RangeValues(18, 50);
                              tempVerifiedOnly = false;
                              tempOnlineOnly = false;
                            });
                          },
                          child: Text(
                            'Reset All',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      children: [
                        // Spoken Languages
                        Text(
                          'Spoken Languages',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableLanguages.map((lang) {
                            final isSel = tempLanguages.contains(lang);
                            return FilterChip(
                              label: Text(lang),
                              selected: isSel,
                              onSelected: (val) {
                                setSheetState(() {
                                  if (val) {
                                    tempLanguages.add(lang);
                                  } else {
                                    tempLanguages.remove(lang);
                                  }
                                });
                              },
                              selectedColor: LinkUpTheme.palePink,
                              checkmarkColor: LinkUpTheme.primaryTeal,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFF4B5563),
                              ),
                              backgroundColor: const Color(0xFFF9FAFB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Gender Filter
                        Text(
                          'Creator Gender',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: LinkUpTheme.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: ['All', 'Female', 'Male'].map((g) {
                            final isSel = tempGender == g;
                            return ChoiceChip(
                              label: Text(g),
                              selected: isSel,
                              onSelected: (val) {
                                if (val) setSheetState(() => tempGender = g);
                              },
                              selectedColor: LinkUpTheme.primaryTeal,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : const Color(0xFF4B5563),
                              ),
                              backgroundColor: const Color(0xFFF9FAFB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Age Range
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Age Range',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: LinkUpTheme.darkSlate,
                              ),
                            ),
                            Text(
                              '${tempAgeRange.start.toInt()} - ${tempAgeRange.end.toInt()} yrs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: LinkUpTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RangeSlider(
                          values: tempAgeRange,
                          min: 18,
                          max: 60,
                          divisions: 42,
                          activeColor: LinkUpTheme.primaryTeal,
                          inactiveColor: const Color(0xFFCEF1EB),
                          labels: RangeLabels(
                            '${tempAgeRange.start.toInt()}',
                            '${tempAgeRange.end.toInt()}',
                          ),
                          onChanged: (values) {
                            setSheetState(() => tempAgeRange = values);
                          },
                        ),

                        const SizedBox(height: 18),

                        // Verified Only Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: const Color(0xFF4285FF),
                          title: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: Color(0xFF4285FF), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Verified Creators Only',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Show only identity-verified profiles',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          value: tempVerifiedOnly,
                          onChanged: (v) {
                            setSheetState(() => tempVerifiedOnly = v);
                          },
                        ),

                        const Divider(height: 20, color: Color(0xFFE5E7EB)),

                        // Online Only Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: const Color(0xFF10B981),
                          title: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Online Now Only',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Show creators currently active for instant interaction',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          value: tempOnlineOnly,
                          onChanged: (v) {
                            setSheetState(() => tempOnlineOnly = v);
                          },
                        ),

                        const SizedBox(height: 28),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedLanguages.clear();
                                _selectedLanguages.addAll(tempLanguages);
                                _selectedGender = tempGender;
                                _ageRange = tempAgeRange;
                                _verifiedOnly = tempVerifiedOnly;
                                _onlineOnly = tempOnlineOnly;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LinkUpTheme.primaryTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'Apply Filters',
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCountry = 'All Countries';
      _selectedCategory = 'Featured';
      _selectedLanguages.clear();
      _selectedGender = 'All';
      _ageRange = const RangeValues(18, 50);
      _verifiedOnly = false;
      _onlineOnly = false;
    });
  }

  void _toggleLike(Map<String, dynamic> creator) {
    final id = creator['id']?.toString() ?? '';
    AppState.instance.toggleLikeCreator(id);
    final isLiked = AppState.instance.isCreatorLiked(id);
    setState(() {
      creator['isLiked'] = isLiked;
      final currentLikes = (creator['likes'] as int?) ?? 0;
      if (isLiked) {
        creator['likes'] = currentLikes + 1;
      } else {
        creator['likes'] = (currentLikes > 0) ? currentLikes - 1 : 0;
      }
    });
  }

  void _toggleFollow(Map<String, dynamic> creator) {
    setState(() {
      creator['isFollowing'] = !((creator['isFollowing'] as bool?) ?? false);
    });
    final isFollowing = (creator['isFollowing'] as bool?) ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowing ? 'Following ${creator['name']}' : 'Unfollowed ${creator['name']}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: LinkUpTheme.darkSlate,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleSave(Map<String, dynamic> creator) {
    final id = creator['id']?.toString() ?? '';
    AppState.instance.toggleSaveCreator(id);
    final isSaved = AppState.instance.isCreatorSaved(id);
    setState(() {
      creator['isSaved'] = isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Saved to bookmarks' : 'Removed from bookmarks',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: LinkUpTheme.darkSlate,
        duration: const Duration(seconds: 1),
      ),
    );
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

    final appState = AppState.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            switch (_currentTabIndex) {
              case 0:
                return _buildHomeTab(context, appState);
              case 1:
                return VideoCallsScreen(
                  onDiscoverTapped: () => setState(() => _currentTabIndex = 0),
                );
              case 2:
                return const WalletScreen();
              case 3:
                return const ProfileSelfScreen();
              default:
                return _buildHomeTab(context, appState);
            }
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===========================================================
  // TAB 1: MAIN HOME TAB (Instagram-Style Feed + LinkUp Design)
  // ===========================================================
  Widget _buildHomeTab(BuildContext context, AppState appState) {
    final filtered = _filteredCreators;

    return RefreshIndicator(
      color: LinkUpTheme.primaryTeal,
      onRefresh: () async {
        await appState.syncCreatorsFromBackend();
        if (mounted) setState(() {});
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Curved Gradient Header Card with Brand Logo, Greeting & Pill Search Bar
          SliverToBoxAdapter(
            child: _buildHeroGradientHeader(context, appState),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Category Tabs: Featured, Top Rated, Trending, Recommended, Live Now
          SliverToBoxAdapter(
            child: Container(
              height: 42,
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  final isLiveNow = cat == 'Live Now';

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLiveNow) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : const Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Text(
                            cat,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : LinkUpTheme.darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),



          // Feed Header: "Discover Creators" + Active Count + Filter Trigger
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Discover Creators',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: LinkUpTheme.darkSlate,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: LinkUpTheme.palePink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filtered.length} Creators',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: LinkUpTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_activeFiltersCount > 0)
                    GestureDetector(
                      onTap: _resetAllFilters,
                      child: Text(
                        'Clear Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _showAdvancedFiltersSheet,
                      child: const Icon(Icons.tune_rounded, color: LinkUpTheme.darkSlate, size: 20),
                    ),
                ],
              ),
            ),
          ),

          // Instagram-Style Vertical Scrolling Profiles Feed or Empty State
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: LinkUpTheme.palePink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: LinkUpTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Creators Yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first verified Creator on LinkUp. Register your profile to start connecting and earning on live 1-on-1 sessions.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BecomeCreatorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'Become a Creator',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LinkUpTheme.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final creator = filtered[index];
                    return _buildInstagramStylePost(creator);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        ),
      );
  }

  // ==========================================
  // SECTION 3, 4, 5: HERO CURVED GRADIENT HEADER (Harmonized with Pink Background)
  // ==========================================
  Widget _buildHeroGradientHeader(BuildContext context, AppState appState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinkUpTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007A78).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Organic Curved Blob Backgrounds (Harmonized with Mint/Teal Theme)
            Positioned(
              left: -50,
              top: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF004D40).withValues(alpha: 0.65),
                ),
              ),
            ),
            Positioned(
              right: -45,
              top: -35,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00A896).withValues(alpha: 0.65),
                ),
              ),
            ),
            Positioned(
              left: 50,
              bottom: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                ),
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Navigation Bar: Grid icon, LinkUp Text, Country, , Like Logo (No Profile Avatar)
                  Row(
                    children: [
                      // Official LinkUp App Logo (Requested Branding)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Image.memory(
                          kAppIconTealBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // LinkUp Brand Logo (Clean, No Heart Icon)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Link',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Up',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: const Color(0xFFFFD43B),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Creator Studio Button (Only shown if creator; empty for normal users)
                      if (appState.isCreator) ...[
                        GestureDetector(
                          key: const ValueKey('creator_studio_btn'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreatorStudioScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Studio',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],


                      // Diamond Badge
                      GestureDetector(
                        key: const ValueKey('header_diamond_badge'),
                        onTap: () => RechargePackagesSheet.show(context),
                        child: Container(
                          key: const ValueKey('recharge_diamonds_btn'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CoinIcon(size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${appState.availableCoins}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Like & Saved Activity Button (Opens LikedSavedScreen with badge counter)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LikedSavedScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 19,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (appState.likedCount > 0 || appState.savedCount > 0)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Center(
                                    child: Text(
                                      '${appState.likedCount + appState.savedCount}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Greeting Section: "Hey, Pradeep" (No Emoji) + Subtitle with Diamonds
                  Text(
                    'Hey, ${appState.userName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Discover your next connection â€¢ Recharge Diamonds',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rounded Pill Search Bar (inside the gradient card)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF007A78),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search creators by name...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                              size: 19,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _showAdvancedFiltersSheet,
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF007A78),
                              size: 19,
                            ),
                          ),
                      ],
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

  // ==========================================
  // INSTAGRAM-STYLE POST FOR EACH CREATOR
  // ==========================================
  Widget _buildInstagramStylePost(Map<String, dynamic> creator) {
    final id = creator['id']?.toString() ?? '';
    final bool isLiked = AppState.instance.isCreatorLiked(id) || ((creator['isLiked'] as bool?) ?? false);
    final bool isFollowing = (creator['isFollowing'] as bool?) ?? false;
    final bool isSaved = AppState.instance.isCreatorSaved(id) || ((creator['isSaved'] as bool?) ?? false);
    final bool isOnline = (creator['isOnline'] as bool?) ?? false;
    final creatorModel = _convertToCreatorModel(creator);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (Avatar with online dot, Name, Profession, Follow Button)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _openCreatorProfile(creator),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: LinkUpTheme.primaryTeal, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            creator['avatar'],
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 42,
                              height: 42,
                              color: const Color(0xFFE5F7F4),
                              child: const Icon(Icons.person, color: LinkUpTheme.primaryTeal),
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openCreatorProfile(creator),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${creator['name']}, ${creator['age']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: LinkUpTheme.darkSlate,
                                ),
                              ),
                            ),
                            if (creator['isVerified'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, color: Color(0xFF4285FF), size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${creator['profession']} â€¢ ${creator['location']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Connect / Following Pill
                OutlinedButton(
                  onPressed: () => _toggleFollow(creator),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    side: BorderSide(
                      color: isFollowing ? const Color(0xFFE5E7EB) : LinkUpTheme.primaryTeal,
                      width: 1.2,
                    ),
                    backgroundColor: isFollowing ? const Color(0xFFF9FAFB) : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Connect',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFollowing ? const Color(0xFF6B7280) : LinkUpTheme.primaryTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: LinkUpTheme.darkSlate, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => CreatorProfileSheet.show(context, creatorModel),
                ),
              ],
            ),
          ),

          // Main Media Carousel: Swipes across all 6 photos with dots + badges
          CreatorMediaCarousel(
            photos: (creator['galleryPhotos'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [creator['image'] as String],
            distance: creator['distance'] as String? ?? '2km',
            rating: creator['rating'] as String? ?? '4.9',
            onTap: () => _openCreatorProfile(creator),
            onDoubleTap: () => _toggleLike(creator),
          ),

          // Action Row (Like, Chat, Book Video Call CTA, Save)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? const Color(0xFFEF4444) : LinkUpTheme.darkSlate,
                    size: 26,
                  ),
                  onPressed: () => _toggleLike(creator),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),

                // "Book Video Call" CTA Button with Vibrant Teal & Mint Gradient
                GestureDetector(
                  key: const ValueKey('video_call_btn'),
                  onTap: () {
                    final appState = AppState.instance;
                    final check = appState.canStartVideoCall(creatorModel);
                    if (!check.isAllowed) {
                      CreatorProfileSheet.show(context, creatorModel);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveCallScreen(
                          creator: creatorModel,
                          isVideoCall: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinkUpTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007A78).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const Spacer(),

                // Save Bookmark Button
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? LinkUpTheme.primaryTeal : LinkUpTheme.darkSlate,
                    size: 24,
                  ),
                  onPressed: () => _toggleSave(creator),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${creator['likes']} likes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: LinkUpTheme.darkSlate,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Caption & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LinkUpTheme.darkSlate),
                children: [
                  TextSpan(
                    text: '${creator['name']} ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: creator['caption'],
                    style: const TextStyle(color: Color(0xFF4B5563), height: 1.35),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tags Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              children: (creator['tags'] as List<dynamic>).map((tag) {
                return Text(
                  '#$tag',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LinkUpTheme.primaryTeal,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // View Full Profile & Services Link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _openCreatorProfile(creator),
              child: Row(
                children: [
                  Text(
                    'View Profile â†’',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: LinkUpTheme.primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '(${creator['comments']} reviews & rate card)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 13: BOTTOM NAVIGATION BAR (Home, Chat, Wallet, Profile)
  // ==========================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: LinkUpTheme.primaryTeal,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam_rounded),
            label: 'Video Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}
}

class CreatorMediaCarousel extends StatefulWidget {
  final List<String> photos;
  final String distance;
  final String rating;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const CreatorMediaCarousel({
    super.key,
    required this.photos,
    required this.distance,
    required this.rating,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  State<CreatorMediaCarousel> createState() => _CreatorMediaCarouselState();
}

class _CreatorMediaCarouselState extends State<CreatorMediaCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validPhotos = widget.photos.where((p) => p.trim().isNotEmpty).toList();
    final displayPhotos = validPhotos.isNotEmpty
        ? validPhotos
        : ['https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80'];

    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      onTap: widget.onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: PageView.builder(
                controller: _pageController,
                itemCount: displayPhotos.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return Image.network(
                    displayPhotos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE5F7F4),
                      child: const Center(
                        child: Icon(Icons.person, size: 64, color: LinkUpTheme.primaryTeal),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Top Segmented Dots Indicator (like Instagram / Tinder)
          if (displayPhotos.length > 1)
            Positioned(
              top: 10,
              left: 14,
              right: 80, // room for distance pill
              child: Row(
                children: List.generate(
                  displayPhotos.length,
                  (idx) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: _currentIndex == idx
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Top Right Distance Pill
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, color: LinkUpTheme.primaryTeal, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.distance})',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Left Rating Pill
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD43B), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Right Photo Counter (e.g. 1/6)
          if (displayPhotos.length > 1)
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${displayPhotos.length}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
