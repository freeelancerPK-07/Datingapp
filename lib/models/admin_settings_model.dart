class AdminSettingsModel {
  final bool isFreezeBalance;
  final bool isVideoConnectionEnabled;
  final String paymentUpiId;

  const AdminSettingsModel({
    this.isFreezeBalance = false,
    this.isVideoConnectionEnabled = true,
    this.paymentUpiId = 'linkup@ybl',
  });

  AdminSettingsModel copyWith({
    bool? isFreezeBalance,
    bool? isVideoConnectionEnabled,
    String? paymentUpiId,
  }) {
    return AdminSettingsModel(
      isFreezeBalance: isFreezeBalance ?? this.isFreezeBalance,
      isVideoConnectionEnabled: isVideoConnectionEnabled ?? this.isVideoConnectionEnabled,
      paymentUpiId: paymentUpiId ?? this.paymentUpiId,
    );
  }
}
