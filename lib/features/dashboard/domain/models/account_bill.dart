class AccountBill {
  const AccountBill({
    required this.amount,
    required this.direction,
    required this.directionLabel,
    required this.billType,
    required this.billTypeLabel,
    required this.createdAt,
    required this.totalAmount,
    this.remark,
  });

  final int amount;
  final String direction;
  final String directionLabel;
  final String billType;
  final String billTypeLabel;
  final DateTime createdAt;
  final int totalAmount;
  final String? remark;
}
