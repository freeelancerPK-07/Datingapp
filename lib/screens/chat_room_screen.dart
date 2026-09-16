import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/wallet_service.dart';
import '../widgets/add_funds_bottom_sheet.dart';
import '../widgets/post_session_review_sheet.dart';
import 'active_call_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final ValueChanged<int>? onNavigateTab;

  const ChatRoomScreen({
    super.key,
    required this.conversation,
    this.onNavigateTab,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Active Session 30-minute Countdown Timer (PDF Page 10)
  int _sessionSecondsRemaining = 24 * 60 + 35; // 24m 35s remaining
  Timer? _sessionTimer;

  // Typing indicator simulation
  bool _isTyping = false;
  Timer? _typingTimer;

  // Voice player playback simulation
  String? _currentlyPlayingVoiceId;
  double _voiceProgress = 0.0;
  Timer? _voicePlayerTimer;

  // Pinned status & Mute status
  bool _isPinned = false;
  bool _isMuted = false;

  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    _initSampleMessages();
    _scheduleTypingSimulation();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _typingTimer?.cancel();
    _voicePlayerTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_sessionSecondsRemaining > 0) {
        setState(() => _sessionSecondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _scheduleTypingSimulation() {
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isTyping = true);
        Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _isTyping = false);
          }
        });
      }
    });
  }

  String _formatSessionTime(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _initSampleMessages() {
    final creatorName = widget.conversation['name'] ?? 'Creator';
    _messages = [
      {
        'id': 'm1',
        'isMe': false,
        'type': 'text',
        'text': 'Hey Alex! Loved your profile vibe ✨ Thank you for connecting with me!',
        'time': '10:15 AM',
        'status': 'read',
      },
      {
        'id': 'm2',
        'isMe': true,
        'type': 'text',
        'text': 'Hey $creatorName! It is great to chat with you. I really admire your creative work!',
        'time': '10:16 AM',
        'status': 'read',
      },
      {
        'id': 'm3',
        'isMe': false,
        'type': 'voice',
        'voiceDuration': '0:28',
        'time': '10:18 AM',
        'status': 'read',
      },
      {
        'id': 'm4',
        'isMe': false,
        'type': 'paid_photo',
        'price': 200.0,
        'title': 'Exclusive Sunset Studio Photo',
        'mediaUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        'isUnlocked': false,
        'time': '10:20 AM',
        'status': 'read',
      },
      {
        'id': 'm5',
        'isMe': true,
        'type': 'text',
        'text': 'The voice note was so sweet! Looking forward to unlocking your private studio photo.',
        'time': '10:21 AM',
        'status': 'delivered',
      },
    ];
  }

  void _sendMessage() {
    final txt = _msgController.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _messages.add({
        'id': 'm_${DateTime.now().millisecondsSinceEpoch}',
        'isMe': true,
        'type': 'text',
        'text': txt,
        'time': 'Just now',
        'status': 'delivered',
      });
      _msgController.clear();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------------------------------------------------
  // Unlock Paid Media Message Logic (Deducts from Wallet)
  // -------------------------------------------------------------
  Future<void> _handleUnlockMedia(Map<String, dynamic> message) async {
    final cost = (message['price'] as num?)?.toDouble() ?? 200.0;
    final wallet = WalletService.instance;
    final title = message['title'] as String? ?? 'Private Media';
    final creatorName = widget.conversation['name'] ?? 'Creator';

    if (wallet.availableBalance < cost) {
      final shortfall = cost - wallet.availableBalance;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient balance. Need ₹${shortfall.ceil()} more to unlock.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Add Money',
            textColor: Colors.white,
            onPressed: () => AddFundsBottomSheet.show(
              context,
              initialAmount: shortfall,
              onDepositSuccess: () => setState(() {}),
            ),
          ),
        ),
      );
      return;
    }

    // Confirm unlock dialog
    final shouldUnlock = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientSunsetAmber,
              ),
              child: const Icon(Icons.lock_open_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Unlock Media?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.pineDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Unlock "$title" by $creatorName for ₹${cost.toInt()}? The amount will be directly deducted from your Available Balance.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientSunsetAmber,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Unlock for ₹${cost.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldUnlock == true) {
      final success = await wallet.holdForBooking(
        amount: cost,
        sessionTitle: 'Paid Media: $title',
      );

      if (success && mounted) {
        setState(() {
          message['isUnlocked'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Unlocked! ₹${cost.toInt()} paid to $creatorName.',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  // -------------------------------------------------------------
  // Voice Player Toggle Simulation
  // -------------------------------------------------------------
  void _togglePlayVoice(String id) {
    if (_currentlyPlayingVoiceId == id) {
      _voicePlayerTimer?.cancel();
      setState(() {
        _currentlyPlayingVoiceId = null;
        _voiceProgress = 0.0;
      });
    } else {
      _voicePlayerTimer?.cancel();
      setState(() {
        _currentlyPlayingVoiceId = id;
        _voiceProgress = 0.0;
      });

      _voicePlayerTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (_voiceProgress >= 1.0) {
          t.cancel();
          setState(() {
            _currentlyPlayingVoiceId = null;
            _voiceProgress = 0.0;
          });
        } else {
          setState(() {
            _voiceProgress += 0.035;
          });
        }
      });
    }
  }

  // -------------------------------------------------------------
  // Action Menu Handler
  // -------------------------------------------------------------
  void _handleActionMenuSelection(String value) {
    switch (value) {
      case 'pin':
        setState(() => _isPinned = !_isPinned);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPinned ? 'Chat pinned to top' : 'Chat unpinned'),
            backgroundColor: AppColors.pineDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'mute':
        setState(() => _isMuted = !_isMuted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isMuted ? 'Notifications muted' : 'Notifications unmuted'),
            backgroundColor: AppColors.pineDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'clear':
        setState(() => _messages.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat history cleared'),
            backgroundColor: AppColors.pineDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'block':
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${widget.conversation['name']} blocked'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile reported to Trust & Safety team'),
            backgroundColor: AppColors.pineDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'review':
        PostSessionReviewSheet.show(
          context,
          creator: widget.conversation,
          serviceTitle: 'Paid Chat Session',
          sessionCost: 150.0,
          onCompleted: () {
            Navigator.pop(context);
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final name = conv['name'] as String? ?? 'Creator';
    final avatar = conv['avatar'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200';
    final bool isOnline = (conv['isOnline'] as bool?) ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFA),
      appBar: _buildChatHeader(name, avatar, isOnline),
      body: Column(
        children: [
          // Active Session Banner with Glowing Gradient
          _buildSessionActiveBanner(),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator(name);
                }
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Message Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Header: Avatar, Name, Verification, Timer, Call Buttons & Menu
  // -------------------------------------------------------------
  PreferredSizeWidget _buildChatHeader(
      String name, String avatar, bool isOnline) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.pineDark, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar with Online dot & Gradient border
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientCyberCyan,
                ),
                child: CircleAvatar(
                  radius: 19,
                  backgroundImage: NetworkImage(avatar),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // Name & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded,
                        size: 15, color: Color(0xFF0D9488)),
                    if (_isPinned) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.push_pin_rounded,
                          size: 13, color: AppColors.textMuted),
                    ],
                  ],
                ),
                Text(
                  isOnline ? 'Online now • Verified Creator' : 'Offline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isOnline
                        ? const Color(0xFF059669)
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Voice Call Shortcut
        IconButton(
          icon: const Icon(Icons.phone_in_talk_rounded,
              color: AppColors.pineDark, size: 21),
          tooltip: 'Voice Call',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActiveCallScreen(
                  creator: widget.conversation,
                  isVideoCall: false,
                  sessionCost: 300.0,
                  serviceTitle: 'Voice Call (15 Mins)',
                ),
              ),
            );
          },
        ),

        // Video Call Shortcut
        IconButton(
          icon: const Icon(Icons.videocam_rounded,
              color: AppColors.pineDark, size: 24),
          tooltip: 'Video Call',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActiveCallScreen(
                  creator: widget.conversation,
                  isVideoCall: true,
                  sessionCost: 500.0,
                  serviceTitle: 'Video Call (10 Mins)',
                ),
              ),
            );
          },
        ),

        // Action Menu (Pin, Mute, Clear, Block, Report)
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.pineDark, size: 21),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onSelected: _handleActionMenuSelection,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(_isPinned ? Icons.pin_end_rounded : Icons.push_pin_rounded,
                      size: 18, color: AppColors.pineDark),
                  const SizedBox(width: 10),
                  Text(_isPinned ? 'Unpin Chat' : 'Pin Chat',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(_isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      size: 18, color: AppColors.pineDark),
                  const SizedBox(width: 10),
                  Text(_isMuted ? 'Unmute Notifications' : 'Mute Notifications',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.cleaning_services_rounded,
                      size: 18, color: AppColors.pineDark),
                  const SizedBox(width: 10),
                  Text('Clear History',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  const Icon(Icons.report_problem_outlined,
                      size: 18, color: Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  Text('Report Profile',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, color: const Color(0xFFD97706))),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  const Icon(Icons.block_rounded,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Text('Block User',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, color: AppColors.error)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'review',
              child: Row(
                children: [
                  const Icon(Icons.star_rate_rounded,
                      size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  Text('Rate & Review Session',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, color: const Color(0xFFB45309))),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.borderLight, height: 1.0),
      ),
    );
  }

  // -------------------------------------------------------------
  // Session Active Countdown Banner (Gradient Strip)
  // -------------------------------------------------------------
  Widget _buildSessionActiveBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F6F4),
            Color(0xFFD6EDE9),
            Color(0xFFE8F6F4),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.paleMint, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientEmeraldTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock_rounded,
                    size: 13, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Paid Chat Session Active',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pineDark,
                ),
              ),
            ],
          ),

          // Timer Capsule & Review CTA
          Row(
            children: [
              GestureDetector(
                onTap: () => _handleActionMenuSelection('review'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientSunsetAmber,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x28F59E0B),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        'Review',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientEmeraldTeal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2810B981),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatSessionTime(_sessionSecondsRemaining)} left',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Message Item Factory: Text, Voice, Paid Media
  // -------------------------------------------------------------
  Widget _buildMessageItem(Map<String, dynamic> msg) {
    final type = msg['type'] as String;
    switch (type) {
      case 'paid_photo':
        return _buildPaidMediaMessage(msg);
      case 'voice':
        return _buildVoiceMessage(msg);
      case 'text':
      default:
        return _buildTextMessage(msg);
    }
  }

  // -------------------------------------------------------------
  // Standard Text Message with Double Check Marks
  // -------------------------------------------------------------
  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = (msg['isMe'] as bool?) ?? false;
    final text = msg['text'] as String? ?? '';
    final time = msg['time'] as String? ?? '';
    final status = msg['status'] as String? ?? 'delivered';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          gradient: isMe ? AppColors.gradientEmeraldTeal : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isMe ? const Color(0x2610B981) : const Color(0x0C000000),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: isMe ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.pineDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isMe ? const Color(0xFFD6EDE9) : AppColors.textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    status == 'read'
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 14,
                    color: status == 'read'
                        ? const Color(0xFF67E8F9)
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Paid Media Message: Blurred with Lock & Unlock flow
  // -------------------------------------------------------------
  Widget _buildPaidMediaMessage(Map<String, dynamic> msg) {
    final isMe = (msg['isMe'] as bool?) ?? false;
    final isUnlocked = (msg['isUnlocked'] as bool?) ?? false;
    final price = (msg['price'] as num?)?.toDouble() ?? 200.0;
    final title = msg['title'] as String? ?? 'Paid Exclusive Photo';
    final mediaUrl = msg['mediaUrl'] as String? ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';
    final time = msg['time'] as String? ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? const Color(0x1A10B981)
                  : const Color(0x24F59E0B),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Area (Blurred if locked)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Image preview
                  ImageFiltered(
                    imageFilter: isUnlocked
                        ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                        : ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: AspectRatio(
                      aspectRatio: 1.25,
                      child: Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Overlay when LOCKED
                  if (!isUnlocked)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: AspectRatio(
                        aspectRatio: 1.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.gradientSunsetAmber,
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Private Creator Media',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFEF3C7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Unlock Button
                            GestureDetector(
                              onTap: () => _handleUnlockMedia(msg),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientSunsetAmber,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40EA580C),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.key_rounded,
                                        size: 15, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Unlock for ₹${price.toInt()}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Unlocked Ribbon
                  if (isUnlocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientEmeraldTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Unlocked',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Bottom card info
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUnlocked ? 'Purchased Exclusive Photo' : 'Private Media • ₹${price.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFB45309),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Voice Note Message Player UI with Animated Waveform
  // -------------------------------------------------------------
  Widget _buildVoiceMessage(Map<String, dynamic> msg) {
    final id = msg['id'] as String;
    final isMe = (msg['isMe'] as bool?) ?? false;
    final duration = msg['voiceDuration'] as String? ?? '0:24';
    final time = msg['time'] as String? ?? '';
    final isPlaying = _currentlyPlayingVoiceId == id;

    final heights = [12.0, 20.0, 32.0, 18.0, 28.0, 14.0, 26.0, 34.0, 22.0, 16.0];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          gradient: isMe ? AppColors.gradientEmeraldTeal : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isMe ? null : Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play / Pause Circle
                GestureDetector(
                  onTap: () => _togglePlayVoice(id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFF34D399), Color(0xFF10B981)])
                          : AppColors.gradientCyberCyan,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Audio Waveform Visualizer
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(heights.length, (index) {
                      final reached = isPlaying &&
                          (index / heights.length) <= _voiceProgress;
                      return Container(
                        width: 3.5,
                        height: heights[index],
                        decoration: BoxDecoration(
                          color: reached
                              ? (isMe ? Colors.white : const Color(0xFF0D9488))
                              : (isMe
                                  ? Colors.white38
                                  : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),

                // Duration Text
                Text(
                  duration,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMe ? Colors.white : AppColors.pineDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isMe ? const Color(0xFFD6EDE9) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Typing Indicator Message
  // -------------------------------------------------------------
  Widget _buildTypingIndicator(String name) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.paleMint),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name is typing',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.seafoamTeal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Message Input Bar with Attachments, Voice & Gradient Send
  // -------------------------------------------------------------
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment options popup
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.seafoamTeal, size: 26),
              onPressed: _showAttachmentSheet,
              tooltip: 'Request Media / Tip',
            ),

            // Text Input Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8F6),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pineDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type message or send reaction...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_alt_rounded,
                          color: AppColors.textMuted, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _msgController.text += ' ❤️';
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Gradient Send Button
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientEmeraldTeal,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Quick Attachment Options Bottom Sheet (Request Paid Media, Tip)
  // -------------------------------------------------------------
  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Interactive Session Actions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.pineDark,
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientSunsetAmber,
                  ),
                  child: const Icon(Icons.image_rounded, color: Colors.white, size: 20),
                ),
                title: Text('Request Custom Photo',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                subtitle: Text('Personalized private photo for ₹200',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _msgController.text = 'Could you share an exclusive studio photo? 📸';
                  _sendMessage();
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientRosePink,
                  ),
                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                ),
                title: Text('Request Custom Video',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                subtitle: Text('1-minute personalized greeting for ₹400',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _msgController.text = 'Can you record a 1-minute video greeting for me? 🎥';
                  _sendMessage();
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientCyberCyan,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                ),
                title: Text('Send Wallet Tip',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                subtitle: Text('Show appreciation with a instant ₹100 tip',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final wallet = WalletService.instance;
                  if (wallet.availableBalance >= 100) {
                    await wallet.holdForBooking(
                      amount: 100,
                      sessionTitle: 'Tip to ${widget.conversation['name']}',
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '₹100 Tip sent successfully to ${widget.conversation['name']}! 💎'),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    AddFundsBottomSheet.show(context, initialAmount: 100);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
