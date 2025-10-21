import 'dart:convert';
import 'dart:io';

import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/sale.dart';
import 'package:desafio_monalisa/services/product_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  bool _isLoading = false;

  Future<void> _importJsonFile() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Use file_picker to select a JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          _showErrorDialog('Nenhum arquivo selecionado.');
        }
        setState(() => _isLoading = false);
        return;
      }

      // Read the selected file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      // Determine if the JSON is for products or sales history
      if (jsonData is List && jsonData.isNotEmpty) {
        if (jsonData.first.containsKey('CodigoBarras')) {
          // Handle product data
          await _importProducts(jsonData);
        } else if (jsonData.first.containsKey('id') &&
            jsonData.first.containsKey('date')) {
          // Handle sales history
          await _importSalesHistory(jsonData);
        } else {
          if (mounted) {
            _showErrorDialog('Formato de arquivo JSON inválido.');
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog('Arquivo JSON vazio ou inválido.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao importar arquivo: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importProducts(List<dynamic> jsonData) async {
    try {
      final products = jsonData
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      // Add or update products in the service
      await ProductService.addOrUpdateProducts(products);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${products.length} produtos importados/atualizados com sucesso!',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao importar produtos: $e');
      }
    }
  }

  Future<void> _importSalesHistory(List<dynamic> jsonData) async {
    try {
      final newSales = jsonData.map((json) => Sale.fromJson(json)).toList();
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString('sales_history') ?? '[]';
      final List<dynamic> existingSales = json.decode(existingJson);

      final existingIds = existingSales.map((s) => s['id']).toSet();
      final uniqueNewSales = newSales
          .where((sale) => !existingIds.contains(sale.id))
          .map((sale) => sale.toJson())
          .toList();

      final updatedSales = [...uniqueNewSales, ...existingSales];
      await prefs.setString('sales_history', json.encode(updatedSales));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${uniqueNewSales.length} vendas importadas com sucesso!',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao importar histórico de vendas: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    debugPrint(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: Theme.of(ctx).cardTheme.shape,
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Dados')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.file_download, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Selecione um arquivo JSON para importar produtos ou histórico de vendas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _importJsonFile,
              icon: const Icon(Icons.file_open),
              label: const Text('Selecionar Arquivo JSON'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
