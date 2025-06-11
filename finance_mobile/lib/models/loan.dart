class Loan {
  final String id;
  final double amount;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double interestRate;
  final bool isActive;
  final bool isAnnuity;

  Loan({
    required this.id,
    required this.amount,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.interestRate,
    this.isActive = true,
    this.isAnnuity = true,
  });

  int get months {
    return ((endDate.difference(startDate).inDays) / 30).ceil();
  }

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      amount: json['amount'] as double,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      interestRate: json['interestRate'] as double,
      isActive: json['isActive'] == 1,
      isAnnuity: json['isAnnuity'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'interestRate': interestRate,
      'isActive': isActive ? 1 : 0,
      'isAnnuity': isAnnuity ? 1 : 0,
    };
  }

  Loan copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? interestRate,
    bool? isActive,
    bool? isAnnuity,
  }) {
    return Loan(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      interestRate: interestRate ?? this.interestRate,
      isActive: isActive ?? this.isActive,
      isAnnuity: isAnnuity ?? this.isAnnuity,
    );
  }
}
