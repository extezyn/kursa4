class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isIncome;
  final int? categoryId;

  TransactionFilter({
    this.startDate,
    this.endDate,
    this.isIncome,
    this.categoryId,
  });

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
    int? categoryId,
  }) {
    return TransactionFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
      categoryId: categoryId ?? this.categoryId,
    );
  }
} 