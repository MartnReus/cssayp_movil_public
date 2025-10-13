import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

/// Estado para datos de creación de boleta de inicio
class BoletaInicioDataState {
  final ParametrosBoletaInicioEntity parametrosBoletaInicio;
  final String? actor;
  final String? demandado;
  final String? causa;
  final String? juzgado;
  final TipoJuicioEntity? tipoJuicio;
  final CircunscripcionEntity? circunscripcion;

  const BoletaInicioDataState({
    required this.parametrosBoletaInicio,
    this.actor,
    this.demandado,
    this.causa,
    this.juzgado,
    this.tipoJuicio,
    this.circunscripcion,
  });

  BoletaInicioDataState copyWith({
    ParametrosBoletaInicioEntity? parametrosBoletaInicio,
    String? actor,
    String? demandado,
    String? causa,
    String? juzgado,
    TipoJuicioEntity? tipoJuicio,
    CircunscripcionEntity? circunscripcion,
  }) {
    return BoletaInicioDataState(
      parametrosBoletaInicio: parametrosBoletaInicio ?? this.parametrosBoletaInicio,
      actor: actor ?? this.actor,
      demandado: demandado ?? this.demandado,
      causa: causa ?? this.causa,
      juzgado: juzgado ?? this.juzgado,
      tipoJuicio: tipoJuicio ?? this.tipoJuicio,
      circunscripcion: circunscripcion ?? this.circunscripcion,
    );
  }

  bool get isValid =>
      actor != null &&
      demandado != null &&
      causa != null &&
      juzgado != null &&
      tipoJuicio != null &&
      circunscripcion != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoletaInicioDataState &&
        other.actor == actor &&
        other.demandado == demandado &&
        other.causa == causa &&
        other.juzgado == juzgado &&
        other.tipoJuicio == tipoJuicio &&
        other.circunscripcion == circunscripcion;
  }

  @override
  int get hashCode =>
      actor.hashCode ^
      demandado.hashCode ^
      causa.hashCode ^
      juzgado.hashCode ^
      tipoJuicio.hashCode ^
      circunscripcion.hashCode;

  @override
  String toString() {
    return 'BoletaInicioDataState(actor: $actor, demandado: $demandado, causa: $causa, juzgado: $juzgado, tipoJuicio: ${tipoJuicio?.id}, circunscripcion: ${circunscripcion?.id})';
  }
}

/// Notifier para datos de creación de boleta de inicio
class BoletaInicioDataNotifier extends AsyncNotifier<BoletaInicioDataState> {
  late final ObtenerParametrosBoletaInicioUseCase _obtenerParametrosBoletaInicioUseCase;

  @override
  Future<BoletaInicioDataState> build() async {
    _obtenerParametrosBoletaInicioUseCase = await ref.read(obtenerParametrosBoletaInicioUseCaseProvider.future);
    final parametrosBoletaInicio = await _obtenerParametrosBoletaInicioUseCase.execute();
    return BoletaInicioDataState(parametrosBoletaInicio: parametrosBoletaInicio);
  }

  void updateActor(String actor) {
    state = AsyncValue.data(state.value!.copyWith(actor: actor));
  }

  void updateDemandado(String demandado) {
    state = AsyncValue.data(state.value!.copyWith(demandado: demandado));
  }

  void updateCausa(String causa) {
    state = AsyncValue.data(state.value!.copyWith(causa: causa));
  }

  void updateTipoJuicio(TipoJuicioEntity tipoJuicio) {
    state = AsyncValue.data(state.value!.copyWith(tipoJuicio: tipoJuicio));
  }

  void updateCircunscripcion(CircunscripcionEntity circunscripcion) {
    state = AsyncValue.data(state.value!.copyWith(circunscripcion: circunscripcion));
  }

  void updateJuzgado(String juzgado) {
    state = AsyncValue.data(state.value!.copyWith(juzgado: juzgado));
  }

  void reset() async {
    final parametrosBoletaInicio = _obtenerParametrosBoletaInicioUseCase.execute();
    state = AsyncValue.data(BoletaInicioDataState(parametrosBoletaInicio: await parametrosBoletaInicio));
  }

  /// Método de conveniencia para actualizar múltiples campos a la vez
  void updateFields({
    String? actor,
    String? demandado,
    String? causa,
    String? juzgado,
    TipoJuicioEntity? tipoJuicio,
    CircunscripcionEntity? circunscripcion,
  }) {
    state = AsyncValue.data(
      state.value!.copyWith(
        actor: actor,
        demandado: demandado,
        causa: causa,
        juzgado: juzgado,
        tipoJuicio: tipoJuicio,
        circunscripcion: circunscripcion,
      ),
    );
  }
}

final boletaInicioDataProvider = AsyncNotifierProvider<BoletaInicioDataNotifier, BoletaInicioDataState>(
  () => BoletaInicioDataNotifier(),
);
