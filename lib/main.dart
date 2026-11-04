import 'package:flutter/material.dart';
import 'package:version1/screens/splash_screen.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/services/navigation_service.dart';
import 'package:version1/widgets/incoming_call_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LinkUpApp());
}

class LinkUpApp extends StatelessWidget {
  const LinkUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'LinkUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007A78),
          primary: const Color(0xFF007A78),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final incoming = AppState.instance.incomingCall;
            return Stack(
              children: [
                ?child,
                if (incoming != null)
                  const Positioned.fill(
                    child: IncomingCallOverlay(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
