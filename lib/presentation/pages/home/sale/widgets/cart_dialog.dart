import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/services/payment_metodod.dart';
import 'package:flutter/material.dart';

class CartDialog extends StatelessWidget {
  final Map<int, int> cartItems;
  final double totalSale;
  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentMethod;
  final Product? Function(int) getProductByBarCode;
  final void Function(Product) onAddToCart;
  final void Function(Product) onRemoveFromCart;
  final VoidCallback onFinalizeSale;
  final void Function(String?) onPaymentMethodChanged;

  const CartDialog({
    super.key,
    required this.cartItems,
    required this.totalSale,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.getProductByBarCode,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onFinalizeSale,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: Theme.of(context).cardTheme.shape,
        title: Row(
          children: [
            Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Carrinho',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text('Carrinho vazio'),
                    ],
                  ),
                )
              : StatefulBuilder(
                  builder: (context, setDialogState) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: cartItems.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (c, i) {
                              var entry = cartItems.entries.elementAt(i);
                              final barCode = entry.key;
                              final qty = entry.value;

                              final product = getProductByBarCode(barCode);
                              if (product == null) {
                                return const SizedBox.shrink();
                              }

                              final subtotal = product.price * qty;

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final bool isCompact =
                                      constraints.maxWidth < 360;

                                  final priceText = Text(
                                    'R\$ ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  );

                                  final qtyControls = Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setDialogState(() {});
                                          onRemoveFromCart(product);
                                        },
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 14,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '$qty',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setDialogState(() {});
                                          onAddToCart(product);
                                        },
                                        icon: const Icon(Icons.add, size: 14),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'R\$ ${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  );

                                  if (isCompact) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.shortDescription,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          priceText,
                                          const SizedBox(height: 8),
                                          qtyControls,
                                        ],
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                      dense: true,
                                      minVerticalPadding: 0,

                                      title: Text(
                                        product.shortDescription,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          priceText,
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setDialogState(() {});
                                                  onRemoveFromCart(product);
                                                },
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 20,
                                                      minHeight: 20,
                                                    ),
                                              ),
                                              Container(
                                                width: 28,
                                                height: 24,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '$qty',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setDialogState(() {});
                                                  onAddToCart(product);
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 20,
                                                      minHeight: 20,
                                                    ),
                                              ),
                                              const SizedBox(width: 4),
                                              SizedBox(
                                                width: 48,
                                                child: Text(
                                                  'R\$ ${subtotal.toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        if (cartItems.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Forma de Pagamento',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedPaymentMethod,
                            items: paymentMethods.map((pm) {
                              return DropdownMenuItem<String>(
                                value: pm.descricao,
                                child: Text(pm.descricao),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                onPaymentMethodChanged(value);
                              });
                            },
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'R\$ ${totalSale.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: cartItems.isNotEmpty ? onFinalizeSale : null,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Finalizar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
