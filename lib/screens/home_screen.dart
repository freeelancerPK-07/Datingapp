import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/app_icon_base64.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/screens/creator_detail_screen.dart';
import 'package:version1/screens/creator_profile_sheet.dart';
import 'package:version1/screens/liked_saved_screen.dart';
import 'package:version1/screens/profile_self_screen.dart';
import 'package:version1/screens/profile_setup_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/screens/video_calls_screen.dart';
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

  static const List<String> _countries = [
    'All Countries',
    'India',
    'Singapore',
    'UAE',
    'United Kingdom',
    'United States',
  ];

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


  late final List<Map<String, dynamic>> _creators;

  @override
  void initState() {
    super.initState();
    _creators = [
      {
        'id': 'c1',
        'name': 'Aanya Sharma',
        'age': 23,
        'profession': 'Bollywood Dancer & Creator',
        'location': 'Bandra, Mumbai',
        'country': 'India',
        'distance': '2km',
        'diamondsPerMin': 50,
        'image':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Bollywood choreography and aesthetic lifestyle vlogs. Let us connect through live dance chats and positive energy!',
        'bio':
            'Bollywood dancer and lifestyle creator. Love sharing positive vibes, choreography tips, and private video sessions.',
        'followers': '142K',
        'rating': '4.9',
        'reviewCount': 136,
        'likes': 1420,
        'comments': 54,
        'tags': ['Dance', 'Lifestyle', 'Bollywood', 'Music'],
        'categories': ['Featured', 'Top Rated', 'Trending', 'Live Now'],
        'languages': ['English', 'Hindi', 'Tamil'],
        'gender': 'Female',
        'isVerified': true,
        'isOnline': true,
        'isLiked': true,
        'isFollowing': true,
        'isSaved': false,
      },
      {
        'id': 'c2',
        'name': 'Olivia Fisher',
        'age': 20,
        'profession': 'Fashion Designer',
        'location': 'Juhu, Mumbai',
        'country': 'India',
        'distance': '3km',
        'diamondsPerMin': 50,
        'image':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Designing the new summer pastel collection. Coffee breaks and vintage boutique hopping. Let us connect and spark creativity!',
        'bio':
            'Fashion designer and visual storyteller. Living between art galleries, vintage boutiques, and rooftop coffee shops.',
        'followers': '128K',
        'rating': '4.9',
        'reviewCount': 128,
        'likes': 1284,
        'comments': 48,
        'tags': ['Fashion', 'PastelAesthetic', 'Coffee', 'Art'],
        'categories': ['Featured', 'Trending', 'Recommended'],
        'languages': ['English', 'Tamil', 'Hindi'],
        'gender': 'Female',
        'isVerified': true,
        'isOnline': true,
        'isLiked': false,
        'isFollowing': false,
        'isSaved': false,
      },
      {
        'id': 'c3',
        'name': 'Maya Patel',
        'age': 22,
        'profession': 'Digital Creator & DJ',
        'location': 'Juhu Beach, Mumbai',
        'country': 'India',
        'distance': '5km',
        'diamondsPerMin': 60,
        'image':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Sunset rooftop session dropping tonight! Curating electronic beats and aesthetic lifestyle vlogs. Who is joining for the live set?',
        'bio':
            'Music producer, sunset chaser, and content creator. Spreading good energy and electronic rhythms.',
        'followers': '94K',
        'rating': '4.9',
        'reviewCount': 96,
        'likes': 2140,
        'comments': 86,
        'tags': ['Music', 'ElectronicBeats', 'DJ', 'Fitness'],
        'categories': ['Featured', 'Top Rated', 'Trending', 'Live Now'],
        'languages': ['English', 'Hindi', 'Tamil'],
        'gender': 'Female',
        'isVerified': true,
        'isOnline': true,
        'isLiked': true,
        'isFollowing': true,
        'isSaved': true,
      },
      {
        'id': 'c4',
        'name': 'Rohan Mehra',
        'age': 25,
        'profession': 'Fitness Coach & Trainer',
        'location': 'Connaught Place, Delhi',
        'country': 'India',
        'distance': '4km',
        'diamondsPerMin': 60,
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Pushing limits every single day. Let us discuss custom workout plans, nutrition goals, and healthy lifestyle routines.',
        'bio':
            'Certified strength & conditioning coach. Helping people achieve their dream fitness goals through 1-on-1 consultations.',
        'followers': '85K',
        'rating': '4.8',
        'reviewCount': 72,
        'likes': 1120,
        'comments': 38,
        'tags': ['Fitness', 'Workout', 'Nutrition', 'Health'],
        'categories': ['Featured', 'Trending'],
        'languages': ['English', 'Hindi', 'Punjabi'],
        'gender': 'Male',
        'isVerified': true,
        'isOnline': true,
        'isLiked': false,
        'isFollowing': false,
        'isSaved': false,
      },
      {
        'id': 'c5',
        'name': 'Liam Vance',
        'age': 24,
        'profession': 'Editorial Photographer',
        'location': 'Colaba, Mumbai',
        'country': 'United Kingdom',
        'distance': '8km',
        'diamondsPerMin': 45,
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Golden hour raw portraits on 35mm film. The street colors in Mumbai during dusk are unmatched.',
        'bio':
            'Capturing raw emotions through analog 35mm film. Always down for spontaneous road trips and indie gigs.',
        'followers': '65K',
        'rating': '4.8',
        'reviewCount': 52,
        'likes': 890,
        'comments': 32,
        'tags': ['Photography', '35mm', 'StreetFilm', 'IndieRock'],
        'categories': ['Featured', 'Recommended'],
        'languages': ['English', 'French'],
        'gender': 'Male',
        'isVerified': true,
        'isOnline': false,
        'isLiked': false,
        'isFollowing': false,
        'isSaved': false,
      },
      {
        'id': 'c6',
        'name': 'Sophia Chen',
        'age': 21,
        'profession': 'Yoga & Wellness Coach',
        'location': 'Marine Drive, Mumbai',
        'country': 'Singapore',
        'distance': '4km',
        'diamondsPerMin': 55,
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Morning meditation and sunrise yoga flow. Finding peace and breath amidst the vibrant city pace. Breathe in calmness, breathe out doubts.',
        'bio':
            'Certified mindfulness and yoga instructor. Encouraging holistic living, plant-based smoothies, and mindful connections.',
        'followers': '112K',
        'rating': '5.0',
        'reviewCount': 142,
        'likes': 1650,
        'comments': 59,
        'tags': ['YogaFlow', 'Wellness', 'Mindfulness', 'HealthyLiving'],
        'categories': ['Featured', 'Top Rated', 'Trending', 'Live Now'],
        'languages': ['English', 'Tamil', 'Telugu'],
        'gender': 'Female',
        'isVerified': true,
        'isOnline': true,
        'isLiked': false,
        'isFollowing': false,
        'isSaved': false,
      },
      {
        'id': 'c7',
        'name': 'Elena Rostova',
        'age': 22,
        'profession': 'Travel & Food Storyteller',
        'location': 'Downtown Marina, Dubai',
        'country': 'UAE',
        'distance': '2km',
        'diamondsPerMin': 50,
        'image':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop&q=80',
        'avatar':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        'caption':
            'Exploring hidden street food alleys and capturing colorful stories. Anyone up for a sunset street food adventure?',
        'bio':
            'Full-time travel journalist and food curator. Visited 24 countries, seeking authentic local experiences.',
        'followers': '175K',
        'rating': '4.9',
        'reviewCount': 188,
        'likes': 3210,
        'comments': 142,
        'tags': ['TravelStory', 'Foodie', 'Wanderlust', 'StreetEats'],
        'categories': ['Featured', 'Recommended', 'Trending'],
        'languages': ['English', 'Tamil', 'Kannada'],
        'gender': 'Female',
        'isVerified': true,
        'isOnline': true,
        'isLiked': false,
        'isFollowing': false,
        'isSaved': false,
      },
    ];
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
    return _creators.where((creator) {
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



  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Country',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  if (_selectedCountry != 'All Countries')
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCountry = 'All Countries');
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.plusJakartaSans(
                          color: LinkUpTheme.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ..._countries.map((country) {
                final isSelected = _selectedCountry == country;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.public_rounded,
                    color: isSelected ? LinkUpTheme.primaryTeal : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  title: Text(
                    country,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? LinkUpTheme.darkSlate : const Color(0xFF4B5563),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: LinkUpTheme.primaryTeal, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedCountry = country);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
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
          isSaved ? 'Saved to bookmarks ❤️' : 'Removed from bookmarks',
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

  // ==========================================
  // PROFILE INCOMPLETE GATE BANNER (Placed directly below top hero box widget)
  // ==========================================
  Widget _buildProfileCompletionBanner(BuildContext context, AppState appState) {
    final int step = appState.userProfile.currentStep;
    final double percent = ((step / 10) * 100).clamp(10, 100);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFCEF1EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: LinkUpTheme.primaryTeal.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo / Lock Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCEF1EB)),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.memory(
              kAppIconTealBytes,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Complete Your Profile to Access Creator Profiles',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkUpTheme.darkSlate,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'To discover verified creators, start live HD video calls, and connect with people near you, you must complete your profile 100%.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Profile Progress Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCEF1EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Status: ${percent.toInt()}% Completed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LinkUpTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      'Step $step of 10',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.darkSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (step / 10).clamp(0.1, 1.0),
                    minHeight: 7,
                    backgroundColor: const Color(0xFFCEF1EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(LinkUpTheme.primaryTeal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Complete Profile to Access Creator Profiles Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinkUpTheme.buttonGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: LinkUpTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Complete Profile to Access Creators',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            '🔒 Takes less than 2 minutes • 100% Safe & Private',
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

  Widget _buildLockedCreatorsPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FEFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCEF1EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F7F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: LinkUpTheme.primaryTeal, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '500+ Verified Creators Waiting',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Preview circles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 4; i++)
                Align(
                  widthFactor: 0.72,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _creators[i % _creators.length]['avatar'],
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFCEF1EB),
                          child: const Icon(Icons.person, color: LinkUpTheme.primaryTeal, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: LinkUpTheme.palePink,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCEF1EB)),
                ),
                child: Text(
                  '+500 Online',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete your profile above to unlock full creator profiles, live chats & instant video calls.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
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
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Curved Gradient Header Card with Brand Logo, Greeting & Pill Search Bar
          SliverToBoxAdapter(
            child: _buildHeroGradientHeader(context, appState),
          ),

          // 100% Profile Completion Gate Check
          if (!appState.isProfileCompleted) ...[
            SliverToBoxAdapter(
              child: _buildProfileCompletionBanner(context, appState),
            ),
            SliverToBoxAdapter(
              child: _buildLockedCreatorsPreview(context),
            ),
          ] else ...[

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
                      'No Creators Found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search keyword, country selector, or filters to discover amazing creators.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetAllFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LinkUpTheme.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Reset Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
                  // Top Navigation Bar: Grid icon, LinkUp Text, Country, 💎, Like Logo (No Profile Avatar)
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

                      // Country Selector Pill
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.public_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCountry == 'All Countries'
                                    ? 'Global'
                                    : _selectedCountry,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 13, color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

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
                    'Discover your next connection • Recharge Diamonds',
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
                          '${creator['profession']} • ${creator['location']}',
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

          // Main Media Photo with Tap to Open Detail Page & Double-Tap to Like
          GestureDetector(
            onDoubleTap: () => _toggleLike(creator),
            onTap: () => _openCreatorProfile(creator),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: Image.network(
                      creator['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5F7F4),
                        child: const Center(
                          child: Icon(Icons.person, size: 64, color: LinkUpTheme.primaryTeal),
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
                          '(${creator['distance']})',
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
                          '${creator['rating']}',
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
              ],
            ),
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
                    'View Profile →',
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
