class CreatorModel {
  final String id;
  final String name;
  final int age;
  final String photoUrl;
  final bool isOnline;
  final bool isVerified;
  final bool isActive;
  final String bio;
  final int diamondsPerMin;
  final String location;
  final List<String> tags;
  final List<String> languages;
  final double rating;
  final int reviewCount;
  final String statusText;
  final String profession;
  final String followers;
  final String responseTime;
  final String tier; // Silver, Gold, Premium, VIP
  final int photoPrice;
  final int videoGreetingPrice;
  final int voiceCallPrice;
  final int videoCallPrice;

  const CreatorModel({
    required this.id,
    required this.name,
    required this.age,
    required this.photoUrl,
    this.isOnline = true,
    this.isVerified = true,
    this.isActive = true,
    this.bio = 'Fashion designer and visual storyteller. Living between art galleries, vintage boutiques, and rooftop coffee shops.',
    this.diamondsPerMin = 50,
    this.location = 'Bandra, Mumbai',
    this.tags = const ['Fashion', 'PastelAesthetic', 'Coffee', 'Art'],
    this.languages = const ['English', 'Tamil', 'Hindi'],
    this.rating = 4.9,
    this.reviewCount = 128,
    this.statusText = 'Online',
    this.profession = 'Fashion Designer',
    this.followers = '128K',
    this.responseTime = 'Under 5m',
    this.tier = 'VIP',
    this.photoPrice = 200,
    this.videoGreetingPrice = 400,
    this.voiceCallPrice = 300,
    this.videoCallPrice = 500,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Creator',
      age: json['age'] ?? 23,
      photoUrl: json['photoUrl'] ?? '',
      isOnline: json['isOnline'] ?? true,
      isVerified: json['isVerified'] ?? true,
      isActive: json['isActive'] ?? true,
      bio: json['bio'] ?? '',
      diamondsPerMin: json['diamondsPerMin'] ?? json['videoCallPrice'] ?? 50,
      location: json['location'] ?? 'Mumbai, India',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const ['Fashion', 'Lifestyle'],
      languages: json['languages'] != null ? List<String>.from(json['languages']) : const ['English', 'Hindi'],
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.9,
      reviewCount: json['reviewCount'] ?? 100,
      statusText: (json['isOnline'] == true) ? 'Online' : 'Offline',
      profession: json['profession'] ?? 'Creator',
      followers: json['followers'] ?? '100K',
      responseTime: json['responseTime'] ?? 'Under 5m',
      tier: json['tier'] ?? 'VIP',
      photoPrice: json['photoPrice'] ?? 200,
      videoGreetingPrice: json['videoGreetingPrice'] ?? 400,
      voiceCallPrice: json['voiceCallPrice'] ?? 300,
      videoCallPrice: json['videoCallPrice'] ?? 500,
    );
  }
}
