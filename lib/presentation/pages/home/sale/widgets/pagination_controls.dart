import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: currentPage > 1 ? onPreviousPage : null,
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            '$currentPage / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? onNextPage : null,
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
}
