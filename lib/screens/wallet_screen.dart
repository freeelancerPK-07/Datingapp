import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:version1/constants/svg_assets.dart';
import 'package:version1/models/wallet_model.dart';
import 'package:version1/screens/recharge_packages_sheet.dart';
import 'package:version1/services/app_state.dart';
import 'package:version1/widgets/coin_icon.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _timeFilter = 'All Time'; // 'All Time', 'This Month', 'This Week'
  String _typeFilter = 'All Types'; // 'All Types', 'Purchases', 'Session Holds', 'Refunds'

  void _showInvoice(WalletTransaction txn) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvoiceBottomSheet(txn: txn),
    );
  }

  void _showLockedInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFFF59E0B), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Locked Session Escrow',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'When you book a creator session (Video Call, Voice Call, or Paid Media), the required Coins are safely locked in escrow until the session begins.\n\nIf the creator declines or the 30-second timeout occurs, 100% of your Coins are instantly refunded to your Available Balance.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
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
        final allTransactions = appState.transactions;

        // Apply time and type filters
        final filteredTransactions = allTransactions.where((txn) {
          if (_typeFilter == 'Purchases' && txn.type != TransactionType.purchase) {
            return false;
          }
          if (_typeFilter == 'Session Holds' && txn.type != TransactionType.sessionHold) {
            return false;
          }
          if (_typeFilter == 'Refunds' && txn.type != TransactionType.refund) {
            return false;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LinkUp Wallet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: LinkUpTheme.darkSlate,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'India-first digital balance with Razorpay UPI & Coins',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            actions: [
              // Coins Currency Indicator Badge
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCEF1EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CoinIcon(size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Coins',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // 1. Hero Balance Card (Trylo-inspired dark theme card)
              _buildHeroBalanceCard(appState),

              const SizedBox(height: 14),

              // 2. Action Buttons (+ Add Coins / Hold & Refund)
              _buildActionButtons(context),

              const SizedBox(height: 16),

              // 3. RBI PPI Guideline Protection Banner
              _buildRbiProtectionCard(),

              const SizedBox(height: 20),

              // 4. Quick Recharge Coins Strip
              _buildQuickRechargeStrip(context),

              const SizedBox(height: 24),

              // 5. Transaction History Section Header & Filter Chips
              _buildTransactionHeader(filteredTransactions.length),

              const SizedBox(height: 12),

              // Filter Tabs (All Time, This Month, This Week)
              _buildTimeFilterPills(),

              const SizedBox(height: 10),

              // Category Filter Pills (All Types, Purchases, Session Holds, Refunds)
              _buildCategoryFilterPills(),

              const SizedBox(height: 14),

              // 6. Transaction Items List
              if (filteredTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFFD1D5DB)),
                        const SizedBox(height: 8),
                        Text(
                          'No transactions in this filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredTransactions.map((txn) => _buildTransactionCard(txn)),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // 1. Hero Balance Card (Total, Available, Locked)
  Widget _buildHeroBalanceCard(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2B32), // Dark Slate Teal
            Color(0xFF005E5D), // Deep Rich Teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B32).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Header & Auto-Secured Lock Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCEF1EB),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-Secured',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Big Total Balance Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CoinIcon(size: 32),
              const SizedBox(width: 10),
              Text(
                '${appState.totalCoins}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Coins',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFCEF1EB),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Sub-Cards: Available Balance & Reserved Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                // Available Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCEF1EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appState.availableCoins} Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to spend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2DD4BF),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 42,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 14),

                // Reserved / Locked Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reserved Balance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCEF1EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appState.lockedCoins} Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Locked for ongoing session',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFBBF24),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Action Buttons (+ Add Coins / Hold & Refund)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Add Coins Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              key: const ValueKey('wallet_recharge_button'),
              onPressed: () => RechargePackagesSheet.show(context),
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
              label: Text(
                'Add Coins',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Hold / Refund History Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showLockedInfoSheet,
              icon: const Icon(Icons.sync_alt_rounded, color: LinkUpTheme.darkSlate, size: 18),
              label: Text(
                'Hold / Refund',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: LinkUpTheme.darkSlate,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3. RBI PPI Guideline Protection Banner
  Widget _buildRbiProtectionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCEF1EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: LinkUpTheme.primaryTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RBI PPI Guideline Protected',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: LinkUpTheme.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wallet balances are held in LinkUp Coins for creator sessions. Smallest package (200 Coins) is minimum reload.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.35,
                    color: const Color(0xFF4A6B74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Quick Recharge Coins Strip
  Widget _buildQuickRechargeStrip(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Coin Packs',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: LinkUpTheme.darkSlate,
              ),
            ),
            GestureDetector(
              onTap: () => RechargePackagesSheet.show(context),
              child: Text(
                'View All (6) →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildQuickCoinChip(context, 200, '₹199', null),
            const SizedBox(width: 8),
            _buildQuickCoinChip(context, 400, '₹399', 'Popular'),
            const SizedBox(width: 8),
            _buildQuickCoinChip(context, 600, '₹599', 'Best Value'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickCoinChip(BuildContext context, int coins, String price, String? tag) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => RechargePackagesSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tag != null ? LinkUpTheme.mintAccent : const Color(0xFFE5E7EB),
              width: tag != null ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CoinIcon(size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$coins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: LinkUpTheme.darkSlate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LinkUpTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Transaction History Header
  Widget _buildTransactionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaction History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: LinkUpTheme.darkSlate,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count records',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  // Time Filter Tabs
  Widget _buildTimeFilterPills() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['All Time', 'This Month', 'This Week'].map((t) {
          final isSel = _timeFilter == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _timeFilter = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSel ? LinkUpTheme.darkSlate : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    t,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Category Filter Pills
  Widget _buildCategoryFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All Types', 'Purchases', 'Session Holds', 'Refunds'].map((cat) {
          final isSel = _typeFilter == cat;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSel,
              onSelected: (_) => setState(() => _typeFilter = cat),
              selectedColor: const Color(0xFFCEF1EB),
              backgroundColor: const Color(0xFFF9FAFB),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? LinkUpTheme.primaryTeal : const Color(0xFF4B5563),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSel ? LinkUpTheme.mintAccent : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 6. Individual Transaction Item Card
  Widget _buildTransactionCard(WalletTransaction txn) {
    final isHold = txn.type == TransactionType.sessionHold;
    final isPurchase = txn.type == TransactionType.purchase;
    final isRefund = txn.type == TransactionType.refund;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isHold
                  ? const Color(0xFFFFFBEB)
                  : isRefund
                      ? const Color(0xFFE5F7F4)
                      : isPurchase
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHold
                  ? Icons.lock_clock_rounded
                  : isRefund
                      ? Icons.replay_rounded
                      : isPurchase
                          ? Icons.add_circle_outline_rounded
                          : Icons.call_made_rounded,
              color: isHold
                  ? const Color(0xFFD97706)
                  : isRefund
                      ? LinkUpTheme.primaryTeal
                      : isPurchase
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Details: Title & Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: LinkUpTheme.darkSlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${txn.timestamp.day} ${_monthName(txn.timestamp.month)}, ${txn.timestamp.hour.toString().padLeft(2, '0')}:${txn.timestamp.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('•', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      'Coin Wallet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Coins (+ / -) & Invoice Link
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${txn.isCredit ? "+" : "-"}${txn.coins} Coins',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isPurchase || isRefund
                      ? const Color(0xFF16A34A)
                      : isHold
                          ? const Color(0xFFD97706)
                          : LinkUpTheme.darkSlate,
                ),
              ),
              const SizedBox(height: 2),

              // Invoice Link for purchases / settled transactions
              if (txn.amountInr != null && (isPurchase || isHold))
                InkWell(
                  onTap: () => _showInvoice(txn),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_outlined, size: 12, color: Color(0xFF007A78)),
                      const SizedBox(width: 3),
                      Text(
                        'Invoice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007A78),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  txn.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return m[month - 1];
  }
}

// -----------------------------------------------------------------------------
// Official Tax Invoice Modal Sheet (PDF Order Requirements)
// -----------------------------------------------------------------------------
class _InvoiceBottomSheet extends StatelessWidget {
  final WalletTransaction txn;

  const _InvoiceBottomSheet({required this.txn});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final inrAmount = txn.amountInr ?? (txn.coins * 1.0);
    final taxableValue = inrAmount / 1.18;
    final gst18 = inrAmount - taxableValue;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Invoice Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F7F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: LinkUpTheme.primaryTeal, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Invoice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: LinkUpTheme.darkSlate,
                        ),
                      ),
                      Text(
                        'LinkUp Technologies Pvt Ltd',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Invoice Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildInvoiceRow('Invoice Number', 'INV-${txn.id}'),
                _buildInvoiceRow('Transaction Date', '${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year}'),
                _buildInvoiceRow('Payment Gateway', 'Razorpay UPI (Verified)'),
                _buildInvoiceRow('Item Description', txn.description),
                const Divider(height: 20, color: Color(0xFFE5E7EB)),
                _buildInvoiceRow('Taxable Value', '₹${taxableValue.toStringAsFixed(2)}'),
                _buildInvoiceRow('GST @ 18% (Inclusive)', '₹${gst18.toStringAsFixed(2)}'),
                const Divider(height: 20, color: Color(0xFFE5E7EB)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: LinkUpTheme.darkSlate,
                      ),
                    ),
                    Text(
                      '₹${inrAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: LinkUpTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Download PDF Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invoice INV-${txn.id}.pdf downloaded successfully!',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: LinkUpTheme.primaryTeal,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
              label: Text(
                'Download PDF Invoice',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: LinkUpTheme.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: LinkUpTheme.darkSlate),
            ),
          ),
        ],
      ),
    );
  }
}
