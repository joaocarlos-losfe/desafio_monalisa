import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/sale.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/widgets/cart_dialog.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/widgets/pagination_controls.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/widgets/product_grid.dart';
import 'package:desafio_monalisa/presentation/pages/home/sale/widgets/sales_report_dialog.dart';
import 'package:desafio_monalisa/services/payment_metodod.dart';
import 'package:desafio_monalisa/services/product_service.dart';
import 'package:flutter/material.dart';
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
      builder: (ctx) => SalesReportDialog(
        total: total,
        soldItems: soldItems,
        totalItems: totalItems,
        paymentMethod: paymentMethod,
        getProductByBarCode: _getProductByBarCode,
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
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => CartDialog(
                      cartItems: _cartItems,
                      totalSale: _totalSale,
                      paymentMethods: _paymentMethods,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      getProductByBarCode: _getProductByBarCode,
                      onAddToCart: _addToCart,
                      onRemoveFromCart: _removeFromCart,
                      onFinalizeSale: _finalizeSale,
                      onPaymentMethodChanged: (value) {
                        setState(() => _selectedPaymentMethod = value);
                      },
                    ),
                  ),
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
              child: ProductGrid(
                products: _products,
                isLoading: _isLoading,
                hasError: _hasError,
                onRetry: _loadProducts,
                onAddToCart: _addToCart,
                onRemoveFromCart: _removeFromCart,
                cartItems: _cartItems,
                onProductTap: (product) => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
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
              ),
            ),
          ),
        ),
        if (_totalPages > 1)
          PaginationControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onNextPage: _loadNextPage,
            onPreviousPage: _loadPreviousPage,
          ),
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
}
