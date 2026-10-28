import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/models/creator_model.dart';
import 'package:version1/screens/chat_room_screen.dart';
import 'package:version1/services/app_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Map<String, dynamic> conv) {
    final creator = AppState.instance.activeCreators.firstWhere(
      (c) => c.id == conv['creatorId'],
      orElse: () => CreatorModel(
        id: conv['creatorId'] ?? 'c1',
        name: conv['name'] ?? 'Creator',
        age: 23,
        photoUrl: conv['avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
        isOnline: conv['isOnline'] == true,
        isVerified: true,
        isActive: true,
        bio: 'Creator on LinkUp',
        diamondsPerMin: conv['diamondsPerMin'] ?? 50,
        location: 'India',
        tags: const ['Lifestyle'],
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          creator: creator,
          conversationId: conv['id'] ?? 'conv_c1',
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
        final activeCreators = appState.activeCreators;
        final conversations = appState.conversations.where((c) {
          if (_searchQuery.isEmpty) return true;
          final name = (c['name'] as String? ?? '').toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Messages',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111111),
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF111111)),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // Search Field
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF111111)),
                        decoration: InputDecoration(
                          hintText: 'Search chats...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 18),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Online Creators Row
              if (_searchQuery.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Online Creators',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    Text(
                      '${activeCreators.where((c) => c.isOnline).length} Active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeCreators.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, idx) {
                      final creator = activeCreators[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                creator: creator,
                                conversationId: 'conv_${creator.id}',
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF007A78), Color(0xFF00C49F)],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 26,
                                    backgroundImage: NetworkImage(creator.photoUrl),
                                  ),
                                ),
                                if (creator.isOnline)
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 60,
                              child: Text(
                                creator.name.split(' ').first,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111111),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 16),
              ],

              // Recent Messages Section
              Text(
                'Recent Conversations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),

              if (conversations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFD1D5DB), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No conversations found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...conversations.map((conv) {
                  final unread = conv['unread'] as int? ?? 0;
                  return InkWell(
                    onTap: () => _openChat(conv),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundImage: NetworkImage(conv['avatar']),
                              ),
                              if (conv['isOnline'] == true)
                                Positioned(
                                  bottom: 1,
                                  right: 1,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      conv['name'] ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    Text(
                                      conv['time'] ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                                        color: unread > 0 ? const Color(0xFF007A78) : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conv['lastMessage'] ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                          color: unread > 0 ? const Color(0xFF111111) : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (unread > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF007A78),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unread',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
