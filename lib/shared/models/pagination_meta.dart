class PaginationMeta {
  final int currentPage;
  final int? from;
  final int? lastPage;
  final String path;
  final int perPage;
  final int? to;
  final int? total;

  PaginationMeta({
    required this.currentPage,
    this.from,
    this.lastPage,
    required this.path,
    required this.perPage,
    this.to,
    this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      to: json['to'],
      total: json['total'],
    );
  }
}
