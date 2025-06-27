class Transaction {
  int? id;
  String type;
  String? category;
  double amount;
  String? description;
  String transactionDate;
  String? createdAt;

  Transaction({
    this.id,
    required this.type,
    this.category,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      transactionDate: map['transaction_date'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate,
      'created_at': createdAt,
    };
  }
}
