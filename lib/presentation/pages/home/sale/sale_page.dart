import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/sale.dart';
import 'package:desafio_monalisa/services/payment_metodod.dart';
import 'package:desafio_monalisa/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalePage extends StatefulWidget {
  const SalePage({super.key});

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final List<String> randomProductImages = [""];
  List<Product> _allProductsCache = [];

  List<Product> _products = [];
  final Map<int, int> _cartItems = {};

  double _totalSale = 0.0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isLoadingBrands = true;
  String _searchQuery = '';
  String? _selectedBranch;
  List<String> _brands = ['Todas'];
  final int _perPage = 12;
  Timer? _debounce;

  List<PaymentMethod> _paymentMethods = [];
  String? _selectedPaymentMethod;

  int get cartCount => _cartItems.values.fold(0, (sum, qty) => sum + qty);

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadPaymentMethods();
    _loadProducts();
    _loadAllProductsForCart();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final branches = await ProductService.getAvailableBrands();
      if (mounted) {
        setState(() {
          _brands = branches;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await PaymentMethodService.getPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _loadProducts({bool debounce = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await Future.delayed(Duration(milliseconds: debounce ? 300 : 0));

    try {
      final response = await ProductService.getProducts(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery,
        branch: _selectedBranch,
      );

      if (mounted) {
        setState(() {
          _products = response.data;
          _totalPages = response.totalPages;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await _loadProducts();
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_currentPage > 1 && !_isLoading) {
      _currentPage--;
      await _loadProducts();
    }
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadProducts();
  }

  void _addToCart(Product product) {
    final currentQty = _cartItems[product.barCode] ?? 0;
    if (currentQty >= product.quantityInStock) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem estoque suficiente!')),
        );
      }
      return;
    }

    setState(() {
      _cartItems[product.barCode] = currentQty + 1;
      _totalSale += product.price;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      final currentQty = _cartItems[product.barCode] ?? 0;
      if (currentQty > 1) {
        _cartItems[product.barCode] = currentQty - 1;
        _totalSale -= product.price;
      } else {
        _cartItems.remove(product.barCode);
        _totalSale -= product.price;
      }
    });
  }

  void _finalizeSale() async {
    if (_cartItems.isEmpty) return;
    if (_selectedPaymentMethod == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: Theme.of(ctx).cardTheme.shape,
          title: const Text('Erro'),
          content: const Text('Por favor, selecione uma forma de pagamento!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await _loadAllProductsForCart();

    final total = _totalSale;
    final soldItems = Map<int, int>.from(_cartItems);
    final totalItems = cartCount;
    final paymentMethod = _selectedPaymentMethod;

    final List<Product> updatedProducts = [];
    for (var entry in soldItems.entries) {
      final barCode = entry.key;
      final soldQty = entry.value;

      final product = _allProductsCache.firstWhere((p) => p.barCode == barCode);
      final newStock = product.quantityInStock - soldQty;

      await ProductService.updateProductStock(barCode, newStock);
      final updatedProduct = product.copyWith(quantityInStock: newStock);
      updatedProducts.add(updatedProduct);
    }

    await _saveSaleToHistory(total, soldItems, totalItems, paymentMethod);

    setState(() {
      for (int i = 0; i < _products.length; i++) {
        final oldProduct = _products[i];
        final updated = updatedProducts.firstWhere(
          (up) => up.barCode == oldProduct.barCode,
          orElse: () => oldProduct,
        );
        _products[i] = updated;
      }
      _cartItems.clear();
      _totalSale = 0.0;
      _selectedPaymentMethod = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Venda finalizada! Estoque atualizado. R\$ ${total.toStringAsFixed(2)}',
          ),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            textColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).cardColor,
            label: 'RELATÓRIO',
            onPressed: () =>
                _showSalesReport(total, soldItems, totalItems, paymentMethod),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showSalesReport(
    double total,
    Map<int, int> soldItems,
    int totalItems,
    String? paymentMethod,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: Theme.of(ctx).cardTheme.shape,
        title: Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: Theme.of(ctx).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('Relatório de Venda'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.9,
              ),
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
                    final product = _getProductByBarCode(entry.key)!;
                    final soldQty = entry.value;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 360;
                        if (isMobile) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.shortDescription,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$soldQty un | Estoque anterior: ${product.quantityInStock + soldQty}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const Divider(height: 8),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.shortDescription,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '$soldQty un | Estoque anterior: ${product.quantityInStock + soldQty}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 12),

                  const Text(
                    '📦 NOVO ESTOQUE:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  ...soldItems.entries.map((entry) {
                    final product = _getProductByBarCode(entry.key)!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.shortDescription,
                            style: const TextStyle(fontSize: 11),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSaleToHistory(
    double total,
    Map<int, int> soldItems,
    int totalItems,
    String? paymentMethod,
  ) async {
    final newSale = Sale.fromCart(soldItems, total, paymentMethod);

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('sales_history') ?? '[]';
      final List<dynamic> jsonList = json.decode(jsonString);
      jsonList.insert(0, newSale.toJson());

      await prefs.setString('sales_history', json.encode(jsonList));
      // ignore: empty_catches
    } catch (e) {}
  }

  Product? _getProductByBarCode(int barCode) {
    if (_allProductsCache.isEmpty) {
      _loadAllProductsForCart();
    }

    final globalMatch = _allProductsCache.where((p) => p.barCode == barCode);
    if (globalMatch.isNotEmpty) {
      return globalMatch.first;
    }

    final localMatch = _products.where((p) => p.barCode == barCode);
    if (localMatch.isNotEmpty) {
      return localMatch.first;
    }

    return null;
  }

  Future<void> _loadAllProductsForCart() async {
    if (_allProductsCache.isNotEmpty) return;

    try {
      final response = await ProductService.getProducts(
        page: 1,
        perPage: 999,
        search: '',
        branch: null,
      );
      _allProductsCache = response.data;
    } catch (e) {
      _allProductsCache = _products;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Platform.isAndroid || Platform.isIOS;

    final pageContent = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Código/Nome',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: Theme.of(
                      context,
                    ).inputDecorationTheme.contentPadding,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      _searchQuery = value;
                      _currentPage = 1;
                      _loadProducts();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              _isLoadingBrands
                  ? SizedBox(
                      width: 90,
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          value: _selectedBranch ?? 'Todas',
                          isExpanded: true,
                          iconSize: 16,
                          items: _brands
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b,
                                    style: Theme.of(
                                      context,
                                    ).dropdownMenuTheme.textStyle,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(
                              () => _selectedBranch = value == 'Todas'
                                  ? null
                                  : value,
                            );
                            _currentPage = 1;
                            _loadProducts();
                          },
                        ),
                      ),
                    ),
              if (cartCount > 0) ...[
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _showCartDialog,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('$cartCount'),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGridView(),
            ),
          ),
        ),
        if (_totalPages > 1) _buildPaginationControls(),
      ],
    );

    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        body: isMobile
            ? SafeArea(top: true, bottom: false, child: pageContent)
            : pageContent,
      ),
    );
  }

  Widget _buildGridView() {
    if (_hasError) {
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
              onPressed: _loadProducts,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    if (_products.isEmpty && !_isLoading) {
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
          itemCount: _products.length,
          itemBuilder: (context, index) {
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
              child: _buildProductCard(_products[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isOutOfStock = product.quantityInStock <= 0;
    final inCartQty = _cartItems[product.barCode] ?? 0;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showProductDetails(product),
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
                              _removeFromCart(product);
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
                              size: 28,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '$inCartQty',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            _addToCart(product);
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
                            size: 28,
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
                    Icon(Icons.block, size: 20, color: theme.colorScheme.error),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? _loadPreviousPage : null,
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            '$_currentPage / $_totalPages',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages ? _loadNextPage : null,
            icon: Icon(
              Icons.arrow_forward,
              size: 24,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx),
        child: AlertDialog(
          shape: Theme.of(ctx).cardTheme.shape,
          title: Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Theme.of(ctx).colorScheme.secondary,
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
            height: 380,
            child: _cartItems.isEmpty
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
                              itemCount: _cartItems.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (c, i) {
                                var entry = _cartItems.entries.elementAt(i);
                                final barCode = entry.key;
                                final qty = entry.value;

                                final product = _getProductByBarCode(barCode);
                                if (product == null) {
                                  return const SizedBox.shrink();
                                }

                                final subtotal = product.price * qty;

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final bool isCompact =
                                        constraints.maxWidth <
                                        360; // cosiderando o tamanho do modal ja com margens aplicadas
                                    final avatar = CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: .1),
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                    );

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setDialogState(() {});
                                            _removeFromCart(product);
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
                                            _addToCart(product);
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
                                            avatar,
                                            const SizedBox(height: 6),
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
                                        leading: SizedBox(
                                          width: 28,
                                          child: avatar,
                                        ),
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
                                                    _removeFromCart(product);
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
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$qty',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.secondary,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    setDialogState(() {});
                                                    _addToCart(product);
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                          if (_cartItems.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Forma de Pagamento',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _selectedPaymentMethod,
                              items: _paymentMethods.map((pm) {
                                return DropdownMenuItem<String>(
                                  value: pm.descricao,
                                  child: Text(pm.descricao),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  _selectedPaymentMethod = value;
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
                                  'R\$ ${_totalSale.toStringAsFixed(2)}',
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
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: cartCount > 0 ? _finalizeSale : null,
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
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx),
        child: AlertDialog(
          shape: Theme.of(ctx).cardTheme.shape,
          title: Text(product.shortDescription),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código: ${product.barCode}'),
              Text('Marca: ${product.branch}'),
              Text('Preço: R\$ ${product.price.toStringAsFixed(2)}'),
              Text('Estoque: ${product.quantityInStock} un'),
              Text('Descrição: ${product.longDescription}'),
            ],
          ),
          actions: [
            if (product.quantityInStock > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _addToCart(product);
                },
                child: const Text('Adicionar'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }
}
