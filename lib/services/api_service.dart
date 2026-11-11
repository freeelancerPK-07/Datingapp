import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/creator_model.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();

  String _resolvedBaseUrl = productionUrl;
  String? _authToken;

  String? get authToken => _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('[ApiService] Auth token updated: ${_authToken != null && _authToken!.length > 10 ? _authToken!.substring(0, 10) : ''}...');
  }

  void clearAuthToken() {
    _authToken = null;
    debugPrint('[ApiService] Auth token cleared.');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null && _authToken!.isNotEmpty) 'Authorization': 'Bearer $_authToken',
  };

  static const String productionUrl = 'https://linkup-jwzs.onrender.com/api/v1';

  /// Returns appropriate base URL based on platform & connectivity
  String get baseUrl {
    if (_resolvedBaseUrl.isNotEmpty) return _resolvedBaseUrl;
    return productionUrl;
  }

  /// Automatically probes backend on app startup (Release APK always uses Production Cloud)
  Future<void> probeBackendUrl() async {
    if (kReleaseMode) {
      _resolvedBaseUrl = productionUrl;
      debugPrint('[ApiService] Release build locked to production: $productionUrl');
      return;
    }
    final candidates = [
      productionUrl,                      // Live Production Cloud Backend (Render)
      'http://10.186.14.158:5000/api/v1', // Physical phone on Wi-Fi (Host PC IP)
      'http://localhost:5000/api/v1',     // Physical phone via adb reverse
      'http://10.0.2.2:5000/api/v1',      // Android Emulator
    ];
    for (final url in candidates) {
      try {
        final res = await http.get(Uri.parse('$url/creators')).timeout(const Duration(milliseconds: 5000));
        if (res.statusCode == 200) {
          _resolvedBaseUrl = url;
          debugPrint('[ApiService] Connected to backend at: $url');
          return;
        }
      } catch (_) {}
    }
    _resolvedBaseUrl = productionUrl;
  }

  // ---------------------------------------------------------------------------
  // 1. Creators API
  // ---------------------------------------------------------------------------
  Future<List<CreatorModel>> fetchCreators() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/creators'), headers: _headers).timeout(
            const Duration(seconds: 4),
          );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((c) => CreatorModel.fromJson(c)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] Failed to fetch creators from backend: $e');
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // 2. Auth API (Phone OTP & Email Auth)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> sendPhoneOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/phone/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Send OTP error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyPhoneOtp(String phone, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/phone/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['token'] != null) {
        setAuthToken(data['token'].toString());
      }
      return data;
    } catch (e) {
      debugPrint('[ApiService] Verify OTP error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final payload = <String, dynamic>{
        'email': email,
        'password': password,
      };
      if (name != null && name.isNotEmpty) payload['name'] = name;
      if (phone != null && phone.isNotEmpty) payload['phone'] = phone;

      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['token'] != null) {
        setAuthToken(data['token'].toString());
      }
      return data;
    } catch (e) {
      debugPrint('[ApiService] Register error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['token'] != null) {
        setAuthToken(data['token'].toString());
      }
      return data;
    } catch (e) {
      debugPrint('[ApiService] Login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> syncFirebaseUser({
    required String email,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/firebase-sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
          if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['token'] != null) {
        setAuthToken(data['token'].toString());
      }
      return data;
    } catch (e) {
      debugPrint('[ApiService] Firebase sync error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMe({String? userId}) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/me${userId != null ? '?userId=$userId' : ''}');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'error': 'Status ${res.statusCode}'};
    } catch (e) {
      debugPrint('[ApiService] getMe error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Wallet & Recharge API (Simulated Instant Top-up)
  // ---------------------------------------------------------------------------
  Future<int?> fetchWalletBalance(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/wallet/balance?userId=$userId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['balance'] as int?;
      }
    } catch (e) {
      debugPrint('[ApiService] Fetch balance error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> rechargeWallet({
    required String userId,
    required int coins,
    required double amountInr,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/wallet/recharge'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'coins': coins,
          'amountInr': amountInr,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Recharge error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Calling API
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> initiateCall({
    required String callerId,
    required String creatorId,
    String callType = 'VIDEO',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calls/initiate'),
        headers: _headers,
        body: jsonEncode({
          'callerId': callerId,
          'creatorId': creatorId,
          'callType': callType,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Initiate call error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkIncomingCall({String? userId, String? creatorId}) async {
    try {
      final query = userId != null ? 'userId=$userId' : 'creatorId=$creatorId';
      final res = await http.get(
        Uri.parse('$baseUrl/calls/incoming?$query'),
        headers: _headers,
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Check incoming call error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCallStatus(String callId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/calls/$callId/status'),
        headers: _headers,
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Get call status error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptCall(String callId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calls/$callId/accept'),
        headers: _headers,
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Accept call error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rejectCall(String callId, {String reason = 'CREATOR_DECLINED'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calls/$callId/reject'),
        headers: _headers,
        body: jsonEncode({'reason': reason}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Reject call error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> endCall({
    required String callId,
    required int durationSeconds,
    String reason = 'USER_HANGUP',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calls/$callId/end'),
        headers: _headers,
        body: jsonEncode({
          'durationSeconds': durationSeconds,
          'endReason': reason,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] End call error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> getIceServers() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/calls/ice-servers'), headers: _headers)
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] getIceServers error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getAgoraCallCredentials(String callId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/calls/$callId/agora-credentials'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[ApiService] getAgoraCallCredentials error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Profile Sync & Creator Registration
  // ---------------------------------------------------------------------------
  Future<bool> registerAsCreator({
    required String userId,
    required String profession,
    required int videoCallPrice,
    int voiceCallPrice = 300,
    int photoPrice = 200,
    String? bio,
    List<String>? tags,
    List<String>? languages,
    String tier = 'VIP',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/creators/register'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'profession': profession,
          'videoCallPrice': videoCallPrice,
          'voiceCallPrice': voiceCallPrice,
          'photoPrice': photoPrice,
          'bio': bio,
          'tags': tags ?? ['Creator', 'Lifestyle'],
          'languages': languages ?? ['English', 'Tamil'],
          'tier': tier,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Register creator error: $e');
      return false;
    }
  }

  Future<bool> syncProfileOnboarding(String userId, Map<String, dynamic> profileData) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/profile/onboarding'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          ...profileData,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Sync profile error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> applyForCreator({
    required String userId,
    required String legalName,
    required int age,
    required String profession,
    required int videoCallPrice,
    int voiceCallPrice = 300,
    String? bio,
    String? photoUrl,
    List<String>? galleryPhotos,
    String govtIdType = 'Aadhaar Card',
    String? socialHandle,
    String? payoutUpiId,
    List<String>? tags,
    List<String>? languages,
    String subscriptionPlan = 'MONTHLY_299',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/creators/apply'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'legalName': legalName,
          'age': age,
          'profession': profession,
          'videoCallPrice': videoCallPrice,
          'voiceCallPrice': voiceCallPrice,
          'bio': bio,
          'photoUrl': photoUrl,
          'galleryPhotos': galleryPhotos ?? [],
          'govtIdType': govtIdType,
          'socialHandle': socialHandle,
          'payoutUpiId': payoutUpiId,
          'tags': tags ?? ['Lifestyle', 'Creator'],
          'languages': languages ?? ['English', 'Tamil'],
          'subscriptionPlan': subscriptionPlan,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Apply creator error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCreatorApplicationStatus(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/creators/application-status?userId=$userId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'error': 'Status ${res.statusCode}'};
    } catch (e) {
      debugPrint('[ApiService] Get application status error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> toggleCreatorOnlineStatus(String userId, bool isOnline) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/creators/toggle-online'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'isOnline': isOnline,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Toggle online error: $e');
      return false;
    }
  }

  Future<bool> updateCreatorRates({
    required String userId,
    int? videoCallPrice,
    int? voiceCallPrice,
    int? photoPrice,
  }) async {
    try {
      final Map<String, dynamic> body = {'userId': userId};
      if (videoCallPrice != null) body['videoCallPrice'] = videoCallPrice;
      if (voiceCallPrice != null) body['voiceCallPrice'] = voiceCallPrice;
      if (photoPrice != null) body['photoPrice'] = photoPrice;

      final res = await http.put(
        Uri.parse('$baseUrl/creators/rates'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Update rates error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchCreatorStudioStats(String userId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/creators/studio-stats?userId=$userId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'error': 'Status ${res.statusCode}'};
    } catch (e) {
      debugPrint('[ApiService] Fetch studio stats error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Permanently deletes user account and all associated data from PostgreSQL database
  Future<bool> deleteAccount(String userId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/profile/delete-account'),
        headers: _headers,
        body: jsonEncode({'userId': userId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] Delete account error: $e');
      return false;
    }
  }

  /// Uploads a local image file to backend server and returns the accessible URL
  Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('[ApiService] File does not exist at $filePath');
        return null;
      }
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final filename = filePath.split(Platform.pathSeparator).last;

      final res = await http.post(
        Uri.parse('$baseUrl/upload/image'),
        headers: _headers,
        body: jsonEncode({
          'image': base64Image,
          'filename': filename,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final serverUrl = data['url'] as String?;
          final relativeUrl = data['relativeUrl'] as String?;
          if (serverUrl != null && serverUrl.startsWith('http')) {
            return serverUrl;
          }
          final rootBase = baseUrl.replaceAll('/api/v1', '');
          return '$rootBase$relativeUrl';
        }
      }
      debugPrint('[ApiService] Upload failed with status: ${res.statusCode} ${res.body}');
      return null;
    } catch (e) {
      debugPrint('[ApiService] Upload image error: $e');
      return null;
    }
  }
}
