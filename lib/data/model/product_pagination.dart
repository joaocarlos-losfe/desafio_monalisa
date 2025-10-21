class ProductPaginationResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int total;
  final int perPage;

  ProductPaginationResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.perPage,
  });
}
