import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/screens/chat_room_screen.dart';
import 'package:version1/screens/creator_detail_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';

class CreatorProfileSheet extends StatefulWidget {
  final CreatorModel creator;

  const CreatorProfileSheet({
    super.key,
    required this.creator,
  });

  static Future<void> show(BuildContext context, CreatorModel creator) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatorProfileSheet(creator: creator),
    );
  }

  @override
  State<CreatorProfileSheet> createState() => _CreatorProfileSheetState();
}

class _CreatorProfileSheetState extends State<CreatorProfileSheet> {
  void _handleChat() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          creator: widget.creator,
          conversationId: 'conv_${widget.creator.id}',
        ),
      ),
    );
  }

  void _handleVideoCall() {
    final appState = AppState.instance;
    final check = appState.canStartVideoCall(widget.creator);

    if (!check.isAllowed) {
      if (check.isInsufficientBalance) {
        // Insufficient diamonds (PRD Section 5 & 14)
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: const [
                Text('💎 '),
                Text('Low Diamond Balance'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your diamond balance is too low to start this connection.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Required: ${widget.creator.diamondsPerMin} 💎 / min\nYour Balance: ${appState.diamondBalance} 💎',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinkUpTheme.activePink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  RechargePackagesSheet.show(context);
                },
                child: const Text('Recharge Diamonds →', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        // Administrative or other restriction
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Text(
              check.errorMessage ?? 'Unable to connect video call.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
      return;
    }

    // Launch active video call screen
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          creator: widget.creator,
          isVideoCall: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.creator;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 14,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 26,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // Drag pill
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Creator Header Photo & Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with online indicator
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      creator.photoUrl,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE7F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: LinkUpTheme.activePink,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: creator.isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, Age, Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${creator.name}, ${creator.age}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        if (creator.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: Color(0xFF4285FF),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      creator.location,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rate Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE1EE)),
                      ),
                      child: Text(
                        '💎 ${creator.diamondsPerMin} Diamonds / min',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: LinkUpTheme.activePink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Bio text
          Text(
            creator.bio,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: creator.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // View Full Profile Action
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatorDetailScreen(creator: creator),
                  ),
                );
              },
              icon: const Icon(Icons.person_outline_rounded, color: LinkUpTheme.activePink, size: 18),
              label: Text(
                'View Full Profile →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.activePink,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Connection Entry Points (PRD Section 10)
          Row(
            children: [
              // Chat Button
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _handleChat,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF111111),
                      size: 20,
                    ),
                    label: Text(
                      'Chat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Video Call Button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    key: const ValueKey('video_call_btn'),
                    onPressed: _handleVideoCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LinkUpTheme.activePink,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    icon: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    label: Text(
                      'Video Call (${creator.diamondsPerMin} 💎)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

/// Simulated Live Call with Real-Time Diamond Deduction
class _LiveVideoCallDialog extends StatefulWidget {
  final CreatorModel creator;
  const _LiveVideoCallDialog({required this.creator});

  @override
  State<_LiveVideoCallDialog> createState() => _LiveVideoCallDialogState();
}

class _LiveVideoCallDialogState extends State<_LiveVideoCallDialog> {
  Timer? _callTimer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    // Initial 1 minute deduction
    AppState.instance.deductDiamonds(widget.creator.diamondsPerMin, widget.creator.name);

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsElapsed++;
      });

      // Deduct per minute (60s)
      if (_secondsElapsed > 0 && _secondsElapsed % 60 == 0) {
        final success = AppState.instance.deductDiamonds(
          widget.creator.diamondsPerMin,
          widget.creator.name,
        );
        if (!success) {
          // Insufficient diamonds or frozen balance -> Disconnect call!
          timer.cancel();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Call ended: Insufficient diamond balance to continue.',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatCallDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Dialog.fullscreen(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background simulated video stream
          Image.network(
            widget.creator.photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),

          // Call info bar top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.creator.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCallDuration(_secondsElapsed),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // Diamond deduction indicator
                      AnimatedBuilder(
                        animation: appState,
                        builder: (context, _) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            '💎 ${appState.diamondBalance}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Call Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                  onPressed: () => setState(() => _isMuted = !_isMuted),
                  icon: Icon(
                    _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: Colors.white,
                  ),
                ),

                // End call
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Video toggle
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                  onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                  icon: Icon(
                    _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
