class Sale {
  final int id;
  final DateTime date;
  final double total;
  final int totalItems;
  final Map<String, String> items;
  final String? paymentMethod;

  Sale({
    required this.id,
    required this.date,
    required this.total,
    required this.totalItems,
    required this.items,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'total': total,
    'totalItems': totalItems,
    'items': items,
    'paymentMethod': paymentMethod,
  };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: json['id'],
    date: DateTime.parse(json['date']),
    total: json['total'].toDouble(),
    totalItems: json['totalItems'],
    items: Map<String, String>.from(json['items']),
    paymentMethod: json['paymentMethod'],
  );

  factory Sale.fromCart(
    Map<int, int> cartItems,
    double totalValue,
    String? paymentMethod,
  ) {
    final items = <String, String>{};
    cartItems.forEach((barCode, qty) {
      items[barCode.toString()] = qty.toString();
    });
    return Sale(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now(),
      total: totalValue,
      totalItems: cartItems.values.fold(0, (sum, qty) => sum + qty),
      items: items,
      paymentMethod: paymentMethod,
    );
  }

  Map<int, int> get itemsAsInt =>
      items.map((key, value) => MapEntry(int.parse(key), int.parse(value)));
}
