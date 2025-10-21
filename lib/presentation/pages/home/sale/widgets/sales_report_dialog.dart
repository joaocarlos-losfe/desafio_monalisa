import 'package:desafio_monalisa/data/model/product.dart';
import 'package:flutter/material.dart';

class SalesReportDialog extends StatelessWidget {
  final double total;
  final Map<int, int> soldItems;
  final int totalItems;
  final String? paymentMethod;
  final Product? Function(int) getProductByBarCode;

  const SalesReportDialog({
    super.key,
    required this.total,
    required this.soldItems,
    required this.totalItems,
    required this.paymentMethod,
    required this.getProductByBarCode,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      shape: Theme.of(context).cardTheme.shape,
      title: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          const Text('Relatório de Venda'),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6,
          minHeight: 200,
          minWidth: screenWidth * 0.5,
          maxWidth: screenWidth * 0.8,
        ),
        child: Scrollbar(
          thumbVisibility: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data: ${DateTime.now().toString().substring(0, 16)}'),
                Text(
                  'Forma de Pagamento: ${paymentMethod ?? 'Não especificada'}',
                ),
                Text('Total: R\$ ${total.toStringAsFixed(2)}'),
                Text('Itens: $totalItems'),
                const Divider(),
                const Text(
                  '🛒 ITENS VENDIDOS:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...soldItems.entries.map((entry) {
                  final product = getProductByBarCode(entry.key)!;
                  final soldQty = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.shortDescription,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$soldQty un | Estoque anterior: ${product.quantityInStock + soldQty}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  '📦 NOVO ESTOQUE:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...soldItems.entries.map((entry) {
                  final product = getProductByBarCode(entry.key)!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.shortDescription,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${product.quantityInStock} un',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  '✅ Venda processada com sucesso!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
