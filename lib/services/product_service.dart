import 'dart:convert';
import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/product_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductService {
  static const String _jsonPath = 'assets/dataset/produtos.json';

  static Future<List<dynamic>> _loadFullJson() async {
    final response = await rootBundle.loadString(_jsonPath);
    return json.decode(response) as List<dynamic>;
  }

  static Future<ProductPaginationResponse<Product>> getProducts({
    int page = 1,
    int perPage = 10,
    String search = '',
    String? branch,
  }) async {
    final jsonData = await _loadFullJson();
    final allProducts = jsonData
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    List<Product> filteredProducts = allProducts;

    if (branch != null && branch.isNotEmpty && branch != 'Todas') {
      filteredProducts = allProducts
          .where((p) => p.branch.toLowerCase() == branch.toLowerCase())
          .toList();
    }

    if (search.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final query = search.toLowerCase();
        return product.barCode.toString().contains(query) ||
            product.shortDescription.toLowerCase().contains(query) ||
            product.longDescription.toLowerCase().contains(query) ||
            product.branch.toLowerCase().contains(query);
      }).toList();
    }

    final total = filteredProducts.length;
    final totalPages = (total / perPage).ceil();
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, total);
    final pageProducts = filteredProducts.sublist(startIndex, endIndex);

    return ProductPaginationResponse<Product>(
      data: pageProducts,
      currentPage: page,
      totalPages: totalPages,
      total: total,
      perPage: perPage,
    );
  }

  static Future<List<String>> getAvailableBrands() async {
    final jsonData = await _loadFullJson();
    final allProducts = jsonData
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    final branches =
        allProducts
            .map((p) => p.branch)
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    branches.insert(0, 'Todas');
    return branches;
  }

  static Future<void> updateProductStock(int barCode, int newStock) async {
    final jsonData = await _loadFullJson();
    final jsonList = List<Map<String, dynamic>>.from(jsonData);

    final productIndex = jsonList.indexWhere(
      (item) => item['bar_code'] == barCode,
    );

    if (productIndex != -1) {
      jsonList[productIndex]['quantity_in_stock'] = newStock;
      await _saveJsonToAssets(jsonList);
    }
  }

  static Future<void> _saveJsonToAssets(
    List<Map<String, dynamic>> updatedData,
  ) async {
    final String updatedJson = json.encode(updatedData);
    debugPrint('📦 ESTOQUE ATUALIZADO: ${updatedJson.length} bytes');
  }

  static Future<void> resetStock() async {
    final originalJson = await rootBundle.loadString(_jsonPath);
    final jsonList = json.decode(originalJson) as List<dynamic>;
    await _saveJsonToAssets(jsonList.cast<Map<String, dynamic>>());
  }
}
