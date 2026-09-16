import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    return 'http://10.0.2.2:3000/api';
  }

  static Future<UserProfileModel?> createUser(UserProfileModel profile) async {
    try {
      final userData = {
        'username': profile.name,
        'date_of_birth': profile.dateOfBirth?.toIso8601String().split('T')[0],
        'gender': _mapGender(profile.gender),
        'country': profile.country,
        'city': profile.city,
        'language_spoken': profile.languages,
        'bio': profile.bio,
        'interests_passions': profile.interests,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        debugPrint('User created in MySQL: ${response.body}');
        final responseData = jsonDecode(response.body);
        return profile.copyWith(mysqlId: responseData['id'] as int);
      } else {
        debugPrint('Failed to create user: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('API Error creating user: $e');
      return null;
    }
  }

  static Future<bool> updateUser(String userId, UserProfileModel profile) async {
    try {
      final userData = {
        'username': profile.name,
        'date_of_birth': profile.dateOfBirth?.toIso8601String().split('T')[0],
        'gender': _mapGender(profile.gender),
        'country': profile.country,
        'city': profile.city,
        'language_spoken': profile.languages,
        'bio': profile.bio,
        'interests_passions': profile.interests,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        debugPrint('User updated in MySQL: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to update user: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('API Error updating user: $e');
      return false;
    }
  }

  static String _mapGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'woman':
        return 'female';
      case 'man':
        return 'male';
      case 'non-binary':
        return 'other';
      case 'prefer not to say':
        return 'prefer_not_to_say';
      default:
        return 'prefer_not_to_say';
    }
  }
}