import 'package:flutter/material.dart';

/// Reusable LinkUp Coin Icon widget (Gold coin with sleek LinkUp branding)
class CoinIcon extends StatelessWidget {
  final double size;
  final bool withShadow;

  const CoinIcon({
    super.key,
    this.size = 18,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFFFE066), // Highlight gold
            Color(0xFFF59E0B), // Rich amber gold
            Color(0xFFD97706), // Deep rim gold
          ],
        ),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
        border: Border.all(
          color: const Color(0xFFFFFBEB),
          width: size > 24 ? 1.5 : 1.0,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.65,
          height: size * 0.65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFB45309).withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              '🪙',
              style: TextStyle(
                fontSize: size * 0.45,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
