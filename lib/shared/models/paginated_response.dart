import 'package:cssayp_movil/shared/models/pagination_links.dart';
import 'package:cssayp_movil/shared/models/pagination_meta.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.links, required this.meta});

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonModel) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>).map((item) => fromJsonModel(item as Map<String, dynamic>)).toList(),
      links: PaginationLinks.fromJson(json['links'] ?? {}),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}
