class Service {
  int? id;
  String name;
  String? description;
  double price;
  String? createdAt;

  Service({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.createdAt,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'created_at': createdAt,
    };
  }
}
