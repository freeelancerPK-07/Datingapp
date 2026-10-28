import 'package:flutter/material.dart';
import 'package:version1/constants/svg_assets.dart';

/// 100% Pure Dart Vector Canvas Painter for Create Account (SignUp) Screen
/// Exactly matching the reference image:
/// - Top-Left: Soft organic pink blob with 3 delicate radiating pink rays
/// - Bottom-Left: Cyan wave curve with sunny yellow organic curve over it
/// - Bottom-Right: Layered pastel pink and vibrant hot pink wave with 2 floating pink droplets
class SignUpBackgroundPainter extends CustomPainter {
  const SignUpBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ==========================================
    // 1. TOP-LEFT ORGANIC PINK BLOBS
    // ==========================================
    // (a) Outer soft pastel pink blob
    final outerTopPaint = Paint()
      ..color = const Color(0xFFFFB8D8)
      ..style = PaintingStyle.fill;

    final outerTopPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.36, 0)
      ..cubicTo(
        w * 0.35, h * 0.04,
        w * 0.28, h * 0.075,
        w * 0.18, h * 0.09,
      )
      ..cubicTo(
        w * 0.11, h * 0.10,
        w * 0.04, h * 0.12,
        0, h * 0.14,
      )
      ..close();
    canvas.drawPath(outerTopPath, outerTopPaint);

    // (b) Inner vibrant hot pink blob
    final innerTopPaint = Paint()
      ..color = LinkUpTheme.activePink
      ..style = PaintingStyle.fill;

    final innerTopPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.26, 0)
      ..cubicTo(
        w * 0.25, h * 0.035,
        w * 0.19, h * 0.06,
        w * 0.12, h * 0.072,
      )
      ..cubicTo(
        w * 0.07, h * 0.08,
        w * 0.03, h * 0.095,
        0, h * 0.11,
      )
      ..close();
    canvas.drawPath(innerTopPath, innerTopPaint);

    // ==========================================
    // 2. BOTTOM-LEFT ORGANIC WAVES (Cyan & Yellow)
    // ==========================================
    // (a) Cyan curve along bottom-left corner
    final cyanPaint = Paint()
      ..color = LinkUpTheme.blobCyan
      ..style = PaintingStyle.fill;

    final cyanPath = Path()
      ..moveTo(0, h * 0.89)
      ..cubicTo(
        w * 0.08, h * 0.90,
        w * 0.15, h * 0.94,
        w * 0.19, h,
      )
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(cyanPath, cyanPaint);

    // (b) Warm sunny yellow wave
    final yellowPaint = Paint()
      ..color = LinkUpTheme.blobYellow
      ..style = PaintingStyle.fill;

    final yellowPath = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(
        w * 0.09, h * 0.83,
        w * 0.15, h * 0.87,
        w * 0.13, h * 0.93,
      )
      ..cubicTo(
        w * 0.11, h * 0.97,
        w * 0.05, h * 0.99,
        0, h,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // ==========================================
    // 3. BOTTOM-RIGHT LAYERED WAVES (Pink & Droplets)
    // ==========================================
    // (a) Outer soft pastel pink wave
    final outerBottomPinkPaint = Paint()
      ..color = const Color(0xFFFFB8D8)
      ..style = PaintingStyle.fill;

    final outerBottomPinkPath = Path()
      ..moveTo(w * 0.62, h)
      ..cubicTo(
        w * 0.70, h * 0.965,
        w * 0.74, h * 0.915,
        w * 0.85, h * 0.925,
      )
      ..cubicTo(
        w * 0.93, h * 0.93,
        w * 0.97, h * 0.885,
        w, h * 0.84,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(outerBottomPinkPath, outerBottomPinkPaint);

    // (b) Inner vibrant hot pink wave
    final innerBottomPinkPaint = Paint()
      ..color = LinkUpTheme.activePink
      ..style = PaintingStyle.fill;

    final innerBottomPinkPath = Path()
      ..moveTo(w * 0.74, h)
      ..cubicTo(
        w * 0.81, h * 0.975,
        w * 0.84, h * 0.945,
        w * 0.91, h * 0.95,
      )
      ..cubicTo(
        w * 0.96, h * 0.955,
        w * 0.985, h * 0.925,
        w, h * 0.895,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(innerBottomPinkPath, innerBottomPinkPaint);

    // (c) 2 Cute floating splash droplets in hot pink
    final dropPaint = Paint()
      ..color = LinkUpTheme.activePink
      ..style = PaintingStyle.fill;

    _drawSplashDroplet(
      canvas,
      center: Offset(w * 0.945, h * 0.865),
      length: 13.0,
      thickness: 5.5,
      angle: -0.75,
      paint: dropPaint,
    );

    _drawSplashDroplet(
      canvas,
      center: Offset(w * 0.905, h * 0.895),
      length: 11.0,
      thickness: 5.0,
      angle: -1.15,
      paint: dropPaint,
    );
  }

  void _drawSplashDroplet(
    Canvas canvas, {
    required Offset center,
    required double length,
    required double thickness,
    required double angle,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: length, height: thickness),
      Radius.circular(thickness / 2),
    );
    canvas.drawRRect(r, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 100% Pure Dart Vector Canvas Painter for Welcome Back (SignIn) Screen
/// Exactly matching the reference image:
/// - Top-Right: Soft lavender & vibrant purple blob with 3 delicate purple rays
/// - Bottom-Left: Cyan & blue curve waves
/// - Center-Bottom: Warm sunny yellow curve
/// - Bottom-Right: Layered pink waves with 2 floating purple droplets
class SignInBackgroundPainter extends CustomPainter {
  const SignInBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ==========================================
    // 1. TOP-RIGHT ORGANIC PURPLE BLOBS
    // ==========================================
    // (a) Outer soft lavender blob
    final outerPurplePaint = Paint()
      ..color = const Color(0xFFDDD6FE)
      ..style = PaintingStyle.fill;

    final outerPurplePath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.64, 0)
      ..cubicTo(
        w * 0.65, h * 0.04,
        w * 0.72, h * 0.075,
        w * 0.82, h * 0.09,
      )
      ..cubicTo(
        w * 0.89, h * 0.10,
        w * 0.96, h * 0.12,
        w, h * 0.14,
      )
      ..close();
    canvas.drawPath(outerPurplePath, outerPurplePaint);

    // (b) Inner vibrant purple blob
    final innerPurplePaint = Paint()
      ..color = LinkUpTheme.blobPurple
      ..style = PaintingStyle.fill;

    final innerPurplePath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.74, 0)
      ..cubicTo(
        w * 0.75, h * 0.035,
        w * 0.81, h * 0.06,
        w * 0.88, h * 0.072,
      )
      ..cubicTo(
        w * 0.93, h * 0.08,
        w * 0.97, h * 0.095,
        w, h * 0.11,
      )
      ..close();
    canvas.drawPath(innerPurplePath, innerPurplePaint);

    // ==========================================
    // 2. BOTTOM-LEFT CURVED WAVES (Cyan & Blue)
    // ==========================================
    // (a) Cyan wave
    final cyanPaint = Paint()
      ..color = LinkUpTheme.blobCyan
      ..style = PaintingStyle.fill;

    final cyanPath = Path()
      ..moveTo(0, h * 0.84)
      ..cubicTo(
        w * 0.07, h * 0.85,
        w * 0.13, h * 0.895,
        w * 0.12, h * 0.955,
      )
      ..cubicTo(
        w * 0.11, h * 0.98,
        w * 0.07, h,
        0, h,
      )
      ..close();
    canvas.drawPath(cyanPath, cyanPaint);

    // (b) Deep royal blue wave
    final bluePaint = Paint()
      ..color = LinkUpTheme.blobBlue
      ..style = PaintingStyle.fill;

    final bluePath = Path()
      ..moveTo(0, h * 0.91)
      ..cubicTo(
        w * 0.05, h * 0.92,
        w * 0.09, h * 0.95,
        w * 0.12, h,
      )
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // ==========================================
    // 3. CENTER-BOTTOM WARM YELLOW WAVE
    // ==========================================
    final yellowPaint = Paint()
      ..color = LinkUpTheme.blobYellow
      ..style = PaintingStyle.fill;

    final yellowPath = Path()
      ..moveTo(w * 0.10, h)
      ..cubicTo(
        w * 0.16, h * 0.935,
        w * 0.28, h * 0.925,
        w * 0.38, h * 0.96,
      )
      ..cubicTo(
        w * 0.42, h * 0.975,
        w * 0.46, h,
        w * 0.50, h,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // ==========================================
    // 4. BOTTOM-RIGHT LAYERED WAVES (Pink & Purple Droplets)
    // ==========================================
    // (a) Outer soft pastel pink wave
    final outerBottomPinkPaint = Paint()
      ..color = const Color(0xFFFFB8D8)
      ..style = PaintingStyle.fill;

    final outerBottomPinkPath = Path()
      ..moveTo(w * 0.55, h)
      ..cubicTo(
        w * 0.65, h * 0.96,
        w * 0.72, h * 0.91,
        w * 0.84, h * 0.92,
      )
      ..cubicTo(
        w * 0.92, h * 0.925,
        w * 0.965, h * 0.88,
        w, h * 0.835,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(outerBottomPinkPath, outerBottomPinkPaint);

    // (b) Inner vibrant hot pink wave
    final innerBottomPinkPaint = Paint()
      ..color = LinkUpTheme.activePink
      ..style = PaintingStyle.fill;

    final innerBottomPinkPath = Path()
      ..moveTo(w * 0.69, h)
      ..cubicTo(
        w * 0.77, h * 0.97,
        w * 0.81, h * 0.94,
        w * 0.89, h * 0.945,
      )
      ..cubicTo(
        w * 0.95, h * 0.95,
        w * 0.98, h * 0.92,
        w, h * 0.89,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(innerBottomPinkPath, innerBottomPinkPaint);

    // (c) 2 Floating purple splash droplets
    final dropPaint = Paint()
      ..color = LinkUpTheme.blobPurple
      ..style = PaintingStyle.fill;

    _drawSplashDroplet(
      canvas,
      center: Offset(w * 0.81, h * 0.895),
      length: 13.0,
      thickness: 5.5,
      angle: -0.75,
      paint: dropPaint,
    );

    _drawSplashDroplet(
      canvas,
      center: Offset(w * 0.85, h * 0.865),
      length: 11.0,
      thickness: 5.0,
      angle: -0.35,
      paint: dropPaint,
    );
  }

  void _drawSplashDroplet(
    Canvas canvas, {
    required Offset center,
    required double length,
    required double thickness,
    required double angle,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: length, height: thickness),
      Radius.circular(thickness / 2),
    );
    canvas.drawRRect(r, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 100% Pure Dart Vector Canvas Painter for Phone + OTP Auth Screen
/// Features playful, minimal LinkUp brand corner abstract shapes:
/// - Top-Left: Vibrant pink & soft pastel organic blobs
/// - Top-Right: Soft purple & blue fluid accent
/// - Bottom-Left: Sunny yellow & cyan organic waves
/// - Bottom-Right: Layered pastel pink waves with floating droplets
class PhoneAuthBackgroundPainter extends CustomPainter {
  const PhoneAuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ==========================================
    // 1. TOP-LEFT ORGANIC PINK BLOBS
    // ==========================================
    final outerTopPaint = Paint()
      ..color = const Color(0xFFFFB8D8).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final outerTopPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.38, 0)
      ..cubicTo(
        w * 0.36, h * 0.04,
        w * 0.26, h * 0.08,
        w * 0.16, h * 0.09,
      )
      ..cubicTo(
        w * 0.09, h * 0.10,
        w * 0.03, h * 0.12,
        0, h * 0.14,
      )
      ..close();
    canvas.drawPath(outerTopPath, outerTopPaint);

    final innerTopPaint = Paint()
      ..color = LinkUpTheme.activePink.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final innerTopPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.25, 0)
      ..cubicTo(
        w * 0.23, h * 0.03,
        w * 0.17, h * 0.055,
        w * 0.10, h * 0.065,
      )
      ..cubicTo(
        w * 0.05, h * 0.075,
        w * 0.02, h * 0.09,
        0, h * 0.105,
      )
      ..close();
    canvas.drawPath(innerTopPath, innerTopPaint);

    // ==========================================
    // 2. TOP-RIGHT PURPLE & BLUE ACCENT
    // ==========================================
    final purplePaint = Paint()
      ..color = LinkUpTheme.blobPurple.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final purplePath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.76, 0)
      ..cubicTo(
        w * 0.80, h * 0.035,
        w * 0.86, h * 0.06,
        w * 0.93, h * 0.065,
      )
      ..cubicTo(
        w * 0.97, h * 0.07,
        w * 0.99, h * 0.09,
        w, h * 0.10,
      )
      ..close();
    canvas.drawPath(purplePath, purplePaint);

    // ==========================================
    // 3. BOTTOM-LEFT WAVES (Cyan & Sunny Yellow)
    // ==========================================
    final cyanPaint = Paint()
      ..color = LinkUpTheme.blobCyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final cyanPath = Path()
      ..moveTo(0, h * 0.89)
      ..cubicTo(
        w * 0.08, h * 0.90,
        w * 0.15, h * 0.94,
        w * 0.18, h,
      )
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(cyanPath, cyanPaint);

    final yellowPaint = Paint()
      ..color = LinkUpTheme.blobYellow.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final yellowPath = Path()
      ..moveTo(0, h * 0.84)
      ..cubicTo(
        w * 0.08, h * 0.85,
        w * 0.13, h * 0.88,
        w * 0.11, h * 0.93,
      )
      ..cubicTo(
        w * 0.09, h * 0.97,
        w * 0.04, h * 0.99,
        0, h,
      )
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // ==========================================
    // 4. BOTTOM-RIGHT LAYERED WAVES (Pink)
    // ==========================================
    final outerBottomPinkPaint = Paint()
      ..color = const Color(0xFFFFB8D8).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final outerBottomPinkPath = Path()
      ..moveTo(w * 0.65, h)
      ..cubicTo(
        w * 0.72, h * 0.97,
        w * 0.76, h * 0.925,
        w * 0.86, h * 0.935,
      )
      ..cubicTo(
        w * 0.93, h * 0.94,
        w * 0.97, h * 0.90,
        w, h * 0.86,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(outerBottomPinkPath, outerBottomPinkPaint);

    final innerBottomPinkPaint = Paint()
      ..color = LinkUpTheme.activePink.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final innerBottomPinkPath = Path()
      ..moveTo(w * 0.76, h)
      ..cubicTo(
        w * 0.82, h * 0.98,
        w * 0.85, h * 0.95,
        w * 0.92, h * 0.955,
      )
      ..cubicTo(
        w * 0.965, h * 0.96,
        w * 0.985, h * 0.935,
        w, h * 0.91,
      )
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(innerBottomPinkPath, innerBottomPinkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

