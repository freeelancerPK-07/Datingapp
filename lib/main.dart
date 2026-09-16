import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/user_profile_service.dart';
import 'core/services/wallet_service.dart';
import 'core/services/socket_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }
  try {
    await UserProfileService.instance.init();
  } catch (e) {
    debugPrint('UserProfileService init: $e');
  }
  try {
    await WalletService.instance.init();
  } catch (e) {
    debugPrint('WalletService init: $e');
  }
  try {
    const String socketUrl = 'http://localhost:3000';
    final mysqlId = UserProfileService.instance.profile.mysqlId;
    final firebaseUid = UserProfileService.instance.profile.id;
    debugPrint('=== Socket Debug ===');
    debugPrint('Firebase UID: $firebaseUid');
    debugPrint('MySQL user ID: $mysqlId');
    debugPrint('Socket URL: $socketUrl');
    debugPrint('====================');
    SocketService().connect(socketUrl, userId: mysqlId);
    if (mysqlId != null) {
      debugPrint('Socket connecting with MySQL user ID: $mysqlId');
    }
  } catch (e) {
    debugPrint('SocketService init: $e');
  }
  runApp(const TryloApp());
}

class TryloApp extends StatelessWidget {
  const TryloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trylo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
