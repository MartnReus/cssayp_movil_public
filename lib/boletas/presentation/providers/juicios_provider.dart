import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/juicios_repository.dart';

class JuiciosState {
  final List<JuicioEntity> juicios;

  const JuiciosState({this.juicios = const []});

  JuiciosState copyWith({List<JuicioEntity>? juicios}) {
    return JuiciosState(juicios: juicios ?? this.juicios);
  }
}

class JuiciosProvider extends StateNotifier<JuiciosState> {
  final JuiciosRepository juiciosRepository;

  JuiciosProvider({required this.juiciosRepository}) : super(JuiciosState());

  Future<List<JuicioEntity>> obtenerListadoJuicios() async {
    try {
      final juicios = await juiciosRepository.obtenerJuiciosActivos(0);
      state = state.copyWith(juicios: juicios);
      return juicios;
    } catch (e) {
      state = state.copyWith(juicios: []);
      return [];
    }
  }
}
