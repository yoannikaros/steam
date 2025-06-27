class Payment {
  int? id;
  int orderId;
  double amount;
  String? method;
  String paymentDate;
  String? note;

  Payment({
    this.id,
    required this.orderId,
    required this.amount,
    this.method,
    required this.paymentDate,
    this.note,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      orderId: map['order_id'],
      amount: map['amount'],
      method: map['method'],
      paymentDate: map['payment_date'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'method': method,
      'payment_date': paymentDate,
      'note': note,
    };
  }
}
