class Credit {
  String id;
  String name;
  double amount;
  double interestRate;
  DateTime startDate;
  DateTime endDate;
  double monthlyPayment;
  bool isPaid;

  Credit({
    required this.id,
    required this.name,
    required this.amount,
    required this.interestRate,
    required this.startDate,
    required this.endDate,
    required this.monthlyPayment,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'interestRate': interestRate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'monthlyPayment': monthlyPayment,
      'isPaid': isPaid,
    };
  }

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      interestRate: json['interestRate'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      monthlyPayment: json['monthlyPayment'],
      isPaid: json['isPaid'],
    );
  }
} 