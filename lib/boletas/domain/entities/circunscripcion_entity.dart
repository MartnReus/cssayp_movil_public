class CircunscripcionEntity {
  final String id;
  final String descripcion;

  CircunscripcionEntity({required this.id, required this.descripcion});

  factory CircunscripcionEntity.fromJson(Map<String, dynamic> json) {
    return CircunscripcionEntity(id: json['id']?.toString() ?? '', descripcion: json['descripcion']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion};
  }

  List<String> toArray() {
    return [id, descripcion];
  }
}
