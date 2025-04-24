class SaleItem {
  final String product;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  // Añade este método para poder copiar y modificar items
  SaleItem copyWith({
    String? product,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return SaleItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  // Métodos toJson y fromJson si los necesitas
  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
  var productData = json['product'] as Map<String, dynamic>;
  return SaleItem(
    product: productData['_id'], // Accede al ID dentro del objeto producto
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}
}