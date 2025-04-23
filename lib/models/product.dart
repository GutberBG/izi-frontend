class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final DateTime? expirationDate;
  final String? image;
  final String? supplier;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.expirationDate,
    this.image,
    this.supplier,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      category: json['category'],
      expirationDate: json['expirationDate'] != null ? DateTime.parse(json['expirationDate']) : null,
      image: json['image'],
      supplier: json['supplier'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'expirationDate': expirationDate?.toIso8601String(),
      'image': image,
      'supplier': supplier,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
