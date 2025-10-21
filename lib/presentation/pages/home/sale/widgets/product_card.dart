import 'package:desafio_monalisa/data/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int inCartQty;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.inCartQty,
    required this.onTap,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.quantityInStock <= 0;
    final theme = Theme.of(context);

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        SlideEffect(
          begin: Offset(0, 1),
          end: Offset(0, 0),
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inCartQty > 0
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: inCartQty > 0 ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.shortDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            product.branch,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.inventory,
                            size: 12,
                            color: isOutOfStock
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                          Text(
                            ' ${product.quantityInStock}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isOutOfStock
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isOutOfStock)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (inCartQty > 0)
                            IconButton(
                              onPressed: () {
                                onRemoveFromCart();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.shortDescription} removido!',
                                    ),
                                    duration: const Duration(milliseconds: 800),
                                    backgroundColor: theme.colorScheme.error,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 24,
                                color: theme.colorScheme.secondary,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'Remover',
                            ),
                          if (inCartQty > 0)
                            Text(
                              '$inCartQty',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              onAddToCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.shortDescription} adicionado!',
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                  backgroundColor: theme.colorScheme.secondary,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 24,
                              color: theme.colorScheme.secondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'Adicionar',
                          ),
                        ],
                      )
                    else
                      Icon(
                        Icons.block,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
