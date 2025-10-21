import 'dart:convert';
import 'dart:io';
import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/product_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ProductService {
  static const String _assetsJsonPath = 'assets/dataset/produtos.json';
  static const String _fileName = 'produtos.json';

  static Future<File> _getJsonFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<List<dynamic>> _loadJsonData() async {
    final file = await _getJsonFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return json.decode(jsonString) as List<dynamic>;
    } else {
      final response = await rootBundle.loadString(_assetsJsonPath);
      final jsonData = json.decode(response) as List<dynamic>;
      await _saveJsonToFile(jsonData);
      return jsonData;
    }
  }

  static Future<void> _saveJsonToFile(List<dynamic> jsonData) async {
    final file = await _getJsonFile();
    final jsonString = json.encode(jsonData);
    await file.writeAsString(jsonString);
    debugPrint('📦 PRODUTOS ATUALIZADOS: ${jsonString.length} bytes');
  }

  static Future<ProductPaginationResponse<Product>> getProducts({
    int page = 1,
    int perPage = 10,
    String search = '',
    String? branch,
  }) async {
    final jsonData = await _loadJsonData();
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
    final jsonData = await _loadJsonData();
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
    final jsonData = await _loadJsonData();
    final jsonList = List<Map<String, dynamic>>.from(jsonData);

    final productIndex = jsonList.indexWhere(
      (item) => item['CodigoBarras'] == barCode,
    );

    if (productIndex != -1) {
      jsonList[productIndex]['SaldoEstoque'] = newStock;
    }

    await _saveJsonToFile(jsonList);
  }

  static Future<void> addOrUpdateProducts(List<Product> newProducts) async {
    final jsonData = await _loadJsonData();
    final jsonList = List<Map<String, dynamic>>.from(jsonData);

    final existingBarCodes = jsonList
        .map((item) => int.tryParse(item['CodigoBarras'].toString()) ?? 0)
        .toSet();

    for (var product in newProducts) {
      final barCode = product.barCode;
      final productJson = product.toJson();

      if (existingBarCodes.contains(barCode)) {
        final productIndex = jsonList.indexWhere(
          (item) => item['CodigoBarras'] == barCode,
        );
        if (productIndex != -1) {
          jsonList[productIndex] = productJson;
        }
      } else {
        jsonList.add(productJson);
      }
    }

    await _saveJsonToFile(jsonList);
  }

  static Future<void> resetStock() async {
    final file = await _getJsonFile();
    List<dynamic> jsonData;

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      jsonData = json.decode(jsonString) as List<dynamic>;
    } else {
      final response = await rootBundle.loadString(_assetsJsonPath);
      jsonData = json.decode(response) as List<dynamic>;
    }

    final originalResponse = await rootBundle.loadString(_assetsJsonPath);
    final originalJsonData = json.decode(originalResponse) as List<dynamic>;
    final originalStockMap = {
      for (var item in originalJsonData)
        item['CodigoBarras']: item['SaldoEstoque'],
    };

    final updatedJsonData = jsonData.map((item) {
      final barCode = item['CodigoBarras'];
      return {
        ...item,
        'SaldoEstoque': originalStockMap[barCode] ?? item['SaldoEstoque'],
      };
    }).toList();

    await _saveJsonToFile(updatedJsonData);
  }
}
