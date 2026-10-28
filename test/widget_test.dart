import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:version1/main.dart';
import 'package:version1/screens/email_signup_screen.dart';
import 'package:version1/screens/home_screen.dart';
import 'package:version1/screens/login_screen.dart';
import 'package:version1/screens/phone_auth_screen.dart';
import 'package:version1/screens/signup_screen.dart';
import 'package:version1/screens/splash_screen.dart';
import 'package:version1/screens/welcome_screen.dart';
import 'package:version1/models/user_profile_model.dart';
import 'package:version1/services/app_state.dart';

void main() {
  testWidgets('Splash screen loads properly', (WidgetTester tester) async {
    await tester.pumpWidget(const LinkUpApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Welcome screen renders properly and has Get Started and Sign In buttons',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);
  });

  testWidgets(
      'Navigating from WelcomeScreen to SignUpScreen when Get Started tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Tap Get Started
    await tester.tap(find.byKey(const ValueKey('get_started_btn')));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Use Email Address'), findsOneWidget);
    expect(find.text('Use Mobile Number'), findsOneWidget);

    // Tap Use Email Address to open the email form
    await tester.tap(find.text('Use Email Address'));
    await tester.pumpAndSettle();

    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets(
      'Navigating from WelcomeScreen to LoginScreen when Already have an account tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Tap "Already have an account? Sign In"
    await tester.tap(find.byKey(const ValueKey('welcome_signin_btn')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget);
    expect(find.textContaining('back'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets(
      'SignUpScreen has Google button and navigates to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );

    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // Tap "Already have an account? Sign In" on SignUpScreen
    await tester.tap(find.byKey(const ValueKey('signup_signin_btn')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });



  testWidgets(
      'Navigating from SignUpScreen to PhoneAuthScreen when Use Mobile Number tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );

    // Tap "Use Mobile Number" on SignUpScreen
    await tester.tap(find.text('Use Mobile Number'));
    await tester.pumpAndSettle();

    expect(find.byType(PhoneAuthScreen), findsOneWidget);
    expect(find.textContaining('mobile number'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });



  testWidgets(
      'PhoneAuthScreen: Entering phone number, sending OTP, and navigating to verification code step',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: PhoneAuthScreen(),
      ),
    );

    // Initially Send OTP is disabled
    final sendOtpFinder = find.byKey(const ValueKey('send_otp_btn'));
    expect(sendOtpFinder, findsOneWidget);

    // Enter valid 10-digit Indian phone number
    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(sendOtpFinder);
    await tester.pump(); // Start sending
    await tester.pump(const Duration(seconds: 1)); // Delay completion
    await tester.pumpAndSettle();

    // Verification code step is now active!
    expect(find.textContaining('verification code'), findsOneWidget);
    expect(find.textContaining('+91 98765 43210'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
  });

  testWidgets('HomeScreen renders PRD-compliant header, wallet, creators and tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    AppState.instance.saveOnboardingDraft(
      const UserProfile(
        name: 'Pradeep',
        dob: null,
        gender: 'Male',
        photoUrl: 'https://example.com/avatar.jpg',
        bio: 'Hello',
        interests: ['Music', 'Travel', 'Fitness'],
        languages: ['English'],
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        currentStep: 10,
        profileCompleted: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Section 3: Header with Logo and Diamond Balance
    expect(find.text('Link'), findsOneWidget);
    expect(find.text('Up'), findsOneWidget);
    expect(find.byKey(const ValueKey('header_diamond_badge')), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

    // Section 4: Greeting
    expect(find.textContaining('Hey, Pradeep'), findsOneWidget);
    expect(find.textContaining('Discover your next connection'), findsOneWidget);

    // Section 8: Diamond Balance & Recharge Action
    expect(find.textContaining('Diamonds'), findsWidgets);
    expect(find.byKey(const ValueKey('recharge_diamonds_btn')), findsOneWidget);

    // Section 5: Creator Search
    expect(find.text('Search creators by name...'), findsOneWidget);

    // Section 6: Discover Creators Heading & Creator Cards
    expect(find.text('Discover Creators'), findsOneWidget);
    expect(find.textContaining('Aanya Sharma'), findsOneWidget);
    expect(find.textContaining('View Profile →'), findsWidgets);

    // Section 13: Bottom Navigation Bar
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Video Calls'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tapping Recharge opens Diamond Packages modal (200 to 700 Diamonds)',
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

    // Tap Recharge Diamonds
    await tester.tap(find.byKey(const ValueKey('recharge_diamonds_btn')));
    await tester.pumpAndSettle();

    // Verify packages
    expect(find.text('Recharge Diamonds'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);
    expect(find.text('500'), findsWidgets);
    expect(find.text('600'), findsOneWidget);
    expect(find.text('700'), findsOneWidget);
    expect(find.byKey(const ValueKey('continue_payment_btn')), findsOneWidget);
  });

  testWidgets('Tapping creator card opens Creator Profile Sheet with Video Call button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    AppState.instance.saveOnboardingDraft(
      const UserProfile(
        name: 'Pradeep',
        dob: null,
        gender: 'Male',
        photoUrl: 'https://example.com/avatar.jpg',
        bio: 'Hello',
        interests: ['Music', 'Travel', 'Fitness'],
        languages: ['English'],
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        currentStep: 10,
        profileCompleted: true,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Tap first creator card
    await tester.tap(find.textContaining('Aanya Sharma'));
    await tester.pumpAndSettle();

    // Verify creator profile details and connection options
    expect(find.text('Chat'), findsWidgets);
    expect(find.byKey(const ValueKey('video_call_btn')), findsOneWidget);
  });

  testWidgets(
      'Navigating from SignUpScreen to EmailSignUpScreen when Use Email Address tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );

    // Tap "Use Email Address"
    await tester.tap(find.text('Use Email Address'));
    await tester.pumpAndSettle();

    expect(find.byType(EmailSignUpScreen), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Create with mobile number'), findsOneWidget);

    // Tap Back button to return to SignUpScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets(
      'Navigating from EmailSignUpScreen to PhoneAuthScreen when Create with mobile number tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: EmailSignUpScreen(),
      ),
    );

    expect(find.byType(EmailSignUpScreen), findsOneWidget);

    // Tap "Create with mobile number"
    await tester.tap(find.byKey(const ValueKey('create_with_mobile_btn')));
    await tester.pumpAndSettle();

    expect(find.byType(PhoneAuthScreen), findsOneWidget);
    expect(find.textContaining('mobile number'), findsOneWidget);
  });
}



