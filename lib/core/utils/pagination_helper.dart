class PaginationHelper {
  static const int defaultPageSize = 20;
  
  static int calculateOffset(int page, int pageSize) {
    return (page - 1) * pageSize;
  }
  
  static int calculateTotalPages(int totalItems, int pageSize) {
    return (totalItems / pageSize).ceil();
  }
  
  static bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages;
  }
  
  static bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
  
  factory PaginatedResult.create({
    required List<T> items,
    required int currentPage,
    required int pageSize,
    required int totalItems,
  }) {
    final totalPages = PaginationHelper.calculateTotalPages(totalItems, pageSize);
    return PaginatedResult(
      items: items,
      currentPage: currentPage,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNext: PaginationHelper.hasNextPage(currentPage, totalPages),
      hasPrevious: PaginationHelper.hasPreviousPage(currentPage),
    );
  }
}