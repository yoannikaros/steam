class Customer {
  int? id;
  String name;
  String? phone;
  String? motorType;
  String? plateNumber;
  String? createdAt;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.motorType,
    this.plateNumber,
    this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      motorType: map['motor_type'],
      plateNumber: map['plate_number'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'motor_type': motorType,
      'plate_number': plateNumber,
      'created_at': createdAt,
    };
  }
}
