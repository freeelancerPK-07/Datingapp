import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/screens/edit_profile_screen.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/screens/welcome_screen.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';
import 'package:version1/widgets/app_image.dart';

class ProfileSelfScreen extends StatefulWidget {
  const ProfileSelfScreen({super.key});

  @override
  State<ProfileSelfScreen> createState() => _ProfileSelfScreenState();
}

class _ProfileSelfScreenState extends State<ProfileSelfScreen> {

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  // -------------------------------------------------------------
  // Modals & Dialogs
  // -------------------------------------------------------------

  void _showTransactionHistorySheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final txns = appState.transactions;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2B32),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: txns.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions yet',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: txns.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final txn = txns[i];
                          final isCredit = txn.isCredit;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCredit
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isCredit
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        txn.description,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111111),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        txn.status,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CoinIcon(size: 13),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${isCredit ? '+' : '-'}${txn.coins}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isCredit
                                            ? const Color(0xFF007A78)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPhotoSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Photo to Gallery',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add authentic photos from your device to your profile gallery.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),

              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF007A78)),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Live selfie or photo using device camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedPath = await AppImagePickerService.pickFromCamera();
                  if (pickedPath != null) {
                    appState.addGalleryPhoto(pickedPath);
                    if (appState.userProfile.photoUrl.isEmpty) {
                      appState.updateUserProfile(photoUrl: pickedPath);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo captured and added to gallery! 📸',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF007A78),
                      ),
                    );
                  }
                },
              ),

              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF007A78)),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Select photo from phone camera roll'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedPath = await AppImagePickerService.pickFromGallery();
                  if (pickedPath != null) {
                    appState.addGalleryPhoto(pickedPath);
                    if (appState.userProfile.photoUrl.isEmpty) {
                      appState.updateUserProfile(photoUrl: pickedPath);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Photo selected and added to gallery! 🖼️',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF007A78),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoOptionsDialog(int index, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            if (index != 0)
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Color(0xFF007A78)),
                title: Text(
                  'Set as Main Profile Photo',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  appState.setMainGalleryPhoto(index);
                  Navigator.pop(ctx);
                },
              ),
            if (appState.userProfile.galleryPhotos.length > 1)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                title: Text(
                  'Delete Photo',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                onTap: () {
                  appState.removeGalleryPhoto(index);
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsersSheet(AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final blocked = appState.userProfile.blockedUsers;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Blocked Users (${blocked.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F2B32),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: blocked.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 48,
                                  color: Color(0xFF007A78),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No blocked users',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Users you block will appear here.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: blocked.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFFE5E7EB)),
                            itemBuilder: (context, i) {
                              final name = blocked[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFF0FAF8),
                                  child: Text(
                                    name.isNotEmpty ? name[0] : 'U',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF007A78),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    appState.unblockUser(name);
                                    setSheetState(() {});
                                  },
                                  child: Text(
                                    'Unblock',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF007A78),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReportDialog() {
    String selectedReason = 'Fake Profile / Impersonation';
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
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
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Report a Problem / Content',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Our safety team reviews all reports 24/7.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ...[
                'Fake Profile / Impersonation',
                'Harassment / Inappropriate Behavior',
                'Spam / Scam / Financial Fraud',
                'Payment or Coins Issue',
                'Other safety issue',
              ].map(
                (reason) {
                  final isSelected = selectedReason == reason;
                  return InkWell(
                    onTap: () => setModalState(() => selectedReason = reason),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? const Color(0xFF007A78) : const Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF0F2B32) : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you. Your report has been submitted to the safety team.',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF007A78),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A78),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Submit Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(AppState appState) {
    final currentLang = appState.userProfile.appLanguage;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'App Language',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2B32),
              ),
            ),
            const SizedBox(height: 12),
            ...[
              {'code': 'en', 'title': 'English'},
              {'code': 'ta', 'title': 'தமிழ் (Tamil)'},
              {'code': 'hi', 'title': 'हिंदी (Hindi)'},
            ].map(
              (item) {
                final isSelected = currentLang == item['title'];
                return ListTile(
                  title: Text(
                    item['title']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF007A78) : const Color(0xFF111111),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF007A78))
                      : null,
                  onTap: () {
                    appState.updatePrivacySettings(appLanguage: item['title']);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Help & 24/7 Support',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2B32),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We are here to assist you with wallet, video calls, and safety.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Color(0xFF007A78)),
              title: Text('Email Support', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              subtitle: const Text('support@linkupapp.in • 2 hour response'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF007A78)),
              title: Text('Live Help Chat', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              subtitle: const Text('Connect with a support agent instantly'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.help_center_outlined, color: Color(0xFF007A78)),
              title: Text('Frequently Asked Questions', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              subtitle: const Text('Coins, booking sessions, refunds & privacy'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2B32),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE5E7EB)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 26),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        content: Text(
          'This action is irreversible.\n\nAll your personal data, uploaded photos, chat history, and remaining LinkUp Coins balance will be permanently erased as per Google Play Store and Apple App Store compliance guidelines.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF4B5563),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.deleteUserAccount();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Delete Permanently',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF111111),
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your LinkUp account?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Main Build
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final profile = appState.userProfile;
        final photoUrl = profile.photoUrl.isNotEmpty
            ? profile.photoUrl
            : (profile.galleryPhotos.isNotEmpty
                ? profile.galleryPhotos.first
                : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300');

        final ageDisplay = profile.age > 0 ? profile.age : 24;
        final isOnlineHidden = profile.hideOnlineStatus;
        final isDistanceHidden = profile.hideDistance;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My Profile',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F2B32),
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF0F2B32)),
                tooltip: 'Edit Profile',
                onPressed: _navigateToEditProfile,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // ==========================================
              // 1. TOP PROFILE AVATAR & BASIC INFO
              // ==========================================
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF005E5D), Color(0xFF00A896)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFF0FAF8),
                            foregroundImage: getAppImageProvider(photoUrl),
                            onForegroundImageError: photoUrl.isNotEmpty ? (exception, stackTrace) {} : null,
                            child: const Icon(Icons.person, size: 48, color: Color(0xFF007A78)),
                          ),
                        ),
                        // Online indicator or hidden badge
                        Positioned(
                          bottom: 3,
                          right: 3,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isOnlineHidden
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                        // Edit icon badge on avatar
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _navigateToEditProfile,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF007A78),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name, Age & Verified Blue Tick
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${appState.userName}, $ageDisplay',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F2B32),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF2563EB), // Blue Tick Selfie Verified
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // City & Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF007A78),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDistanceHidden
                              ? appState.userCity
                              : '${appState.userCity} • 2 km away',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Online status text chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOnlineHidden
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFFF0FAF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOnlineHidden
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFFCEF1EB),
                        ),
                      ),
                      child: Text(
                        isOnlineHidden ? '🔒 Status Hidden (Private)' : '● Active now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOnlineHidden
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF007A78),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Edit Profile Button (Opens Single-Page Profile Editor)
                    SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF007A78)),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF007A78),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCEF1EB), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 2. COIN BALANCE CARD + RECHARGE + TXN SHORTCUT
              // ==========================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinkUpTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007A78).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CoinIcon(size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'LINKUP COINS BALANCE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showTransactionHistorySheet(context, appState),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'History',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${appState.availableCoins} Coins',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Locked for sessions: ${appState.reservedCoins} Coins',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => RechargePackagesSheet.show(context),
                          icon: const Icon(Icons.add_rounded, color: Color(0xFF007A78), size: 16),
                          label: Text(
                            'Recharge',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF007A78),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 3. MY PHOTOS (6 PHOTOS GALLERY)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Photos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: const Icon(Icons.tune_rounded, size: 14, color: Color(0xFF007A78)),
                    label: Text(
                      'Manage (${profile.galleryPhotos.length}/6)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'First photo is your primary profile image visible on creator feeds.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: profile.galleryPhotos.length < 6
                      ? profile.galleryPhotos.length + 1
                      : profile.galleryPhotos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    if (i == profile.galleryPhotos.length) {
                      // Add Photo Card
                      return GestureDetector(
                        onTap: () => _showAddPhotoSheet(context, appState),
                        child: Container(
                          width: 95,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FAF8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFCEF1EB),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007A78),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF007A78),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final photo = profile.galleryPhotos[i];
                    final isMain = i == 0;

                    return GestureDetector(
                      onTap: () => _showPhotoOptionsDialog(i, appState),
                      child: Stack(
                        children: [
                          AppImage(
                            path: photo,
                            width: 95,
                            height: 130,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          if (isMain)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007A78),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '★ MAIN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 4. THE BASICS (PERSONAL OVERVIEW)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basics',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildBasicRow(Icons.height_rounded, 'Height', profile.height),
                    const Divider(height: 18, color: Color(0xFFE5E7EB)),
                    _buildBasicRow(Icons.work_outline_rounded, 'Work', profile.job),
                    const Divider(height: 18, color: Color(0xFFE5E7EB)),
                    _buildBasicRow(Icons.school_outlined, 'Education', profile.education),
                    const Divider(height: 18, color: Color(0xFFE5E7EB)),
                    _buildBasicRow(
                      Icons.camera_alt_outlined,
                      'Instagram',
                      profile.instagram.isNotEmpty ? '@${profile.instagram}' : 'Not linked',
                      isHighlight: profile.instagram.isNotEmpty,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 5. MARKETPLACE RATING & REVIEWS CARD
              // ==========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCEF1EB), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
                            const SizedBox(width: 6),
                            Text(
                              '${profile.rating}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F2B32),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${profile.reviewCount} Reviews)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCEF1EB)),
                            ),
                            child: Text(
                              '🛡️ Verified Community Member',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF007A78),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '“Super polite, engaging conversations, and highly recommended on LinkUp live video calls!”',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 6. PROFILE PROMPTS (Q & A)
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prompts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...profile.prompts.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCEF1EB), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PROFILE PROMPT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF007A78),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p['question'] ?? '',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F2B32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p['answer'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: const Color(0xFF374151),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ==========================================
              // 7. ABOUT ME / BIO
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'About Me',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F2B32),
                    ),
                  ),
                  Text(
                    '${appState.userBio.length} / 150 chars',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  appState.userBio.isNotEmpty
                      ? appState.userBio
                      : 'Share a little bit about yourself, your hobbies, and what you love...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 8. LOOKING FOR / INTENT
              // ==========================================
              Text(
                'Looking For',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCEF1EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFF007A78), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      profile.lookingFor,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007A78),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 9. INTERESTS & LANGUAGES
              // ==========================================
              if (profile.interests.isNotEmpty) ...[
                Text(
                  'My Interests',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2B32),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.interests.map((item) {
                    final tag = item.startsWith('#') ? item : '#$item';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FAF8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCEF1EB)),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007A78),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              if (profile.languages.isNotEmpty) ...[
                Text(
                  'Spoken Languages',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2B32),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.languages.map((lang) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        lang,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ==========================================
              // 10. PRIVACY OPTIONS (MUKKIYAM)
              // ==========================================
              Text(
                'Privacy Controls',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your visibility, safety and privacy preferences.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    // Hide Online Status Switch
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Text(
                        'Hide Online Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      subtitle: Text(
                        'Hide whether you are active or when you were last seen.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      value: isOnlineHidden,
                      activeTrackColor: const Color(0xFF007A78),
                      onChanged: (val) {
                        appState.updatePrivacySettings(hideOnlineStatus: val);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),

                    // Hide Distance Switch
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Text(
                        'Hide Distance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      subtitle: Text(
                        'Do not show your exact distance from other creators.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      value: isDistanceHidden,
                      activeTrackColor: const Color(0xFF007A78),
                      onChanged: (val) {
                        appState.updatePrivacySettings(hideDistance: val);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),

                    // Block List
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(Icons.block_rounded, color: Color(0xFF007A78), size: 20),
                      title: Text(
                        'Blocked Users',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      subtitle: Text(
                        '${profile.blockedUsers.length} users blocked',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                      onTap: () => _showBlockedUsersSheet(appState),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),

                    // Report an Issue
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(Icons.flag_outlined, color: Color(0xFF007A78), size: 20),
                      title: Text(
                        'Report an Issue / Problem',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      subtitle: Text(
                        'Report suspicious profiles or platform issues.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                      onTap: _showReportDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // 11. SETTINGS & PREFERENCES
              // ==========================================
              Text(
                'Settings & Preferences',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 10),

              _buildSettingsCard([
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.notifications_none_rounded, color: Color(0xFF007A78), size: 20),
                  title: Text(
                    'Push Notifications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    value: profile.notificationsEnabled,
                    activeTrackColor: const Color(0xFF007A78),
                    onChanged: (val) {
                      appState.saveOnboardingDraft(profile.copyWith(notificationsEnabled: val));
                    },
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.language_rounded, color: Color(0xFF007A78), size: 20),
                  title: Text(
                    'Language',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.appLanguage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF007A78),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                  onTap: () => _showLanguageSelector(appState),
                ),
              ]),

              const SizedBox(height: 24),

              // ==========================================
              // 12. HELP, SUPPORT, TERMS & PRIVACY
              // ==========================================
              Text(
                'Support & Legal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2B32),
                ),
              ),
              const SizedBox(height: 10),

              _buildSettingsCard([
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF007A78), size: 20),
                  title: Text(
                    'Help & Support',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: _showHelpSupportSheet,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.description_outlined, color: Color(0xFF007A78), size: 20),
                  title: Text(
                    'Terms & Conditions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: () => _showTermsDialog(
                    'Terms & Conditions',
                    'Welcome to LinkUp.\n\n1. Acceptance: By accessing LinkUp, you agree to comply with our community terms and platform guidelines.\n2. Age Requirement: Users must be 18 years or older.\n3. LinkUp Coins: In-app currency purchased via verified payment gateways (Razorpay). Coins are used for private 1-on-1 video call interactions with creators.\n4. Code of Conduct: Mutual respect, zero tolerance for harassment, hate speech, or nudity.',
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF007A78), size: 20),
                  title: Text(
                    'Privacy Policy',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: () => _showTermsDialog(
                    'Privacy Policy',
                    'LinkUp values your privacy.\n\n1. Data Protection: Your personal data, phone number, and location are encrypted and never sold to third parties.\n2. Visibility Controls: You have full control over hiding your online status and hiding your distance.\n3. Media & Permissions: Camera and microphone access are requested exclusively for real-time Agora video call streaming.\n4. Right to Deletion: You can permanently delete your account and all associated data at any time directly within this screen.',
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // ==========================================
              // 13. LOG OUT & DELETE ACCOUNT (MANDATORY)
              // ==========================================
              _buildSettingsCard([
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFE53935), size: 20),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: _showLogoutDialog,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE5E7EB)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 20),
                  title: Text(
                    'Delete Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  subtitle: Text(
                    'Permanently delete account, photos & coins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                  onTap: () => _showDeleteAccountDialog(appState),
                ),
              ]),

              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF007A78), size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlight ? const Color(0xFF007A78) : const Color(0xFF111111),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }
}
