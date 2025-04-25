
class PaginationResult<T> {
  final List<T> products;
  final int totalProducts;
  final int totalPages;
  final int currentPage;
  final int limit;

  PaginationResult({
    required this.products,
    required this.totalProducts,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });
}