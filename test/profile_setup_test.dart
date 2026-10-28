import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:version1/models/user_profile_model.dart';
import 'package:version1/screens/profile_setup_screen.dart';
import 'package:version1/services/app_state.dart';

void main() {
  setUp(() {
    // Reset AppState profile before each test
    AppState.instance.saveOnboardingDraft(
      const UserProfile(
        name: '',
        dob: null,
        gender: '',
        photoUrl: '',
        bio: '',
        interests: [],
        languages: [],
        city: '',
        state: '',
        country: 'India',
        currentStep: 1,
      ),
    );
  });

  testWidgets('ProfileSetupScreen renders Step 1 (Name) and validates name input',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Step 1 Header & Elements
    expect(find.text("What's your name?"), findsOneWidget);
    expect(find.text("Let's start with your name."), findsOneWidget);
    expect(find.text('Step 1 of 10'), findsOneWidget);
    expect(find.text('Enter your first name'), findsOneWidget);

    // Continue is initially disabled when name is empty
    final continueFinder = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueFinder, findsOneWidget);
    final elevatedBtn = tester.widget<ElevatedButton>(continueFinder);
    expect(elevatedBtn.onPressed, isNull);

    // Enter valid name
    await tester.enterText(find.byType(TextField).first, 'Pradeep');
    await tester.pumpAndSettle();

    // Now Continue should be enabled
    final updatedBtn = tester.widget<ElevatedButton>(continueFinder);
    expect(updatedBtn.onPressed, isNotNull);

    // Tap Continue to navigate to Step 2
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    // Verify Step 2 is active
    expect(find.text("When's your birthday?"), findsOneWidget);
    expect(find.text('Step 2 of 10'), findsOneWidget);
  });

  testWidgets('UserProfile model correctly validates 18+ age requirement',
      (WidgetTester tester) async {
    final adultProfile = UserProfile(
      name: 'Karthik',
      dob: DateTime(2000, 5, 10),
    );
    expect(adultProfile.age, greaterThanOrEqualTo(18));
    expect(adultProfile.isAdult, isTrue);
    expect(adultProfile.isStepValid(2), isTrue);

    final minorProfile = UserProfile(
      name: 'Youngster',
      dob: DateTime(DateTime.now().year - 15, 1, 1),
    );
    expect(minorProfile.age, lessThan(18));
    expect(minorProfile.isAdult, isFalse);
    expect(minorProfile.isStepValid(2), isFalse);
  });

  testWidgets('UserProfile model correctly enforces interest count (3 to 8)',
      (WidgetTester tester) async {
    const emptyInterests = UserProfile(interests: []);
    expect(emptyInterests.isStepValid(6), isFalse);

    const twoInterests = UserProfile(interests: ['Music', 'Dance']);
    expect(twoInterests.isStepValid(6), isFalse);

    const validInterests = UserProfile(interests: ['Music', 'Travel', 'Fitness']);
    expect(validInterests.isStepValid(6), isTrue);

    const nineInterests = UserProfile(interests: [
      '1', '2', '3', '4', '5', '6', '7', '8', '9'
    ]);
    expect(nineInterests.isStepValid(6), isFalse);
  });

  testWidgets('ProfileSetupScreen Step 10 renders You are all set! summary card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Preset draft to step 10
    AppState.instance.saveOnboardingDraft(
      UserProfile(
        name: 'Pradeep',
        dob: DateTime(2003, 8, 15),
        gender: 'Male',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
        bio: 'Tech enthusiast',
        interests: const ['Music', 'Travel', 'Fitness'],
        languages: const ['Tamil', 'English'],
        city: 'Chennai',
        state: 'Tamil Nadu',
        currentStep: 10,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Step 10 UI
    expect(find.text("You're all set!"), findsOneWidget);
    expect(find.text("Here's a quick look at your profile."), findsOneWidget);
    expect(find.text('Step 10 of 10'), findsOneWidget);
    expect(find.text('Pradeep'), findsOneWidget);
    expect(find.textContaining('Chennai, Tamil Nadu'), findsOneWidget);
    expect(find.text('Continue to Home'), findsOneWidget);
  });
}
