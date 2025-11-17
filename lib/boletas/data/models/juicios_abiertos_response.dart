import 'package:cssayp_movil/boletas/data/models/juicio_model.dart';

class JuiciosAbiertosPaginatedResponse {
  final int statusCode;
  final List<JuicioModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  JuiciosAbiertosPaginatedResponse({
    required this.statusCode,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory JuiciosAbiertosPaginatedResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return JuiciosAbiertosPaginatedResponse(
      statusCode: statusCode,
      data: (json['data'] as List).map((item) => JuicioModel.fromJson(item)).toList(),
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      total: json['total'] as int,
      perPage: json['per_page'] as int,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPreviousPage => prevPageUrl != null;
}
