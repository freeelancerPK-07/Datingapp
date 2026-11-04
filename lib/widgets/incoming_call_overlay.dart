import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/services/api_service.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/services/navigation_service.dart';

class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({super.key});

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(BuildContext context, Map<String, dynamic> call) async {
    final callId = call['callId'] as String;
    final caller = call['caller'] as Map<String, dynamic>? ?? {};
    final isVideo = (call['callType'] as String? ?? 'VIDEO') == 'VIDEO';

    // Dismiss overlay from AppState
    AppState.instance.dismissIncomingCall();

    // Call accept endpoint
    await ApiService.instance.acceptCall(callId);

    // Build creator representation of caller
    final callerAsCreator = CreatorModel(
      id: caller['id'] as String? ?? 'caller',
      name: caller['name'] as String? ?? 'LinkUp User',
      age: 24,
      photoUrl: caller['photoUrl'] as String? ?? '',
      diamondsPerMin: call['ratePerMin'] as int? ?? 500,
    );

    final navState = rootNavigatorKey.currentState;
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
  }

  Future<void> _handleDecline(Map<String, dynamic> call) async {
    final callId = call['callId'] as String;
    AppState.instance.dismissIncomingCall();
    await ApiService.instance.rejectCall(callId, reason: 'CREATOR_DECLINED');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final incoming = AppState.instance.incomingCall;
        if (incoming == null) return const SizedBox.shrink();

        final caller = incoming['caller'] as Map<String, dynamic>? ?? {};
        final callerName = caller['name'] as String? ?? 'Incoming Caller';
        final callerPhoto = caller['photoUrl'] as String? ?? '';
        final isVideo = (incoming['callType'] as String? ?? 'VIDEO') == 'VIDEO';
        final rate = incoming['ratePerMin'] ?? 500;

        return Material(
          color: Colors.black.withValues(alpha: 0.75),
          child: SafeArea(
            child: Center(
              child: ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Incoming Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.ring_volume_rounded, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isVideo ? 'INCOMING VIDEO CALL' : 'INCOMING VOICE CALL',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Caller Avatar
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF10B981), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (callerPhoto.isNotEmpty && !callerPhoto.startsWith('blob:') && callerPhoto.startsWith('http'))
                              ? Image.network(
                                  callerPhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF007A78),
                                    alignment: Alignment.center,
                                    child: Text(
                                      callerName.isNotEmpty ? callerName[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF007A78),
                                  alignment: Alignment.center,
                                  child: Text(
                                    callerName.isNotEmpty ? callerName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Caller Name
                      Text(
                        callerName,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Earnings Rate
                      Text(
                        'Earn $rate Coins/min',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons: Decline & Accept
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Decline Button
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _handleDecline(incoming),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x66EF4444),
                                        blurRadius: 16,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.call_end_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Decline',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Accept Button
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _handleAccept(context, incoming),
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x6610B981),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.call_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Accept',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF10B981),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
