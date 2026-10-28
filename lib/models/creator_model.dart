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
}
