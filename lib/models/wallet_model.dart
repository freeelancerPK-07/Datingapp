enum TransactionType {
  purchase,
  callUsage,
  photoPurchase,
  refund,
  sessionHold,
}

class CoinPackage {
  final int coins;
  final int priceInr;
  final String? tag;

  const CoinPackage({
    required this.coins,
    required this.priceInr,
    this.tag,
  });

  // Backward-compatibility getter
  int get diamonds => coins;
}

// Typedef for seamless backward-compatibility
typedef DiamondPackage = CoinPackage;

/// Official 6 fixed LinkUp Coin packages: 200 to 700 Coins
const List<CoinPackage> kCoinPackages = [
  CoinPackage(coins: 200, priceInr: 199),
  CoinPackage(coins: 300, priceInr: 299),
  CoinPackage(coins: 400, priceInr: 399, tag: 'Popular'),
  CoinPackage(coins: 500, priceInr: 499),
  CoinPackage(coins: 600, priceInr: 599, tag: 'Best Value'),
  CoinPackage(coins: 700, priceInr: 699, tag: 'VIP Pack'),
];

// Alias for existing callers
const List<CoinPackage> kDiamondPackages = kCoinPackages;

class WalletTransaction {
  final String id;
  final String description;
  final int coins;
  final bool isCredit;
  final DateTime timestamp;
  final double? amountInr;
  final TransactionType type;
  final String status; // 'Completed', 'Reserved', 'Refunded'

  const WalletTransaction({
    required this.id,
    required this.description,
    required this.coins,
    required this.isCredit,
    required this.timestamp,
    this.amountInr,
    this.type = TransactionType.purchase,
    this.status = 'Completed',
  });

  // Backward-compatibility getter
  int get diamonds => coins;
}
