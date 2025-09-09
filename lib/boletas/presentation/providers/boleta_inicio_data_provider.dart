import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para datos de creación de boleta de inicio
class BoletaInicioDataState {
  final String? actor;
  final String? demandado;
  final String? causa;

  const BoletaInicioDataState({this.actor, this.demandado, this.causa});

  BoletaInicioDataState copyWith({String? actor, String? demandado, String? causa}) {
    return BoletaInicioDataState(
      actor: actor ?? this.actor,
      demandado: demandado ?? this.demandado,
      causa: causa ?? this.causa,
    );
  }

  bool get isValid => actor != null && demandado != null && causa != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoletaInicioDataState &&
        other.actor == actor &&
        other.demandado == demandado &&
        other.causa == causa;
  }

  @override
  int get hashCode => actor.hashCode ^ demandado.hashCode ^ causa.hashCode;

  @override
  String toString() {
    return 'BoletaInicioDataState(actor: $actor, demandado: $demandado, causa: $causa)';
  }
}

/// Notifier para datos de creación de boleta de inicio
class BoletaInicioDataNotifier extends Notifier<BoletaInicioDataState> {
  @override
  BoletaInicioDataState build() {
    return const BoletaInicioDataState();
  }

  void updateActor(String actor) {
    state = state.copyWith(actor: actor);
  }

  void updateDemandado(String demandado) {
    state = state.copyWith(demandado: demandado);
  }

  void updateCausa(String causa) {
    state = state.copyWith(causa: causa);
  }

  void reset() {
    state = const BoletaInicioDataState();
  }

  /// Método de conveniencia para actualizar múltiples campos a la vez
  void updateFields({String? actor, String? demandado, String? causa}) {
    state = state.copyWith(actor: actor, demandado: demandado, causa: causa);
  }
}

final boletaInicioDataProvider = NotifierProvider<BoletaInicioDataNotifier, BoletaInicioDataState>(
  () => BoletaInicioDataNotifier(),
);
