class PaginatedResponseModel {
  final int statusCode;
  final List<Map<String, dynamic>> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedResponseModel({
    required this.statusCode,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginatedResponseModel.fromJson(int statusCode, Map<String, dynamic> json) {
    return PaginatedResponseModel(
      statusCode: statusCode,
      data: (json['data'] as List).cast<Map<String, dynamic>>(),
      currentPage: json['meta']['current_page'],
      lastPage: json['meta']['last_page'],
      total: json['meta']['total'],
      perPage: json['meta']['per_page'],
    );
  }
}
