import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/comprobantes/comprobantes.dart';

class ComprobantesState {
  final ComprobanteEntity comprobante;

  ComprobantesState({required this.comprobante});

  ComprobantesState copyWith({ComprobanteEntity? comprobante}) {
    return ComprobantesState(comprobante: comprobante ?? this.comprobante);
  }
}

class ComprobantesNotifier extends AsyncNotifier<ComprobantesState> {
  @override
  Future<ComprobantesState> build() async {
    return ComprobantesState(
      comprobante: ComprobanteEntity(id: 0, fecha: "", externalReferenceId: "", importe: "0", boletasPagadas: []),
    );
  }

  Future<void> obtenerComprobante(int idBoletaPagada) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final obtenerComprobanteUseCase = await ref.read(obtenerComprobanteUseCaseProvider.future);
      final comprobante = await obtenerComprobanteUseCase.execute(idBoletaPagada);

      if (state.value == null) {
        return ComprobantesState(comprobante: comprobante);
      }

      return state.value!.copyWith(comprobante: comprobante);
    });
  }
}
