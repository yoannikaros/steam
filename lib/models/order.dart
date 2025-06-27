class Order {
  int? id;
  int? customerId;
  int serviceId;
  String date;
  String time;
  double? totalPrice;
  String status;
  int isPaid;
  String? notes;
  String? createdAt;

  Order({
    this.id,
    this.customerId,
    required this.serviceId,
    required this.date,
    required this.time,
    this.totalPrice,
    this.status = 'waiting',
    this.isPaid = 0,
    this.notes,
    this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerId: map['customer_id'],
      serviceId: map['service_id'],
      date: map['date'],
      time: map['time'],
      totalPrice: map['total_price'],
      status: map['status'],
      isPaid: map['is_paid'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'date': date,
      'time': time,
      'total_price': totalPrice,
      'status': status,
      'is_paid': isPaid,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
