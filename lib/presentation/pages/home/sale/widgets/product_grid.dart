import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final void Function(Product) onAddToCart;
  final void Function(Product) onRemoveFromCart;
  final Map<int, int> cartItems;
  final void Function(Product) onProductTap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.cartItems,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            const Text('Erro ao carregar produtos'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (isLoading && products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    if (products.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            const Text('Nenhum produto encontrado'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double width = constraints.maxWidth;

        if (width < 500) {
          crossAxisCount = 2; // mobile
        } else if (width < 900) {
          crossAxisCount = 2; // tablet
        } else {
          crossAxisCount = 3; // desktop
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: width < 500
                ? 0.8
                : width < 900
                ? 1.5
                : 1.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Animate(
              effects: [
                FadeEffect(duration: 400.ms, delay: (100 * index).ms),
                SlideEffect(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                  duration: 400.ms,
                  delay: (100 * index).ms,
                  curve: Curves.easeOut,
                ),
              ],
              child: ProductCard(
                product: product,
                inCartQty: cartItems[product.barCode] ?? 0,
                onTap: () => onProductTap(product),
                onAddToCart: () => onAddToCart(product),
                onRemoveFromCart: () => onRemoveFromCart(product),
              ),
            );
          },
        );
      },
    );
  }
}
