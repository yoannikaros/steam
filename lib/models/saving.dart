class Saving {
  int? id;
  String type;
  double amount;
  String? description;
  String date;
  String? createdAt;

  Saving({
    this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.createdAt,
  });

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: map['date'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
      'created_at': createdAt,
    };
  }
}
