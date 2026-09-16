class UserProfileModel {
  final String id;
  final int? mysqlId;
  final String name;
  final String? avatarPath;
  final List<String> galleryPaths;
  final DateTime? dateOfBirth;
  final int age;
  final String gender;
  final String bio;
  final String country;
  final String city;
  final List<String> languages;
  final List<String> interests;
  final bool isProfileCompleted;

  const UserProfileModel({
    required this.id,
    this.mysqlId,
    required this.name,
    this.avatarPath,
    this.galleryPaths = const [],
    this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.bio,
    required this.country,
    this.city = '',
    this.languages = const [],
    this.interests = const [],
    this.isProfileCompleted = false,
  });

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  UserProfileModel copyWith({
    String? id,
    int? mysqlId,
    String? name,
    String? avatarPath,
    List<String>? galleryPaths,
    DateTime? dateOfBirth,
    int? age,
    String? gender,
    String? bio,
    String? country,
    String? city,
    List<String>? languages,
    List<String>? interests,
    bool? isProfileCompleted,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      mysqlId: mysqlId ?? this.mysqlId,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      galleryPaths: galleryPaths ?? this.galleryPaths,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mysqlId': mysqlId,
      'name': name,
      'avatarPath': avatarPath,
      'galleryPaths': galleryPaths,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'gender': gender,
      'bio': bio,
      'country': country,
      'city': city,
      'languages': languages,
      'interests': interests,
      'isProfileCompleted': isProfileCompleted,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    if (json['dateOfBirth'] != null) {
      dob = DateTime.tryParse(json['dateOfBirth'] as String);
    }

    return UserProfileModel(
      id: json['id'] as String? ?? '',
      mysqlId: json['mysqlId'] as int?,
      name: json['name'] as String? ?? '',
      avatarPath: json['avatarPath'] as String?,
      galleryPaths: (json['galleryPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dateOfBirth: dob,
      age: (json['age'] as num?)?.toInt() ?? (dob != null ? calculateAge(dob) : 0),
      gender: json['gender'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
    );
  }

  static UserProfileModel defaultProfile() {
    return const UserProfileModel(
      id: 'default_user',
      mysqlId: null,
      name: 'Alex Morgan',
      avatarPath: null,
      galleryPaths: [],
      dateOfBirth: null,
      age: 24,
      gender: 'Woman',
      bio: 'Design enthusiast, coffee explorer, and weekend photographer.',
      country: 'India',
      city: 'Mumbai',
      languages: ['English', 'Tamil'],
      interests: ['Coffee Lover', 'Visual Arts', 'Travel & Road Trips', 'Indie Pop', 'Photography'],
      isProfileCompleted: false,
    );
  }
}
