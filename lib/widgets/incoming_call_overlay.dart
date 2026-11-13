import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/services/api_service.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/services/navigation_service.dart';
import 'package:version1/widgets/coin_icon.dart';

class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({super.key});

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  Timer? _hapticTimer;
  bool _isResponding = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Subtle real-time ringing haptic pulse on hardware devices
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
    _hapticTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _isResponding) return;
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(Map<String, dynamic> call) async {
    if (_isResponding) return;
    final callId = call['callId']?.toString() ?? '';
    if (callId.isEmpty) {
      AppState.instance.dismissIncomingCall();
      return;
    }

    setState(() {
      _isResponding = true;
      _isAccepting = true;
    });
    _hapticTimer?.cancel();

    final caller = call['caller'] as Map<String, dynamic>? ?? {};
    final isVideo = (call['callType'] as String? ?? 'VIDEO') == 'VIDEO';

    try {
      final res = await ApiService.instance.acceptCall(callId);
      if (!mounted) return;

      if (res['success'] != true) {
        AppState.instance.dismissIncomingCall(callId: callId);
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                res['error']?.toString() ?? 'Call is no longer available.',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1E293B),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final callerAsCreator = CreatorModel(
        id: caller['id']?.toString() ?? 'caller',
        name: caller['name']?.toString() ?? 'LinkUp User',
        age: 24,
        photoUrl: caller['photoUrl']?.toString() ?? '',
        diamondsPerMin: (call['ratePerMin'] is int)
            ? call['ratePerMin'] as int
            : int.tryParse('${call['ratePerMin']}') ?? 500,
      );

      final navState = rootNavigatorKey.currentState;
      AppState.instance.dismissIncomingCall(callId: callId);

      if (navState != null) {
        navState.push(
          MaterialPageRoute(
            builder: (_) => ActiveCallScreen(
              creator: callerAsCreator,
              isVideoCall: isVideo,
              callId: callId,
              isCaller: false,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isResponding = false;
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _handleDecline(Map<String, dynamic> call) async {
    if (_isResponding) return;
    final callId = call['callId']?.toString() ?? '';
    setState(() {
      _isResponding = true;
      _isAccepting = false;
    });
    _hapticTimer?.cancel();

    AppState.instance.dismissIncomingCall(callId: callId);
    if (callId.isNotEmpty) {
      await ApiService.instance.rejectCall(callId, reason: 'CREATOR_DECLINED');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final incoming = AppState.instance.incomingCall;
        if (incoming == null) return const SizedBox.shrink();

        final caller = incoming['caller'] as Map<String, dynamic>? ?? {};
        final callerName = (caller['name'] as String?)?.trim().isNotEmpty == true
            ? (caller['name'] as String).trim()
            : 'LinkUp User';
        final callerPhoto = (caller['photoUrl'] as String?)?.trim() ?? '';
        final hasPhoto = callerPhoto.isNotEmpty &&
            !callerPhoto.startsWith('blob:') &&
            callerPhoto.startsWith('http');
        final isVideo = (incoming['callType'] as String? ?? 'VIDEO') == 'VIDEO';
        final rate = incoming['ratePerMin'] ?? 500;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Material(
            color: const Color(0xFF0B1215),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-screen blurred caller wallpaper or deep ambient call background
                if (hasPhoto)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Image.network(
                      callerPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _AmbientCallBackdrop(),
                    ),
                  )
                else
                  const _AmbientCallBackdrop(),

                // Dark scrim for crisp legibility matching native FaceTime/WhatsApp call screens
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.62),
                        Colors.black.withValues(alpha: 0.48),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(28, 20, 28, bottomPadding + 36),
                    child: Column(
                      children: [
                        // Subtle top call type indicator (no neon box)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isVideo ? 'LinkUp Video Call' : 'LinkUp Voice Call',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(flex: 2),

                        // Caller Avatar with soft concentric ring ripple
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _rippleController,
                                builder: (context, _) {
                                  final t = _rippleController.value;
                                  final size = 118.0 + (52.0 * t);
                                  final opacity = (1.0 - t) * 0.28;
                                  return Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: opacity),
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: hasPhoto
                                      ? Image.network(
                                          callerPhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => _CallerInitialsAvatar(name: callerName),
                                        )
                                      : _CallerInitialsAvatar(name: callerName),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Caller Name
                        Text(
                          callerName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Clean status text
                        Text(
                          _isAccepting
                              ? 'Connecting live room...'
                              : (isVideo ? 'Incoming video call...' : 'Incoming voice call...'),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Clean minimal rate indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CoinIcon(size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Earn $rate Coins / min',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Bottom Real-Time Call Controls (Thumb-friendly native layout)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Decline Button
                            _CallActionButton(
                              backgroundColor: const Color(0xFFEF4444),
                              icon: Icons.call_end_rounded,
                              label: 'Decline',
                              disabled: _isResponding,
                              isLoading: false,
                              onTap: () => _handleDecline(incoming),
                            ),

                            // Accept Button
                            _CallActionButton(
                              backgroundColor: const Color(0xFF16A34A),
                              icon: isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                              label: _isAccepting ? 'Joining' : 'Accept',
                              disabled: _isResponding,
                              isLoading: _isAccepting,
                              onTap: () => _handleAccept(incoming),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AmbientCallBackdrop extends StatelessWidget {
  const _AmbientCallBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E1B1F),
            Color(0xFF0B1215),
            Color(0xFF071314),
          ],
        ),
      ),
    );
  }
}

class _CallerInitialsAvatar extends StatelessWidget {
  final String name;
  const _CallerInitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007A78), Color(0xFF0F4C5C)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 44,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String label;
  final bool disabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.disabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            customBorder: const CircleBorder(),
            child: Ink(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: disabled && !isLoading
                    ? backgroundColor.withValues(alpha: 0.45)
                    : backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
