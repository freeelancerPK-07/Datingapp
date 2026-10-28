import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/call_record_model.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/services/app_state.dart';

class CallingScreen extends StatefulWidget {
  final CreatorModel creator;
  final bool isVideoCall;

  const CallingScreen({
    super.key,
    required this.creator,
    this.isVideoCall = true,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _connectTimer;
  String _statusText = 'Calling...';
  bool _isMuted = false;
  bool _isSpeaker = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Phase 1: Calling (0 - 1.5s) -> Phase 2: Ringing (1.5s - 3.5s) -> Phase 3: Connected!
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _statusText = 'Ringing...');
      }
    });

    _connectTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveCallScreen(
            creator: widget.creator,
            isVideoCall: widget.isVideoCall,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectTimer?.cancel();
    super.dispose();
  }

  void _cancelCall() {
    _connectTimer?.cancel();

    // Record cancelled/declined call in Call History
    AppState.instance.addCallRecord(
      CallRecord(
        id: 'call_${DateTime.now().millisecondsSinceEpoch}',
        creatorId: widget.creator.id,
        name: widget.creator.name,
        age: widget.creator.age,
        photoUrl: widget.creator.photoUrl,
        type: CallType.rejected,
        timestamp: DateTime.now(),
        durationSeconds: 0,
        coinsUsed: 0,
        isOnline: widget.creator.isOnline,
        isAvailableForCall: true,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Call cancelled • 0 Coins deducted',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF111111),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.creator;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo with heavy dark blur
          Image.network(
            creator.photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F172A)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.92),
                  const Color(0xFF0F172A).withValues(alpha: 0.82),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Call Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVideoCall ? Icons.videocam_rounded : Icons.call_rounded,
                          color: const Color(0xFF007A78),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isVideoCall ? 'Encrypted Video Connection' : 'Voice Call',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Radar Pulsing Avatar
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140 * _pulseAnimation.value,
                            height: 140 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF007A78).withValues(
                                alpha: (1.3 - _pulseAnimation.value).clamp(0.0, 0.4),
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF007A78), width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FF3D9A),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                creator.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Icon(Icons.person, color: Colors.white54, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Creator Name
                  Text(
                    creator.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Text(
                    creator.location,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Status Text (Calling... / Ringing...)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _statusText,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFFFD43B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Call in-progress rate info
                  Text(
                    'Rate: 💎 ${creator.diamondsPerMin} / minute',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diamonds deducted only after call connects',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 11.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottom Controls (Mute, Cancel Call, Speaker)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute Button
                      GestureDetector(
                        onTap: () => setState(() => _isMuted = !_isMuted),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isMuted
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: _isMuted ? const Color(0xFF0F172A) : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Red End / Cancel Call Button
                      GestureDetector(
                        onTap: _cancelCall,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66DC2626),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Speaker Button
                      GestureDetector(
                        onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isSpeaker
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isSpeaker ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                            color: _isSpeaker ? const Color(0xFF0F172A) : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
