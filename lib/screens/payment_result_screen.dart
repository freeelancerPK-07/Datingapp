import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/wallet_model.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

enum PaymentResultStatus { success, failed, pending, cancelled }

class PaymentResultScreen extends StatelessWidget {
  final PaymentResultStatus status;
  final CoinPackage package;
  final String transactionId;
  final String paymentMethod;
  final VoidCallback? onReturn;

  const PaymentResultScreen({
    super.key,
    required this.status,
    required this.package,
    required this.transactionId,
    this.paymentMethod = 'Razorpay UPI (Google Pay)',
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF111111)),
            onPressed: () {
              Navigator.of(context).pop();
              if (onReturn != null) onReturn!();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),

              // Status Icon Centerpiece
              if (status == PaymentResultStatus.success) ...[
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF007A78), Color(0xFF00A896)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4000A896),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: LinkUpTheme.darkSlate,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF007A78))),
                    const SizedBox(width: 4),
                    const CoinIcon(size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${package.coins} LinkUp Coins Added',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ] else if (status == PaymentResultStatus.failed) ...[
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEF4444),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x35EF4444),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Failed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction could not be completed. If your account was debited, money will be refunded in 24-48 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ] else ...[
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF59E0B),
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Pending',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for bank confirmation. Coins will be credited automatically once verified.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Order Breakdown Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FCFA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCEF1EB)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Transaction ID', transactionId),
                    const Divider(height: 20, color: Color(0xFFE2EAEF)),
                    _buildReceiptRow('Amount Paid (INR)', '₹${package.priceInr}.00'),
                    const Divider(height: 20, color: Color(0xFFE2EAEF)),
                    _buildReceiptRow('LinkUp Coins Credited', '${package.coins} Coins'),
                    const Divider(height: 20, color: Color(0xFFE2EAEF)),
                    _buildReceiptRow('Payment Method', paymentMethod),
                    const Divider(height: 20, color: Color(0xFFE2EAEF)),
                    _buildReceiptRow(
                      'Updated Wallet Balance',
                      '${appState.availableCoins} Coins',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              if (status == PaymentResultStatus.success) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinkUpTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: LinkUpTheme.primaryTeal.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        if (onReturn != null) onReturn!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Continue to Creator Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LinkUpTheme.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight ? LinkUpTheme.primaryTeal : LinkUpTheme.darkSlate,
          ),
        ),
      ],
    );
  }
}
