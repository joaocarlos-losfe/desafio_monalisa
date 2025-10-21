class Product {
  final int barCode;
  final String longDescription;
  final String shortDescription;
  final double price;
  final String branch;
  final int quantityInStock;

  Product({
    required this.barCode,
    required this.longDescription,
    required this.shortDescription,
    required this.price,
    required this.branch,
    required this.quantityInStock,
  });

  Product copyWith({int? quantityInStock}) {
    return Product(
      barCode: barCode,
      shortDescription: shortDescription,
      longDescription: longDescription,
      branch: branch,
      price: price,
      quantityInStock: quantityInStock ?? this.quantityInStock,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barCode: int.tryParse(json['CodigoBarras'].toString()) ?? 0,
      longDescription: json['DescricaoLonga'] ?? '',
      shortDescription: json['DescricaoCurta'] ?? '',
      price: double.tryParse(json['PrecoUnitario'].toString()) ?? 0,
      branch: json['Marca'] ?? '',
      quantityInStock: int.tryParse(json['SaldoEstoque'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CodigoBarras': barCode,
      'DescricaoLonga': longDescription,
      'DescricaoCurta': shortDescription,
      'PrecoUnitario': price,
      'Marca': branch,
      'SaldoEstoque': quantityInStock,
    };
  }
}
