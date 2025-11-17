import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/juicios_repository.dart';
import 'package:cssayp_movil/auth/auth.dart';

class JuiciosState {
  final List<JuicioEntity> juicios;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const JuiciosState({
    this.juicios = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 20,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  JuiciosState copyWith({
    List<JuicioEntity>? juicios,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return JuiciosState(
      juicios: juicios ?? this.juicios,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}

class JuiciosNotifier extends AsyncNotifier<JuiciosState> {
  late final JuiciosRepository juiciosRepository;

  @override
  Future<JuiciosState> build() async {
    juiciosRepository = await ref.read(juiciosRepositoryProvider.future);
    
    // Load juicios on initialization
    state = const AsyncValue.data(JuiciosState());
    await cargarJuicios(page: 1);

    return state.value ?? const JuiciosState();
  }

  Future<void> cargarJuicios({int page = 1}) async {
    try {
      // Get the user's nroAfiliado
      final authState = await ref.read(authProvider.future);
      final user = authState.usuario;

      if (user == null) {
        state = AsyncValue.data(
          (state.value ?? const JuiciosState()).copyWith(isLoading: false, error: 'Usuario no autenticado'),
        );
        return;
      }

      // Set loading state
      state = AsyncValue.data((state.value ?? const JuiciosState()).copyWith(isLoading: true, error: null));

      // Fetch juicios from repository
      final juicios = await juiciosRepository.obtenerJuiciosActivos(user.nroAfiliado, page: page);

      // Update state with juicios
      // Note: The API doesn't return pagination metadata in the response we have,
      // but we can estimate it based on the results
      state = AsyncValue.data(
        JuiciosState(
          juicios: juicios,
          isLoading: false,
          error: null,
          currentPage: page,
          lastPage: page, // Will be updated when we get proper pagination
          total: juicios.length,
          perPage: 20,
          hasNextPage: juicios.length >= 20,
          hasPreviousPage: page > 1,
        ),
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? const JuiciosState()).copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> nextPage() async {
    final currentState = state.value;
    if (currentState != null && currentState.hasNextPage && !currentState.isLoading) {
      await cargarJuicios(page: currentState.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    final currentState = state.value;
    if (currentState != null && currentState.hasPreviousPage && !currentState.isLoading) {
      await cargarJuicios(page: currentState.currentPage - 1);
    }
  }

  Future<void> refresh() async {
    await cargarJuicios(page: 1);
  }
}

final juiciosProvider = AsyncNotifierProvider<JuiciosNotifier, JuiciosState>(() => JuiciosNotifier());
