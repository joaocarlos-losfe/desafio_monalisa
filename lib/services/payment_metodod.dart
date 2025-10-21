import 'dart:convert';
import 'package:flutter/services.dart';

class PaymentMethod {
  final int id;
  final String descricao;

  PaymentMethod({required this.id, required this.descricao});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(id: json['Id'], descricao: json['Descricao']);
  }
}

class PaymentMethodService {
  static const String _jsonPath = 'assets/dataset/formasPagamento.json';

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await rootBundle.loadString(_jsonPath);
    final List<dynamic> jsonList = json.decode(response);
    return jsonList
        .map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
