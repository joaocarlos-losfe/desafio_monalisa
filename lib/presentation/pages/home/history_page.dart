import 'dart:convert';
import 'package:desafio_monalisa/data/model/product.dart';
import 'package:desafio_monalisa/data/model/sale.dart';
import 'package:desafio_monalisa/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Sale> _sales = [];
  List<Product> _allProductsCache = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadSalesHistory(), _loadAllProducts()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadSalesHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('sales_history');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final sales = jsonList.map((json) => Sale.fromJson(json)).toList();
        if (mounted) setState(() => _sales = sales.toList());
      }
    } catch (_) {}
  }

  Future<void> _loadAllProducts() async {
    try {
      final response = await ProductService.getProducts(
        page: 1,
        perPage: 999,
        search: '',
        branch: null,
      );
      if (mounted) setState(() => _allProductsCache = response.data);
    } catch (_) {}
  }

  Product? _getProductByBarCode(String barCodeStr) {
    try {
      final barCode = int.parse(barCodeStr);
      for (final p in _allProductsCache) {
        if (p.barCode == barCode) return p;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Sale> get _filteredSales {
    if (_searchQuery.isEmpty) return _sales;
    final query = _searchQuery.toLowerCase();
    return _sales.where((sale) {
      if (sale.date.toString().toLowerCase().contains(query)) return true;
      if (sale.total.toString().contains(query)) return true;
      for (var entry in sale.items.entries) {
        final product = _getProductByBarCode(entry.key);
        if (product?.shortDescription.toLowerCase().contains(query) == true) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Widget _themedCircularAvatar({
    required Widget child,
    double radius = 20,
    Color? background,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        background ??
        (isDark
            ? theme.colorScheme.primaryContainer.withAlpha(64)
            : theme.colorScheme.primaryContainer.withAlpha(230));

    return CircleAvatar(radius: radius, backgroundColor: bgColor, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico (${_sales.length})'),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () => setState(() => _searchQuery = ''),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquisar venda, produto ou data',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          _buildStatsSection(theme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSales.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];
                      return Animate(
                        delay: (100 * index).ms,
                        effects: const [
                          FadeEffect(),
                          SlideEffect(begin: Offset(0, 0.2)),
                        ],
                        child: _buildSaleCard(sale, theme),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final totalSalesValue = _sales.fold(0.0, (s, e) => s + e.total);
    final totalItems = _sales.fold(0, (s, e) => s + e.totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      'Vendas',
                      '${_sales.length}',
                      Icons.receipt_long,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildStatCard(
                      'R\$ Total',
                      'R\$ ${totalSalesValue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildStatCard(
                      'Itens',
                      '$totalItems',
                      Icons.shopping_bag_outlined,
                      theme: theme,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: _getMaxY(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: _getMaxY() / 5,
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _getMaxY() / 5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            'R\$ ${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildLineChartSpots(
                      (sale) => sale.total,
                      extraDays: 2,
                    ), // <- 2 dias extra
                    isCurved: true,
                    color: Theme.of(context).colorScheme.secondary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.3),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - spot.x.toInt()),
                        );
                        return LineTooltipItem(
                          '${date.day}/${date.month}\nR\$ ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    final today = DateTime.now();
    double max = 0;
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      double total = _sales
          .where(
            (s) =>
                s.date.year == date.year &&
                s.date.month == date.month &&
                s.date.day == date.day,
          )
          .fold(0.0, (prev, s) => prev + s.total);
      if (total > max) max = total;
    }
    return max == 0 ? 10 : max * 1.2;
  }

  List<FlSpot> _buildLineChartSpots(
    double Function(Sale) valueSelector, {
    int extraDays = 0,
  }) {
    final today = DateTime.now();
    List<FlSpot> spots = [];
    for (int i = 6; i >= -extraDays; i--) {
      final date = today.subtract(Duration(days: i));
      double total = _sales
          .where(
            (s) =>
                s.date.year == date.year &&
                s.date.month == date.month &&
                s.date.day == date.day,
          )
          .fold(0.0, (prev, s) => prev + valueSelector(s));
      spots.add(FlSpot(6 - i.toDouble(), total));
    }
    return spots;
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhuma venda registrada ainda'
                : 'Nenhum resultado encontrado',
            style: const TextStyle(fontSize: 17, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Sale sale, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: theme.colorScheme.surface,
        collapsedBackgroundColor: theme.colorScheme.surface,
        leading: _themedCircularAvatar(
          child: Text(
            '${sale.date.day.toString().padLeft(2, '0')}\n${sale.date.month.toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          'R\$ ${sale.total.toStringAsFixed(2)}  ${sale.paymentMethod != null ? "| ${sale.paymentMethod}" : ""}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${sale.totalItems} itens • ${sale.date.toString().substring(11, 16)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        children: [
          Column(
            children: sale.items.entries.map((entry) {
              final product = _getProductByBarCode(entry.key);
              final qty = int.tryParse(entry.value) ?? 0;
              if (product == null) {
                return _buildItemRow(
                  title: 'Produto ID: ${entry.key}',
                  subtitle: 'ERRO: Produto não encontrado',
                  quantity: qty,
                  price: 0,
                  valid: false,
                );
              }
              final subtotal = product.price * qty;
              return _buildItemRow(
                title: product.shortDescription,
                subtitle: 'R\$ ${product.price.toStringAsFixed(2)}',
                quantity: qty,
                price: subtotal,
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'TOTAL: R\$ ${sale.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String title,
    required String subtitle,
    required int quantity,
    required double price,
    bool valid = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = valid
        ? (isDark
              ? theme.colorScheme.primaryContainer.withAlpha(64)
              : theme.colorScheme.primaryContainer.withAlpha(230))
        : Colors.red.shade100;
    final textColor = valid
        ? theme.colorScheme.onPrimaryContainer
        : Colors.redAccent.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _themedCircularAvatar(
            radius: 16,
            background: bgColor,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: valid
                        ? theme.colorScheme.onSurfaceVariant
                        : Colors.redAccent.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valid ? 'R\$ ${price.toStringAsFixed(2)}' : '--',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valid
                  ? theme.colorScheme.secondary
                  : Colors.redAccent.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
