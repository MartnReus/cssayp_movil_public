import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para datos de creación de boleta de finalización
class BoletaFinDataState {
  final int? idBoletaInicio;
  final String? caratula;
  final int? expediente;
  final int? anio;
  final int? cuij;
  final DateTime? fechaRegulacion;
  final double? cantidadJus;
  final double? valorJus;
  final double? honorarios;
  final double? montoValido;

  const BoletaFinDataState({
    this.idBoletaInicio,
    this.caratula,
    this.expediente,
    this.anio,
    this.cuij,
    this.fechaRegulacion,
    this.cantidadJus,
    this.valorJus,
    this.honorarios,
    this.montoValido,
  });

  BoletaFinDataState copyWith({
    int? idBoletaInicio,
    String? caratula,
    int? expediente,
    int? anio,
    int? cuij,
    DateTime? fechaRegulacion,
    double? cantidadJus,
    double? valorJus,
    double? honorarios,
    double? montoValido,
  }) {
    return BoletaFinDataState(
      idBoletaInicio: idBoletaInicio ?? this.idBoletaInicio,
      caratula: caratula ?? this.caratula,
      expediente: expediente ?? this.expediente,
      anio: anio ?? this.anio,
      cuij: cuij ?? this.cuij,
      fechaRegulacion: fechaRegulacion ?? this.fechaRegulacion,
      cantidadJus: cantidadJus ?? this.cantidadJus,
      valorJus: valorJus ?? this.valorJus,
      honorarios: honorarios ?? this.honorarios,
      montoValido: montoValido ?? this.montoValido,
    );
  }

  bool get isValid => caratula != null && fechaRegulacion != null && cantidadJus != null;

  bool get isValidForStep1 => idBoletaInicio != null && caratula != null;
  bool get isValidForStep2 => fechaRegulacion != null && cantidadJus != null;
  bool get isValidForStep3 => isValid && honorarios != null && montoValido != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoletaFinDataState &&
        other.idBoletaInicio == idBoletaInicio &&
        other.caratula == caratula &&
        other.expediente == expediente &&
        other.anio == anio &&
        other.cuij == cuij &&
        other.fechaRegulacion == fechaRegulacion &&
        other.cantidadJus == cantidadJus &&
        other.valorJus == valorJus &&
        other.honorarios == honorarios &&
        other.montoValido == montoValido;
  }

  @override
  int get hashCode {
    return idBoletaInicio.hashCode ^
        caratula.hashCode ^
        expediente.hashCode ^
        anio.hashCode ^
        cuij.hashCode ^
        fechaRegulacion.hashCode ^
        cantidadJus.hashCode ^
        valorJus.hashCode ^
        honorarios.hashCode ^
        montoValido.hashCode;
  }

  @override
  String toString() {
    return 'BoletaFinDataState('
        'idBoletaInicio: $idBoletaInicio, '
        'caratula: $caratula, '
        'expediente: $expediente, '
        'anio: $anio, '
        'cuij: $cuij, '
        'fechaRegulacion: $fechaRegulacion, '
        'cantidadJus: $cantidadJus, '
        'valorJus: $valorJus, '
        'honorarios: $honorarios, '
        'montoValido: $montoValido)';
  }
}

/// Notifier para datos de creación de boleta de finalización
class BoletaFinDataNotifier extends Notifier<BoletaFinDataState> {
  @override
  BoletaFinDataState build() {
    return const BoletaFinDataState();
  }

  void updateIdBoletaInicio(int idBoletaInicio) {
    state = state.copyWith(idBoletaInicio: idBoletaInicio);
  }

  void updateCaratula(String caratula) {
    state = state.copyWith(caratula: caratula);
  }

  void updateExpediente(int? expediente) {
    state = state.copyWith(expediente: expediente);
  }

  void updateAnio(int? anio) {
    state = state.copyWith(anio: anio);
  }

  void updateCuij(int? cuij) {
    state = state.copyWith(cuij: cuij);
  }

  void updateFechaRegulacion(DateTime fechaRegulacion) {
    state = state.copyWith(fechaRegulacion: fechaRegulacion);
  }

  void updateCantidadJus(double cantidadJus) {
    state = state.copyWith(cantidadJus: cantidadJus);
  }

  void updateValorJus(double valorJus) {
    state = state.copyWith(valorJus: valorJus);
  }

  void updateHonorarios(double honorarios) {
    state = state.copyWith(honorarios: honorarios);
  }

  void updateMontoValido(double montoValido) {
    state = state.copyWith(montoValido: montoValido);
  }

  void reset() {
    state = const BoletaFinDataState();
  }

  void updateStep1Data({required int idBoletaInicio, required String caratula, int? expediente, int? anio, int? cuij}) {
    state = state.copyWith(
      idBoletaInicio: idBoletaInicio,
      caratula: caratula,
      expediente: expediente,
      anio: anio,
      cuij: cuij,
    );
  }

  void updateStep2Data({
    required DateTime fechaRegulacion,
    required double cantidadJus,
    required double valorJus,
    required double honorarios,
    required double montoValido,
  }) {
    state = state.copyWith(
      fechaRegulacion: fechaRegulacion,
      cantidadJus: cantidadJus,
      valorJus: valorJus,
      honorarios: honorarios,
      montoValido: montoValido,
    );
  }
}

final boletaFinDataProvider = NotifierProvider<BoletaFinDataNotifier, BoletaFinDataState>(
  () => BoletaFinDataNotifier(),
);
