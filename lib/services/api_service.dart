import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/creator_model.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();

  /// Returns appropriate base URL based on platform
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 reaches the host PC from Android Emulator
        return 'http://10.0.2.2:5000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:5000/api/v1';
  }

  // ---------------------------------------------------------------------------
  // 1. Creators API
  // ---------------------------------------------------------------------------
  Future<List<CreatorModel>> fetchCreators() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/creators')).timeout(
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
  // 2. Auth API (Phone OTP)
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
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[ApiService] Verify OTP error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Wallet & Recharge API (Simulated Instant Top-up)
  // ---------------------------------------------------------------------------
  Future<int?> fetchWalletBalance(String userId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/wallet/balance?userId=$userId'));
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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

  Future<Map<String, dynamic>> endCall({
    required String callId,
    required int durationSeconds,
    String reason = 'USER_HANGUP',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calls/$callId/end'),
        headers: {'Content-Type': 'application/json'},
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
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/creators/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'profession': profession,
          'videoCallPrice': videoCallPrice,
          'voiceCallPrice': voiceCallPrice,
          'photoPrice': photoPrice,
          'bio': bio,
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
        headers: {'Content-Type': 'application/json'},
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
}
