class Report {
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final double totalRevenue;
  final List<ProductSold> productsSold;
  final DateTime? reportDate;
  final String user;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalRevenue,
    required this.productsSold,
    this.reportDate,
    required this.user,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      productsSold: (json['productsSold'] as List)
          .map((e) => ProductSold.fromJson(e))
          .toList(),
      reportDate: json['reportDate'] != null ? DateTime.parse(json['reportDate']) : null,
      user: json['user'] ?? 'system',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'productsSold': productsSold.map((e) => e.toJson()).toList(),
      'reportDate': reportDate?.toIso8601String(),
      'user': user,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ProductSold {
  final String productId;
  final String productName;
  final int quantity;
  final double total;

  ProductSold({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.total,
  });

  factory ProductSold.fromJson(Map<String, dynamic> json) {
    return ProductSold(
      productId: json['productId'] ?? '',
      productName: json['productName'],
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'total': total,
    };
  }
}
