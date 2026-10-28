import 'dart:convert';

/// Complete User Profile Data Model for LinkUp Dating App Onboarding & Profile
class UserProfile {
  final String name;
  final DateTime? dob;
  final String gender; // 'Male', 'Female', 'Other'
  final String photoUrl;
  final List<String> galleryPhotos; // 4 to 6 photos
  final String bio;
  final List<String> interests;
  final List<String> languages;
  final String city;
  final String state;
  final String country;
  final String lookingFor; // 'Friendship', 'Dating & Chat', 'Serious Relationship', 'Casual & Fun'
  final String height; // e.g. "5' 10\" (178 cm)"
  final String job; // e.g. "UI/UX Designer"
  final String education; // e.g. "B.Tech Computer Science"
  final String instagram; // e.g. "pradeep.design"
  final double rating; // e.g. 4.9
  final int reviewCount; // e.g. 18
  final List<Map<String, String>> prompts; // Interactive profile question + answer list
  final bool isVerified;
  final bool hideOnlineStatus;
  final bool hideDistance;
  final List<String> blockedUsers;
  final String appLanguage;
  final bool notificationsEnabled;
  final bool cameraEnabled;
  final bool microphoneEnabled;
  final bool profileCompleted;
  final int currentStep; // 1 to 10 for draft resume

  const UserProfile({
    this.name = '',
    this.dob,
    this.gender = '',
    this.photoUrl = '',
    this.galleryPhotos = const [],
    this.bio = '',
    this.interests = const [],
    this.languages = const [],
    this.city = '',
    this.state = '',
    this.country = 'India',
    this.lookingFor = 'Dating & Chat',
    this.height = '',
    this.job = '',
    this.education = '',
    this.instagram = '',
    this.rating = 5.0,
    this.reviewCount = 0,
    this.prompts = const [
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
    ],
    this.isVerified = true,
    this.hideOnlineStatus = false,
    this.hideDistance = false,
    this.blockedUsers = const [],
    this.appLanguage = 'English',
    this.notificationsEnabled = true,
    this.cameraEnabled = true,
    this.microphoneEnabled = true,
    this.profileCompleted = false,
    this.currentStep = 1,
  });

  /// Computes real age from Date of Birth
  int get age {
    if (dob == null) return 0;
    final now = DateTime.now();
    int calculatedAge = now.year - dob!.year;
    if (now.month < dob!.month || (now.month == dob!.month && now.day < dob!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// 18+ Age Validation (Dating app safety compliance)
  bool get isAdult => age >= 18;

  /// Validation status for each onboarding step
  bool isStepValid(int step) {
    switch (step) {
      case 1: // Name: 2-30 chars, no digits/emoji
        final trimmed = name.trim();
        return trimmed.length >= 2 &&
            trimmed.length <= 30 &&
            RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(trimmed);
      case 2: // Birthday: 18+ required
        return dob != null && isAdult;
      case 3: // Gender: Male, Female, Other
        return gender.isNotEmpty;
      case 4: // Profile photo: 1 required
        return photoUrl.isNotEmpty;
      case 5: // Bio: Optional / skippable (max 150 chars)
        return bio.length <= 150;
      case 6: // Interests: min 3, max 8
        return interests.length >= 3 && interests.length <= 8;
      case 7: // Languages: min 1
        return languages.isNotEmpty;
      case 8: // Location: City & State required
        return city.trim().isNotEmpty;
      case 9: // Permissions: Informational / configurable
        return true;
      case 10: // All set summary
        return true;
      default:
        return false;
    }
  }

  UserProfile copyWith({
    String? name,
    DateTime? dob,
    String? gender,
    String? photoUrl,
    List<String>? galleryPhotos,
    String? bio,
    List<String>? interests,
    List<String>? languages,
    String? city,
    String? state,
    String? country,
    String? lookingFor,
    String? height,
    String? job,
    String? education,
    String? instagram,
    double? rating,
    int? reviewCount,
    List<Map<String, String>>? prompts,
    bool? isVerified,
    bool? hideOnlineStatus,
    bool? hideDistance,
    List<String>? blockedUsers,
    String? appLanguage,
    bool? notificationsEnabled,
    bool? cameraEnabled,
    bool? microphoneEnabled,
    bool? profileCompleted,
    int? currentStep,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      galleryPhotos: galleryPhotos ?? this.galleryPhotos,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      lookingFor: lookingFor ?? this.lookingFor,
      height: height ?? this.height,
      job: job ?? this.job,
      education: education ?? this.education,
      instagram: instagram ?? this.instagram,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      prompts: prompts ?? this.prompts,
      isVerified: isVerified ?? this.isVerified,
      hideOnlineStatus: hideOnlineStatus ?? this.hideOnlineStatus,
      hideDistance: hideDistance ?? this.hideDistance,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      appLanguage: appLanguage ?? this.appLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'photoUrl': photoUrl,
      'galleryPhotos': galleryPhotos,
      'bio': bio,
      'interests': interests,
      'languages': languages,
      'city': city,
      'state': state,
      'country': country,
      'lookingFor': lookingFor,
      'height': height,
      'job': job,
      'education': education,
      'instagram': instagram,
      'rating': rating,
      'reviewCount': reviewCount,
      'prompts': prompts,
      'isVerified': isVerified,
      'hideOnlineStatus': hideOnlineStatus,
      'hideDistance': hideDistance,
      'blockedUsers': blockedUsers,
      'appLanguage': appLanguage,
      'notificationsEnabled': notificationsEnabled,
      'cameraEnabled': cameraEnabled,
      'microphoneEnabled': microphoneEnabled,
      'profileCompleted': profileCompleted,
      'currentStep': currentStep,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      gender: map['gender'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      galleryPhotos: List<String>.from(map['galleryPhotos'] as List? ?? [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=600&q=80',
      ]),
      bio: map['bio'] as String? ?? '',
      interests: List<String>.from(map['interests'] as List? ?? []),
      languages: List<String>.from(map['languages'] as List? ?? []),
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? 'India',
      lookingFor: map['lookingFor'] as String? ?? 'Dating & Chat',
      height: map['height'] as String? ?? '5\' 10" (178 cm)',
      job: map['job'] as String? ?? 'UI/UX Designer',
      education: map['education'] as String? ?? 'B.Tech, Anna University',
      instagram: map['instagram'] as String? ?? 'pradeep.design',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: map['reviewCount'] as int? ?? 18,
      prompts: (map['prompts'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [
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
          ],
      isVerified: map['isVerified'] as bool? ?? true,
      hideOnlineStatus: map['hideOnlineStatus'] as bool? ?? false,
      hideDistance: map['hideDistance'] as bool? ?? false,
      blockedUsers: List<String>.from(map['blockedUsers'] as List? ?? []),
      appLanguage: map['appLanguage'] as String? ?? 'English',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      cameraEnabled: map['cameraEnabled'] as bool? ?? true,
      microphoneEnabled: map['microphoneEnabled'] as bool? ?? true,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      currentStep: map['currentStep'] as int? ?? 1,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
