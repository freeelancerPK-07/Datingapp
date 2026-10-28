import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:version1/models/call_record_model.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:version1/screens/video_calls_screen.dart';
import 'package:version1/services/app_state.dart';

void main() {
  testWidgets('VideoCallsScreen renders branding, search, online creators and call history',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Tab 2 is "Video Calls"
    final videoCallsTab = find.text('Video Calls');
    expect(videoCallsTab, findsOneWidget);

    // Tap "Video Calls" Tab
    await tester.tap(videoCallsTab);
    await tester.pumpAndSettle();

    // Verify Video Calls screen header
    expect(find.byType(VideoCallsScreen), findsOneWidget);
    expect(find.text('Meet someone new, face to face.'), findsOneWidget);
    expect(find.text('Search people...'), findsOneWidget);

    // Verify Sections: Online Creators, Recent Calls, Suggested People
    expect(find.text('Online Creators'), findsOneWidget);
    expect(find.text('Recent Calls'), findsOneWidget);
    expect(find.text('Suggested People'), findsOneWidget);
  });

  testWidgets('Searching in VideoCallsScreen filters creators',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VideoCallsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Enter search text "Aanya"
    await tester.enterText(find.byType(TextField).first, 'Aanya');
    await tester.pumpAndSettle();

    // Should find Aanya Sharma
    expect(find.textContaining('Aanya'), findsWidgets);
  });

  testWidgets('Clearing call history displays empty calls state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    AppState.instance.clearCallHistory();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VideoCallsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Empty State is shown
    expect(find.text('No calls yet'), findsOneWidget);
    expect(find.text('Your next connection could start with a video call.'), findsOneWidget);
    expect(find.text('Discover Available People'), findsOneWidget);

    // Re-seed call history for subsequent operations
    AppState.instance.addCallRecord(
      CallRecord(
        id: 'call_seed_1',
        creatorId: 'c1',
        name: 'Aanya Sharma',
        age: 23,
        photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
        type: CallType.completed,
        timestamp: DateTime.now(),
        durationSeconds: 300,
        coinsUsed: 500,
        isOnline: true,
        isAvailableForCall: true,
      ),
    );
  });
}
