import 'sale_item.dart';

class Sale {
  final String id;
  final List<SaleItem> items;
  final double total;
  final DateTime date;
  final String note;
  final String user;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Sale({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.note,
    required this.user,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Map) {
        // Suponiendo que el mapa tiene una estructura con '$date' o algo similar
        if (dateValue.containsKey('\$date')) {
          return DateTime.parse(dateValue['\$date']);
        }
        // Alternativa si usa timestamp
        if (dateValue.containsKey('timestamp')) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue['timestamp']);
        }
      }
      // Si no puede ser analizado, devuelve la fecha actual
      return DateTime.now();
    }

    return Sale(
      id: json['_id'] ?? '',
      items: (json['items'] as List)
          .map((item) => SaleItem.fromJson(item))
          .toList(),
      total: (json['total'] as num).toDouble(),
      date: parseDate(json['date']),
      note: json['note'] ?? '',
      user: json['user'] ?? 'system',
      isDeleted: json['isDeleted'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
      'note': note,
      'user': user,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
