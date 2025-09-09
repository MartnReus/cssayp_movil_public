import 'boleta_historial_model.dart';

sealed class HistorialBoletasResponse {
  final int statusCode;

  const HistorialBoletasResponse({required this.statusCode});
}

class HistorialBoletasSuccessResponse extends HistorialBoletasResponse {
  final int currentPage;
  final List<BoletaHistorialModel> boletas;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const HistorialBoletasSuccessResponse({
    required super.statusCode,
    required this.currentPage,
    required this.boletas,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory HistorialBoletasSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return HistorialBoletasSuccessResponse(
      statusCode: statusCode,
      currentPage: json['current_page'],
      boletas: (json['data'] as List).map((boletaJson) => BoletaHistorialModel.fromJson(boletaJson)).toList(),
      lastPage: json['last_page'],
      total: json['total'],
      perPage: int.parse(json['per_page'].toString()),
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'current_page': currentPage,
      'data': boletas.map((boleta) => boleta.toJson()).toList(),
      'last_page': lastPage,
      'total': total,
      'per_page': perPage,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
    };
  }
}

class HistorialBoletasErrorResponse extends HistorialBoletasResponse {
  final String errorMessage;

  const HistorialBoletasErrorResponse({required super.statusCode, required this.errorMessage});

  factory HistorialBoletasErrorResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return HistorialBoletasErrorResponse(
      statusCode: statusCode,
      errorMessage: json['errorMessage'] ?? 'Error al obtener historial de boletas',
    );
  }

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'errorMessage': errorMessage};
  }
}
