import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/user_profile_service.dart';
import '../core/services/wallet_service.dart';
import 'onboarding_welcome_screen.dart';
import 'profile_setup_screen.dart';
import 'user_settings_screen.dart';

class ProfileSelfScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProfileSelfScreen({super.key, this.onNavigateTab});

  static const String _fallbackAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80';

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out of Trylo?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.pineDark,
          ),
        ),
        content: Text(
          'Are you sure you want to log out? You will need to verify your number or email to sign in again.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await AuthService.instance.signOut();
                await UserProfileService.instance.clearProfile();
              } catch (_) {}
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingWelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(isEditing: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserProfileService.instance,
      builder: (context, _) {
        final profile = UserProfileService.instance.profile;
        final displayName = profile.name.isNotEmpty ? profile.name : 'Alex Morgan';
        final displayAge = profile.age > 0 ? profile.age : 24;
        final displayLocation = (profile.city.isNotEmpty ? '${profile.city}, ' : '') +
            (profile.country.isNotEmpty ? profile.country : 'India');
        final displayHandle =
            '@${displayName.toLowerCase().replaceAll(' ', '_')} • $displayLocation';

        ImageProvider avatarProvider;
        if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) {
          if (profile.avatarPath!.startsWith('http') || kIsWeb) {
            avatarProvider = NetworkImage(profile.avatarPath!);
          } else {
            avatarProvider = FileImage(File(profile.avatarPath!));
          }
        } else {
          avatarProvider = const NetworkImage(_fallbackAvatar);
        }

        final interestsList = profile.interests.isNotEmpty
            ? profile.interests
            : const [
                'Coffee',
                'Visual Arts',
                'Travel & Road Trips',
                'Music',
                'Photography',
                'Nature Hikes',
              ];

        return Scaffold(
          backgroundColor: const Color(0xFFFBFDFD),
          body: SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 95),
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pineDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.pineDark),
                      onPressed: () => _openEditProfile(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F374442),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar with Edit Badge
                      GestureDetector(
                        onTap: () => _openEditProfile(context),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.seafoamTeal, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundImage: avatarProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.pineDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name & Verified Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '$displayName, $displayAge',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pineDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.seafoamTeal, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Text(
                        displayHandle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (profile.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          profile.bio,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.iceMint.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('14', 'Matches'),
                            Container(width: 1, height: 24, color: AppColors.paleMint),
                            _buildStat('328', 'Likes'),
                            Container(width: 1, height: 24, color: AppColors.paleMint),
                            GestureDetector(
                              onTap: () => onNavigateTab?.call(2),
                              child: _buildStat('₹${WalletService.instance.totalBalance.toInt()}', 'Wallet'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Completeness Banner
                GestureDetector(
                  onTap: () => _openEditProfile(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F6F4), Color(0xFFF0FAF8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.paleMint),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.seafoamTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.isProfileCompleted ? 'Profile Complete' : 'Profile Incomplete',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pineDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.isProfileCompleted
                                    ? 'Your profile is live and verified'
                                    : 'Tap to update photos and details',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.pineDark),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // My Interests
                Text(
                  'My Interests',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interestsList.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        interest,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pineDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (profile.languages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Languages',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.languages.map((lang) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.iceMint.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.paleMint),
                        ),
                        child: Text(
                          lang,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pineDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Settings & Preferences Menu
                Text(
                  'Settings & Preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile & Photos',
                        onTap: () => _openEditProfile(context),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.tune_rounded,
                        title: 'Dating Preferences & Distance',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Trylo Wallet & Top-Up',
                        onTap: () => onNavigateTab?.call(2),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.security_rounded,
                        title: 'Privacy & Safety',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const UserSettingsScreen(initialIndex: 0),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notification Preferences',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const UserSettingsScreen(initialIndex: 1),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.account_balance_rounded,
                        title: 'KYC & Limits Center',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const UserSettingsScreen(initialIndex: 2),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.headset_mic_rounded,
                        title: 'Support & Dispute Center',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const UserSettingsScreen(initialIndex: 3),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        isDestructive: true,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.pineDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFFECEF)
                : AppColors.iceMint.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive ? const Color(0xFFE53935) : AppColors.pineDark,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDestructive ? const Color(0xFFE53935) : AppColors.pineDark,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.borderLight);
  }
}
