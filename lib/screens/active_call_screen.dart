import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/call_record_model.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

enum NetworkQuality { strong, fair, weak }

class ActiveCallScreen extends StatefulWidget {
  final CreatorModel creator;
  final bool isVideoCall;
  final int initialDurationSeconds;

  const ActiveCallScreen({
    super.key,
    required this.creator,
    this.isVideoCall = true,
    this.initialDurationSeconds = 600, // 10 minutes default
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with TickerProviderStateMixin {
  late int _secondsRemaining;
  int _elapsedSeconds = 0;
  int _diamondsUsed = 0;
  late Timer _callCountdownTimer;
  late Timer _diamondDeductionTimer;

  // Call Controls State
  bool _isMuted = false;
  late bool _isVideoEnabled;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;

  // Network Quality State
  NetworkQuality _networkQuality = NetworkQuality.strong;
  int _pingMs = 42;

  // Draggable PIP coordinates (for Video Call self preview)
  Offset _pipPosition = const Offset(20, 80);

  // Pulse animations for Radar waves
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideoCall;
    _secondsRemaining = widget.initialDurationSeconds;
    _diamondsUsed = widget.creator.diamondsPerMin; // First minute charged upon connection

    // Deduct initial 1 minute rate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.instance.deductDiamonds(widget.creator.diamondsPerMin, widget.creator.name);
    });

    // Countdown and Elapsed Timer
    _callCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _elapsedSeconds++;

      if (_secondsRemaining <= 1) {
        timer.cancel();
        _handleEndCall(isTimeout: true);
      } else {
        setState(() {
          _secondsRemaining--;

          // Fluctuate network ping for realistic heartbeat check
          if (_secondsRemaining % 20 == 0) {
            _pingMs = 38 + (_secondsRemaining % 15);
            _networkQuality = _pingMs > 50 ? NetworkQuality.fair : NetworkQuality.strong;
          }
        });
      }
    });

    // Diamond deduction every 60 seconds (Live per-minute deduction)
    _diamondDeductionTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final appState = AppState.instance;

      if (appState.diamondBalance < widget.creator.diamondsPerMin) {
        // Auto-end call when balance is insufficient for next minute
        timer.cancel();
        _handleEndCall(isAutoEnd: true);
      } else {
        appState.deductDiamonds(widget.creator.diamondsPerMin, widget.creator.name);
        setState(() {
          _diamondsUsed += widget.creator.diamondsPerMin;
        });
      }
    });

    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _callCountdownTimer.cancel();
    _diamondDeductionTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _handleEndCall({bool isTimeout = false, bool isAutoEnd = false}) {
    _callCountdownTimer.cancel();
    _diamondDeductionTimer.cancel();

    // Persist completed call record to AppState Call History
    AppState.instance.addCallRecord(
      CallRecord(
        id: 'call_${DateTime.now().millisecondsSinceEpoch}',
        creatorId: widget.creator.id,
        name: widget.creator.name,
        age: widget.creator.age,
        photoUrl: widget.creator.photoUrl,
        type: CallType.completed,
        timestamp: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        coinsUsed: _diamondsUsed,
        isOnline: widget.creator.isOnline,
        isAvailableForCall: true,
      ),
    );

    if (isAutoEnd && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Call ended: Diamond balance reached 0.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PostCallReviewSheet(
        creator: widget.creator,
        durationSeconds: _elapsedSeconds,
        diamondsUsed: _diamondsUsed,
        remainingBalance: AppState.instance.diamondBalance,
        isVideoCall: widget.isVideoCall,
        onDone: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Video / Audio Feed
          Positioned.fill(
            child: _isVideoEnabled
                ? Image.network(
                    widget.creator.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1A1A24),
                      child: const Center(
                        child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 48),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF2A1530), Color(0xFF0F0B13)],
                        radius: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140 * _pulseScale.value,
                                    height: 140 * _pulseScale.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF007A78).withValues(alpha: _pulseOpacity.value),
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(widget.creator.photoUrl),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.creator.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Encrypted Voice Call In Progress...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Top Status Bar Overlay (Network, Live Timer, Rate, Creator Name, Live Balance)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Creator Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.creator.photoUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.creator.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const CoinIcon(size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.creator.diamondsPerMin}/min • Live',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFD43B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Live Coin Balance Chip
                      AnimatedBuilder(
                        animation: AppState.instance,
                        builder: (context, _) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F7).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF007A78).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CoinIcon(size: 13),
                              const SizedBox(width: 4),
                              Text(
                                '${AppState.instance.availableCoins}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Timer & Network Quality Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _networkQuality == NetworkQuality.strong
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatDuration(_elapsedSeconds),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Low Balance Warning Banner (balance < 1 min, Recharge without call cut)
                  AnimatedBuilder(
                    animation: AppState.instance,
                    builder: (context, _) {
                      final balance = AppState.instance.diamondBalance;
                      final isLow = balance < widget.creator.diamondsPerMin;

                      if (!isLow) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44DC2626),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Low Diamonds (< 1 min left)! Call ends soon.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Open recharge sheet without ending the call!
                                RechargePackagesSheet.show(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '⚡ Recharge',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. Draggable PIP Self-Preview (Video Call Only)
          if (_isVideoEnabled)
            Positioned(
              left: _pipPosition.dx,
              top: _pipPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _pipPosition += details.delta;
                    _pipPosition = Offset(
                      _pipPosition.dx.clamp(16.0, screenSize.width - 136.0),
                      _pipPosition.dy.clamp(80.0, screenSize.height - 240.0),
                    );
                  });
                },
                child: Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF007A78), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                            child: Icon(Icons.person, color: Colors.white54, size: 40),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isFrontCamera ? 'Front Cam' : 'Back Cam',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. Bottom Call Controls (Mute, Toggle Video, Flip Cam, Speaker, End Call)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.88),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Audio
                  _buildCallBtn(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: _isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),

                  // Toggle Video
                  _buildCallBtn(
                    icon: _isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    label: _isVideoEnabled ? 'Stop Video' : 'Start Video',
                    isActive: !_isVideoEnabled,
                    onTap: () => setState(() => _isVideoEnabled = !_isVideoEnabled),
                  ),

                  // Flip Camera
                  if (_isVideoEnabled)
                    _buildCallBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      label: 'Flip',
                      isActive: false,
                      onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                    ),

                  // Speaker Toggle
                  _buildCallBtn(
                    icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    label: 'Speaker',
                    isActive: _isSpeakerOn,
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),

                  // End Call (Vibrant Red)
                  GestureDetector(
                    onTap: () => _handleEndCall(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66E53935),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF007A78) : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Post-Call Review & Summary Sheet (Duration, Diamonds Used, Remaining Balance, Rating, Report)
