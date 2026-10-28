import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/active_call_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final CreatorModel creator;
  final String conversationId;

  const ChatRoomScreen({
    super.key,
    required this.creator,
    required this.conversationId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _sessionSecondsRemaining = 25 * 60; // 25 min session
  Timer? _sessionTimer;
  bool _isTyping = false;
  Timer? _replyTimer;

  // Voice player simulation
  bool _isPlayingVoice = false;
  double _voiceProgress = 0.3;

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.instance.markConversationRead(widget.conversationId);
    });
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

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _replyTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTimer(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    AppState.instance.addMessage(
      convId: widget.conversationId,
      text: text,
      isMe: true,
    );

    _scrollToBottom();

    // Simulate creator typing and reply
    setState(() => _isTyping = true);
    _replyTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      AppState.instance.addMessage(
        convId: widget.conversationId,
        text: 'Thanks for reaching out! Looking forward to connecting with you on call 💖',
        isMe: false,
      );
      _scrollToBottom();
    });
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

  void _startCall({required bool isVideo}) {
    final appState = AppState.instance;
    final check = appState.canStartVideoCall(widget.creator);

    if (!check.isAllowed) {
      if (check.isInsufficientBalance) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Insufficient Diamonds',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
            content: Text(
              'Your diamond balance is too low to start this connection. Recharge your wallet to connect with ${widget.creator.name}.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  RechargePackagesSheet.show(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A78),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Recharge Diamonds', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(check.errorMessage ?? 'Call not allowed at this time.'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          creator: widget.creator,
          isVideoCall: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final messages = appState.getMessages(widget.conversationId);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111111), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.creator.photoUrl),
                    ),
                    if (widget.creator.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.creator.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111111),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.creator.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: Color(0xFF4285FF), size: 15),
                          ],
                        ],
                      ),
                      Text(
                        _isTyping
                            ? 'Typing...'
                            : (widget.creator.isOnline ? 'Online • 💎 ${widget.creator.diamondsPerMin}/m' : 'Offline'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isTyping ? const Color(0xFF007A78) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Voice Call Button
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: Color(0xFF111111), size: 22),
                onPressed: () => _startCall(isVideo: false),
              ),
              // Video Call Button (Pink Highlight)
              IconButton(
                icon: const Icon(Icons.videocam_rounded, color: Color(0xFF007A78), size: 25),
                onPressed: () => _startCall(isVideo: true),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Column(
            children: [
              // Top Active Session Notification Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFE5F7F4),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF007A78)),
                    const SizedBox(width: 6),
                    Text(
                      'Session Active: ${_formatTimer(_sessionSecondsRemaining)} remaining',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => RechargePackagesSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE1EE)),
                        ),
                        child: Text(
                          '💎 ${appState.diamondBalance}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['isMe'] == true;
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
              ),

              // Simulated Voice Note Player sample (from dating app)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlayingVoice ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: const Color(0xFF007A78),
                        size: 32,
                      ),
                      onPressed: () => setState(() => _isPlayingVoice = !_isPlayingVoice),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Note from ${widget.creator.name} (0:42)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          Slider(
                            value: _voiceProgress,
                            activeColor: const Color(0xFF007A78),
                            inactiveColor: const Color(0xFFE5E7EB),
                            onChanged: (val) => setState(() => _voiceProgress = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Message Input Bar
              Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    // Plus / Attachment Icon
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF9CA3AF), size: 24),
                      onPressed: () {},
                    ),
                    // Text Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          controller: _msgController,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF111111)),
                          decoration: InputDecoration(
                            hintText: 'Type a message to ${widget.creator.name}...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send Button (Vibrant Pink)
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF005E5D), Color(0xFF00A896)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF007A78) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] ?? '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                color: isMe ? Colors.white : const Color(0xFF111111),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['time'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : const Color(0xFF9CA3AF),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
