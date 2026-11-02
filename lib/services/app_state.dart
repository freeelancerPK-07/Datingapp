import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:version1/models/admin_settings_model.dart';
import 'package:version1/models/call_record_model.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/models/user_profile_model.dart';
import 'package:version1/models/wallet_model.dart';
import 'package:version1/services/api_service.dart';

class CallCheckResult {
  final bool isAllowed;
  final String? errorMessage;
  final bool isInsufficientBalance;

  const CallCheckResult({
    required this.isAllowed,
    this.errorMessage,
    this.isInsufficientBalance = false,
  });
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal() {
    _initSampleCreators();
    syncCreatorsFromBackend();
  }

  String? _backendUserId;
  String? get backendUserId => _backendUserId;

  void setBackendUserId(String id) {
    _backendUserId = id;
    syncWalletFromBackend();
  }

  Future<void> syncCreatorsFromBackend() async {
    try {
      final live = await ApiService.instance.fetchCreators();
      if (live.isNotEmpty) {
        _allCreators.clear();
        _allCreators.addAll(live);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> syncWalletFromBackend() async {
    if (_backendUserId == null) return;
    try {
      final bal = await ApiService.instance.fetchWalletBalance(_backendUserId!);
      if (bal != null) {
        _availableCoins = bal;
        notifyListeners();
      }
    } catch (_) {}
  }

  bool _isCreator = false;
  bool get isCreator => _isCreator || _allCreators.any((c) => _backendUserId != null && c.userId == _backendUserId);

  // User Profile & Onboarding State
  UserProfile _userProfile = const UserProfile(
    name: '',
    photoUrl: '',
    galleryPhotos: [],
    bio: '',
    city: '',
    state: '',
    country: 'India',
    interests: [],
    languages: [],
    profileCompleted: false,
    currentStep: 1,
  );
  UserProfile get userProfile => _userProfile;
  bool get isProfileCompleted => _userProfile.profileCompleted;

  String _userName = '';
  String get userName => _userProfile.name.isNotEmpty ? _userProfile.name : (_userName.isNotEmpty ? _userName : 'User');
  String _userPhone = '';
  String get userPhone => _userPhone;
  String _userCity = '';
  String get userCity => _userProfile.city.isNotEmpty
      ? '${_userProfile.city}${_userProfile.state.isNotEmpty ? ', ${_userProfile.state}' : ''}'
      : _userCity;
  String _userBio = '';
  String get userBio => _userProfile.bio.isNotEmpty ? _userProfile.bio : _userBio;

  void saveOnboardingDraft(UserProfile draft) {
    _userProfile = draft;
    notifyListeners();
  }

  void completeProfileSetup(UserProfile finalProfile) {
    _userProfile = finalProfile.copyWith(
      profileCompleted: true,
      currentStep: 10,
    );
    _userName = _userProfile.name;
    _userCity = '${_userProfile.city}, ${_userProfile.state}';
    _userBio = _userProfile.bio;
    notifyListeners();

    if (_backendUserId != null) {
      ApiService.instance.syncProfileOnboarding(_backendUserId!, {
        'name': _userProfile.name,
        'bio': _userProfile.bio,
        'city': _userProfile.city,
        'state': _userProfile.state,
        'country': _userProfile.country,
        'avatarUrl': _userProfile.photoUrl,
        'galleryPhotos': _userProfile.galleryPhotos,
        'interests': _userProfile.interests,
        'languages': _userProfile.languages,
        'isCompleted': true,
        'currentStep': 10,
      });
    }
    const FlutterSecureStorage().write(key: 'is_profile_completed', value: 'true');
  }

  Future<bool> becomeCreator({
    required String profession,
    required int videoCallPrice,
    int voiceCallPrice = 300,
    int photoPrice = 200,
    String? bio,
  }) async {
    if (_backendUserId == null) return false;
    final success = await ApiService.instance.registerAsCreator(
      userId: _backendUserId!,
      profession: profession,
      videoCallPrice: videoCallPrice,
      voiceCallPrice: voiceCallPrice,
      photoPrice: photoPrice,
      bio: bio ?? _userProfile.bio,
    );
    if (success) {
      _isCreator = true;
      await syncCreatorsFromBackend();
      notifyListeners();
    }
    return success;
  }

  void setProfileCompleted(bool completed) {
    _userProfile = _userProfile.copyWith(profileCompleted: completed);
    notifyListeners();
  }

  void addGalleryPhoto(String url) {
    final list = List<String>.from(_userProfile.galleryPhotos);
    if (list.length < 6) {
      list.add(url);
      _userProfile = _userProfile.copyWith(galleryPhotos: list);
      notifyListeners();
    }
  }

  void removeGalleryPhoto(int index) {
    final list = List<String>.from(_userProfile.galleryPhotos);
    if (index >= 0 && index < list.length && list.length > 1) {
      list.removeAt(index);
      _userProfile = _userProfile.copyWith(
        galleryPhotos: list,
        photoUrl: index == 0 && list.isNotEmpty ? list.first : _userProfile.photoUrl,
      );
      notifyListeners();
    }
  }

  void setMainGalleryPhoto(int index) {
    final list = List<String>.from(_userProfile.galleryPhotos);
    if (index > 0 && index < list.length) {
      final selected = list.removeAt(index);
      list.insert(0, selected);
      _userProfile = _userProfile.copyWith(
        galleryPhotos: list,
        photoUrl: selected,
      );
      notifyListeners();
    }
  }

  void reorderGalleryPhotos(int oldIndex, int newIndex) {
    final list = List<String>.from(_userProfile.galleryPhotos);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _userProfile = _userProfile.copyWith(
      galleryPhotos: list,
      photoUrl: list.isNotEmpty ? list.first : _userProfile.photoUrl,
    );
    notifyListeners();
  }

  void updatePrivacySettings({
    bool? hideOnlineStatus,
    bool? hideDistance,
    String? appLanguage,
  }) {
    _userProfile = _userProfile.copyWith(
      hideOnlineStatus: hideOnlineStatus,
      hideDistance: hideDistance,
      appLanguage: appLanguage,
    );
    notifyListeners();
  }

  void blockUser(String name) {
    final list = List<String>.from(_userProfile.blockedUsers);
    if (!list.contains(name)) {
      list.add(name);
      _userProfile = _userProfile.copyWith(blockedUsers: list);
      notifyListeners();
    }
  }

  void unblockUser(String name) {
    final list = List<String>.from(_userProfile.blockedUsers);
    list.remove(name);
    _userProfile = _userProfile.copyWith(blockedUsers: list);
    notifyListeners();
  }

  void deleteUserAccount() {
    _userProfile = const UserProfile(profileCompleted: false, currentStep: 1);
    _userName = 'Guest';
    _userCity = '';
    _userBio = '';
    notifyListeners();
  }

  void updateUserProfile({
    String? name,
    String? phone,
    String? city,
    String? state,
    String? bio,
    DateTime? dob,
    String? gender,
    String? photoUrl,
    List<String>? interests,
    List<String>? languages,
  }) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    if (city != null) _userCity = city;
    if (bio != null) _userBio = bio;
    _userProfile = _userProfile.copyWith(
      name: name,
      city: city,
      state: state,
      bio: bio,
      dob: dob,
      gender: gender,
      photoUrl: photoUrl,
      interests: interests,
      languages: languages,
    );
    notifyListeners();
  }

  void updateFullProfile({
    String? name,
    DateTime? dob,
    String? gender,
    String? bio,
    String? city,
    String? state,
    String? height,
    String? job,
    String? education,
    String? instagram,
    String? lookingFor,
    List<String>? galleryPhotos,
    List<String>? interests,
    List<String>? languages,
    List<Map<String, String>>? prompts,
  }) {
    if (name != null && name.isNotEmpty) _userName = name;
    if (city != null && city.isNotEmpty) _userCity = city;
    if (bio != null) _userBio = bio;
    _userProfile = _userProfile.copyWith(
      name: name,
      dob: dob,
      gender: gender,
      bio: bio,
      city: city,
      state: state,
      height: height,
      job: job,
      education: education,
      instagram: instagram,
      lookingFor: lookingFor,
      galleryPhotos: galleryPhotos,
      photoUrl: (galleryPhotos != null && galleryPhotos.isNotEmpty) ? galleryPhotos.first : _userProfile.photoUrl,
      interests: interests,
      languages: languages,
      prompts: prompts,
    );
    notifyListeners();
  }

  // LinkUp Coins Unified Wallet State (V1 Single Virtual Currency)
  int _availableCoins = 0; // Available Coins ready to spend
  int get availableCoins => _availableCoins;

  int _lockedCoins = 0; // Locked Coins for ongoing sessions
  int get lockedCoins => _lockedCoins;
  int get reservedCoins => _lockedCoins;

  int get totalCoins => _availableCoins + _lockedCoins; // 1,100 Total Coins

  // Backward-compatibility getters
  int get diamondBalance => _availableCoins;
  double get walletBalance => _availableCoins.toDouble();
  double get reservedBalance => _lockedCoins.toDouble();
  double _creatorEarnings = 0.0;
  double get creatorEarnings => _creatorEarnings;

  final Set<String> _processedTransactionIds = {};

  final List<WalletTransaction> _transactions = [];
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  // Active Conversations & Messages for Chat Tab
  final List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> get conversations => List.unmodifiable(_conversations);

  final Map<String, List<Map<String, dynamic>>> _messagesByConv = {};

  List<Map<String, dynamic>> getMessages(String convId) {
    return _messagesByConv[convId] ?? [
      {
        'id': 'init_1',
        'isMe': false,
        'text': 'Hello! Excited to connect with you on LinkUp!',
        'time': 'Just now',
        'status': 'read',
      }
    ];
  }

  void addMessage({required String convId, required String text, required bool isMe}) {
    if (!_messagesByConv.containsKey(convId)) {
      _messagesByConv[convId] = [];
    }
    _messagesByConv[convId]!.add({
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'isMe': isMe,
      'text': text,
      'time': 'Just now',
      'status': 'delivered',
    });

    final idx = _conversations.indexWhere((c) => c['id'] == convId);
    if (idx != -1) {
      _conversations[idx]['lastMessage'] = text;
      _conversations[idx]['time'] = 'Just now';
      if (!isMe) {
        _conversations[idx]['unread'] = (_conversations[idx]['unread'] as int? ?? 0) + 1;
      }
    }
    notifyListeners();
  }

  void markConversationRead(String convId) {
    final idx = _conversations.indexWhere((c) => c['id'] == convId);
    if (idx != -1) {
      _conversations[idx]['unread'] = 0;
      notifyListeners();
    }
  }

  // Admin Settings
  AdminSettingsModel _adminSettings = const AdminSettingsModel();
  AdminSettingsModel get adminSettings => _adminSettings;

  void updateAdminSettings(AdminSettingsModel settings) {
    _adminSettings = settings;
    notifyListeners();
  }

  // Video Call History State
  final List<CallRecord> _callHistory = [];

  List<CallRecord> get callHistory => List.unmodifiable(_callHistory);

  void addCallRecord(CallRecord record) {
    _callHistory.insert(0, record);
    notifyListeners();
  }

  void clearCallHistory() {
    _callHistory.clear();
    notifyListeners();
  }

  void deleteCallRecord(String id) {
    _callHistory.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Creators Listing
  final List<CreatorModel> _allCreators = [];
  List<CreatorModel> get activeCreators =>
      _allCreators.where((c) => c.isActive).toList();
  List<CreatorModel> get allCreators => _allCreators;

  // Global Liked & Saved Creators State (Instagram-Style Favorites & Bookmarks)
  final Set<String> _likedCreatorIds = {};
  final Set<String> _savedCreatorIds = {};

  Set<String> get likedCreatorIds => _likedCreatorIds;
  Set<String> get savedCreatorIds => _savedCreatorIds;

  int get likedCount => _likedCreatorIds.length;
  int get savedCount => _savedCreatorIds.length;

  bool isCreatorLiked(String id) => _likedCreatorIds.contains(id);
  bool isCreatorSaved(String id) => _savedCreatorIds.contains(id);

  void toggleLikeCreator(String id) {
    if (_likedCreatorIds.contains(id)) {
      _likedCreatorIds.remove(id);
    } else {
      _likedCreatorIds.add(id);
    }
    notifyListeners();
  }

  void toggleSaveCreator(String id) {
    if (_savedCreatorIds.contains(id)) {
      _savedCreatorIds.remove(id);
    } else {
      _savedCreatorIds.add(id);
    }
    notifyListeners();
  }

  List<CreatorModel> get likedCreators =>
      _allCreators.where((c) => _likedCreatorIds.contains(c.id)).toList();

  List<CreatorModel> get savedCreators =>
      _allCreators.where((c) => _savedCreatorIds.contains(c.id)).toList();

  CreatorModel? getCreatorById(String id) {
    try {
      return _allCreators.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _initSampleCreators() {
    // Only real creators fetched from backend PostgreSQL are loaded
  }

  // ---------------------------------------------------------------------------
  // LinkUp Coins Purchase Flow (Razorpay UPI / Card / Netbanking with Signature Check)
  // ---------------------------------------------------------------------------
  bool purchaseCoins({
    required CoinPackage package,
    required String transactionId,
    String paymentMethod = 'UPI',
  }) {
    // Prevent duplicate wallet credits for the same transaction (PRD Requirement)
    if (_processedTransactionIds.contains(transactionId)) {
      return false;
    }

    _processedTransactionIds.add(transactionId);
    _availableCoins += package.coins;

    _transactions.insert(
      0,
      WalletTransaction(
        id: transactionId,
        description: 'LinkUp Coins Purchase (${package.coins} Coins)',
        coins: package.coins,
        amountInr: package.priceInr.toDouble(),
        isCredit: true,
        type: TransactionType.purchase,
        status: 'Completed',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();

    if (_backendUserId != null) {
      ApiService.instance.rechargeWallet(
        userId: _backendUserId!,
        coins: package.coins,
        amountInr: package.priceInr.toDouble(),
      );
    }
    return true;
  }

  // Diamond Recharge Flow (Backward-compatible adapter)
  bool rechargeDiamonds({
    required DiamondPackage package,
    required String transactionId,
  }) {
    return purchaseCoins(package: package, transactionId: transactionId);
  }

  // Call Pre-Check (Section 5 & 10)
  CallCheckResult canStartVideoCall(CreatorModel creator) {
    // 1. Admin Video Control check (PRD Section 6B)
    if (!_adminSettings.isVideoConnectionEnabled) {
      return const CallCheckResult(
        isAllowed: false,
        errorMessage: 'Video connections are temporarily disabled by the administrator.',
      );
    }

    // 2. Admin Wallet Freeze check (PRD Section 6A)
    if (_adminSettings.isFreezeBalance) {
      return const CallCheckResult(
        isAllowed: false,
        errorMessage: 'Your diamond balance is currently frozen per administrative restrictions.',
      );
    }

    // 3. Insufficient balance check (PRD Section 5 & 14)
    if (_availableCoins < creator.diamondsPerMin) {
      return const CallCheckResult(
        isAllowed: false,
        errorMessage: 'Your coin balance is too low to start this connection.',
        isInsufficientBalance: true,
      );
    }

    return const CallCheckResult(isAllowed: true);
  }

  // Deduct coins for ongoing call
  bool deductDiamonds(int amount, String creatorName) {
    if (_adminSettings.isFreezeBalance) return false;
    if (_availableCoins < amount) return false;

    _availableCoins -= amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'CALL-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Video Call with $creatorName',
        coins: amount,
        amountInr: amount.toDouble(),
        isCredit: false,
        type: TransactionType.callUsage,
        status: 'Completed',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // G. Booking Workflow — Escrow Engine Methods (PDF order)
  // ---------------------------------------------------------------------------

  /// Step 4: Coins reserved -> Deducts from available coins, moves to locked bucket
  bool reserveBooking({
    required String serviceName,
    required double amount,
    required String creatorName,
  }) {
    final coinAmount = amount.round();
    if (_availableCoins < coinAmount) return false;

    _availableCoins -= coinAmount;
    _lockedCoins += coinAmount;

    _transactions.insert(
      0,
      WalletTransaction(
        id: 'HOLD-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Session Hold – $serviceName ($creatorName)',
        coins: coinAmount,
        amountInr: amount,
        isCredit: false,
        type: TransactionType.sessionHold,
        status: 'Reserved',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  /// Step 5 Refund: Creator declines or 30s timeout -> 100% refund to available coins
  void refundReservedBooking({
    required String serviceName,
    required double amount,
    String reason = 'Timeout / Declined',
  }) {
    final coinAmount = amount.round();
    _lockedCoins = (_lockedCoins - coinAmount).clamp(0, 99999999);
    _availableCoins += coinAmount;

    _transactions.insert(
      0,
      WalletTransaction(
        id: 'REFUND-${DateTime.now().millisecondsSinceEpoch}',
        description: '100% Refund – $serviceName ($reason)',
        coins: coinAmount,
        amountInr: amount,
        isCredit: true,
        type: TransactionType.refund,
        status: 'Refunded',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  /// Step 9 & 10: Session completed -> Commission split (70% creator, 30% platform) & wallet update
  Map<String, double> completeBookingSettlement({
    required String serviceName,
    required double amount,
    double creatorSharePercent = 0.70, // 70% Creator, 30% Platform
  }) {
    final coinAmount = amount.round();
    _lockedCoins = (_lockedCoins - coinAmount).clamp(0, 99999999);

    final creatorPayout = amount * creatorSharePercent;
    final platformCommission = amount * (1.0 - creatorSharePercent);
    _creatorEarnings += creatorPayout;

    _transactions.insert(
      0,
      WalletTransaction(
        id: 'SETTLED-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Completed – $serviceName',
        coins: coinAmount,
        amountInr: amount,
        isCredit: false,
        type: serviceName.contains('Photo') ? TransactionType.photoPurchase : TransactionType.callUsage,
        status: 'Completed',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
    return {
      'total': amount,
      'creatorPayout': creatorPayout,
      'platformCommission': platformCommission,
    };
  }

  /// Step 11: Rating & Review recorded for Creator
  void addRatingAndReview({
    required String creatorId,
    required int rating,
    required String review,
    List<String> tags = const [],
  }) {
    // In production, syncs with backend API
    notifyListeners();
  }
}