class _PostCallReviewSheet extends StatefulWidget {
  final CreatorModel creator;
  final int durationSeconds;
  final int diamondsUsed;
  final int remainingBalance;
  final bool isVideoCall;
  final VoidCallback onDone;

  const _PostCallReviewSheet({
    required this.creator,
    required this.durationSeconds,
    required this.diamondsUsed,
    required this.remainingBalance,
    this.isVideoCall = true,
    required this.onDone,
  });

  @override
  State<_PostCallReviewSheet> createState() => _PostCallReviewSheetState();
}

class _PostCallReviewSheetState extends State<_PostCallReviewSheet> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();

  String _formatDuration(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 34,
              backgroundImage: NetworkImage(widget.creator.photoUrl),
            ),
            const SizedBox(height: 10),
            Text(
              'Call Ended with ${widget.creator.name}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Call Summary & Review',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),

            // Call Summary Metrics Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        _formatDuration(widget.durationSeconds),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CoinIcon(size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.diamondsUsed}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF007A78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Used',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CoinIcon(size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.remainingBalance}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Remaining',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Escrow Commission Split Breakdown (PRD Requirement G - Step 9 & 10)
            Builder(
              builder: (context) {
                final creatorCoins = (widget.diamondsUsed * 0.70).round();
                final platformCoins = widget.diamondsUsed - creatorCoins;

                return Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCEF1EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart_outline_rounded, size: 16, color: Color(0xFF007A78)),
                          const SizedBox(width: 6),
                          Text(
                            'Session Commission Split',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F2B32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCEF1EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Creator (70%)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$creatorCoins Coins',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF007A78),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCEF1EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Platform Fee (30%)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$platformCoins Coins',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4A6B74),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Rating Stars
            Text(
              'How was your conversation with ${widget.creator.name}?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _selectedRating = star),
                  icon: Icon(
                    star <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFD43B),
                    size: 32,
                  ),
                );
              }),
            ),

            // Quick Compliment Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                'Super Friendly 😊',
                'Great Advice 💡',
                'High Quality 🌟',
                'Quick Response ⚡',
              ].map((chip) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    chip,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Optional Feedback TextField
            TextField(
              controller: _feedbackController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Leave a sweet note or feedback (optional)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Submit & Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Settle escrow booking (PRD Requirement G - Step 10)
                  AppState.instance.completeBookingSettlement(
                    serviceName: widget.isVideoCall ? 'Video Call' : 'Voice Call',
                    amount: 500.0,
                    creatorSharePercent: 0.70,
                  );

                  AppState.instance.addRatingAndReview(
                    creatorId: widget.creator.id,
                    rating: _selectedRating,
                    review: _feedbackController.text.trim(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Thank you for your review! ⭐ $_selectedRating stars submitted.',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  widget.onDone();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A78),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: Text(
                  'Submit & Close',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
