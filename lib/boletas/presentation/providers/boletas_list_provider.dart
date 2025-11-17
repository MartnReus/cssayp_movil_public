import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';

class BoletasState {
  final List<BoletaEntity> boletas;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final bool isOfflineData;
  final DateTime? lastSyncTime;

  const BoletasState({
    this.boletas = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 10,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.isOfflineData = false,
    this.lastSyncTime,
  });

  BoletasState copyWith({
    List<BoletaEntity>? boletas,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    bool? hasNextPage,
    bool? hasPreviousPage,
    bool? isOfflineData,
    DateTime? lastSyncTime,
  }) {
    return BoletasState(
      boletas: boletas ?? this.boletas,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      isOfflineData: isOfflineData ?? this.isOfflineData,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class BoletasNotifier extends AsyncNotifier<BoletasState> {
  late final ObtenerHistorialBoletasUseCase _obtenerHistorialBoletasUseCase;
  late final GenerarBoletaInicioUseCase _generarBoletaInicioUseCase;
  late final GenerarBoletaFinalizacionUseCase _generarBoletaFinalizacionUseCase;
  late final BuscarBoletasInicioPagadasUseCase _buscarBoletasInicioPagadasUseCase;
  late final BoletasLocalDataSource _boletasLocalDataSource;

  @override
  Future<BoletasState> build() async {
    _obtenerHistorialBoletasUseCase = await ref.read(obtenerHistorialBoletasUseCaseProvider.future);
    _generarBoletaInicioUseCase = await ref.read(generarBoletaInicioUseCaseProvider.future);
    _generarBoletaFinalizacionUseCase = await ref.read(generarBoletaFinalizacionUseCaseProvider.future);
    _buscarBoletasInicioPagadasUseCase = await ref.read(buscarBoletasInicioPagadasUseCaseProvider.future);
    _boletasLocalDataSource = ref.read(boletasLocalDataSourceProvider);

    ref.listen(connectivityProvider, (previous, current) {
      if (current.value == null || previous?.value == current.value) {
        return;
      }
      _handleConnectivityChange(previous?.value, current.value!);
    });

    state = const AsyncValue.data(BoletasState());
    await obtenerBoletasCreadas(page: 1);

    return state.value!;
  }

  Future<void> obtenerBoletasCreadas({int? page, bool forceRefresh = false, String filtroEstado = 'todas'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isOnline = ref.read(connectivityProvider).value == ConnectivityStatus.online;
      final currentPage = page ?? 1;

      if (!forceRefresh && !isOnline) {
        return await _getFromLocalCache(page: currentPage);
      }

      if (isOnline) {
        try {
          final response = await _obtenerHistorialBoletasUseCase.execute(page: currentPage, filtroEstado: filtroEstado);

          final boletas = response.boletas.map((boletaModel) => _convertirBoletaHistorialAEntity(boletaModel)).toList();

          if (currentPage == 1) {
            await _boletasLocalDataSource.guardarBoletas(boletas);
          }

          return BoletasState(
            boletas: boletas,
            isLoading: false,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            total: response.total,
            perPage: response.perPage,
            hasNextPage: response.nextPageUrl != null,
            hasPreviousPage: response.prevPageUrl != null,
            isOfflineData: false,
            lastSyncTime: DateTime.now(),
          );
        } catch (e) {
          final hasCache = await _boletasLocalDataSource.tieneBoletasEnCache();
          if (hasCache) {
            print('API failed, falling back to cache: $e');
            return await _getFromLocalCache(page: currentPage);
          }
          rethrow;
        }
      } else {
        return await _getFromLocalCache(page: currentPage);
      }
    });
  }

  /// Método específico para la pantalla de pagos que oculta las boletas pagadas
  Future<void> obtenerBoletasParaPagar({int? page, bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isOnline = ref.read(connectivityProvider).value == ConnectivityStatus.online;
      final currentPage = page ?? 1;

      if (!forceRefresh && !isOnline) {
        return await _getFromLocalCache(page: currentPage);
      }

      if (isOnline) {
        try {
          final response = await _obtenerHistorialBoletasUseCase.execute(page: currentPage, filtroEstado: 'no_pagadas');

          final boletas = response.boletas.map((boletaModel) => _convertirBoletaHistorialAEntity(boletaModel)).toList();

          return BoletasState(
            boletas: boletas,
            isLoading: false,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            total: response.total,
            perPage: response.perPage,
            hasNextPage: response.nextPageUrl != null,
            hasPreviousPage: response.prevPageUrl != null,
            isOfflineData: false,
            lastSyncTime: DateTime.now(),
          );
        } catch (e) {
          final hasCache = await _boletasLocalDataSource.tieneBoletasEnCache();
          if (hasCache) {
            print('API failed, falling back to cache: $e');
            return await _getFromLocalCache(page: currentPage);
          }
          rethrow;
        }
      } else {
        return await _getFromLocalCache(page: currentPage);
      }
    });
  }

  Future<void> irAPagina(int page) async {
    if (page < 1) return;
    await obtenerBoletasCreadas(page: page);
  }

  Future<void> irAPaginaSiguiente() async {
    final currentState = state.value;
    if (currentState != null && currentState.hasNextPage) {
      await irAPagina(currentState.currentPage + 1);
    }
  }

  Future<void> irAPaginaAnterior() async {
    final currentState = state.value;
    if (currentState != null && currentState.hasPreviousPage) {
      await irAPagina(currentState.currentPage - 1);
    }
  }

  BoletaEntity _convertirBoletaHistorialAEntity(BoletaHistorialModel model) {
    return BoletaEntity(
      id: int.tryParse(model.idBoletaGenerada) ?? 0,
      tipo: BoletaTipo.fromId(int.tryParse(model.idTipoTransaccion ?? '0') ?? 0),
      monto: double.tryParse(model.monto) ?? 0.0,
      fechaImpresion: _parseFechaImpresion(model.fechaImpresion),
      fechaVencimiento: _calcularFechaVencimiento(model.fechaImpresion, model.diasVencimiento),
      codBarra: model.codBarra,
      caratula: model.caratula,
      fechaPago: model.fechaPago != null && model.fechaPago!.isNotEmpty ? _parseFechaImpresion(model.fechaPago!) : null,
      gastosAdministrativos: model.gastosAdministrativos != null ? double.tryParse(model.gastosAdministrativos!) : null,
      estado: model.estado,
    );
  }

  BoletaEntity _convertirBoletaInicioPagadaAEntity(BoletaInicioPagadaModel model) {
    return BoletaEntity(
      id: int.tryParse(model.id) ?? 0,
      tipo: BoletaTipo.inicio,
      monto: double.tryParse(model.monto) ?? 0.0,
      fechaImpresion: _parseFechaImpresion(model.fechaImpresion),
      fechaVencimiento: _calcularFechaVencimiento(model.fechaImpresion, model.diasVencimiento),
      caratula: model.caratula,
    );
  }

  DateTime _parseFechaImpresion(String? fecha) {
    if (fecha == null || fecha.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(fecha.replaceAll('_', ' '));
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _calcularFechaVencimiento(String? fechaImpresion, String? diasVencimiento) {
    final fechaBase = _parseFechaImpresion(fechaImpresion);
    final dias = int.tryParse(diasVencimiento ?? '') ?? 30;
    return fechaBase.add(Duration(days: dias));
  }

  Future<CrearBoletaInicioResult?> crearBoletaInicio({
    required String caratula,
    required String juzgado,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
  }) async {
    state = const AsyncValue.loading();
    try {
      final resultado = await _generarBoletaInicioUseCase.execute(
        caratula: caratula,
        juzgado: juzgado,
        circunscripcion: circunscripcion,
        tipoJuicio: tipoJuicio,
      );

      await refresh();

      return resultado;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<BoletaEntity?> crearBoletaFin({required BoletaFinDataState boletaFinData}) async {
    state = const AsyncValue.loading();
    try {
      final boleta = await _generarBoletaFinalizacionUseCase.execute(
        idBoletaInicio: boletaFinData.idBoletaInicio!,
        monto: boletaFinData.montoValido!,
        fechaRegulacion: boletaFinData.fechaRegulacion!,
        honorarios: boletaFinData.honorarios!,
        caratula: boletaFinData.caratula!,
        cantidadJus: boletaFinData.cantidadJus!,
        valorJus: boletaFinData.valorJus!,
        nroExpediente: boletaFinData.expediente,
        anioExpediente: boletaFinData.anio,
        cuij: boletaFinData.cuij,
      );

      await refresh();

      return boleta;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> buscarBoletasInicioPagadas({int page = 1, String? caratulaBuscada}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _buscarBoletasInicioPagadasUseCase.execute(page: page, caratulaBuscada: caratulaBuscada);
      print(response);
      return BoletasState(
        boletas: response.data
            .map((boletaModel) => _convertirBoletaInicioPagadaAEntity(BoletaInicioPagadaModel.fromJson(boletaModel)))
            .toList(),
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        perPage: response.perPage,
        hasNextPage: response.currentPage < response.lastPage,
        hasPreviousPage: response.currentPage > 1,
      );
    });
  }

  Future<void> refresh() async {
    final currentState = state.value;
    final currentPage = currentState?.currentPage ?? 1;
    await obtenerBoletasCreadas(page: currentPage, forceRefresh: true);
  }

  Future<BoletasState> _getFromLocalCache({int page = 1}) async {
    const perPage = 10;
    final offset = (page - 1) * perPage;

    final boletas = await _boletasLocalDataSource.obtenerBoletasLocales(limit: perPage, offset: offset);

    final total = await _boletasLocalDataSource.obtenerConteoBoletasLocales();
    final lastPage = (total / perPage).ceil();
    final lastSync = await _boletasLocalDataSource.obtenerUltimaSincronizacion();

    return BoletasState(
      boletas: boletas,
      isLoading: false,
      currentPage: page,
      lastPage: lastPage > 0 ? lastPage : 1,
      total: total,
      perPage: perPage,
      hasNextPage: page < lastPage,
      hasPreviousPage: page > 1,
      isOfflineData: true,
      lastSyncTime: lastSync,
    );
  }

  Future<void> syncCache() async {
    final isOnline = ref.read(connectivityProvider).value == ConnectivityStatus.online;
    if (!isOnline) return;
    await obtenerBoletasCreadas(page: 1, forceRefresh: true);
  }

  void _handleConnectivityChange(ConnectivityStatus? previous, ConnectivityStatus current) {
    if (previous == ConnectivityStatus.offline && current == ConnectivityStatus.online) {
      print('📶 Connectivity restored - auto-syncing boletas...');

      Future.microtask(() async {
        final hasCache = await _boletasLocalDataSource.tieneBoletasEnCache();
        if (hasCache) {
          await syncCache();
        }
      });
    }
  }
}

final boletasProvider = AsyncNotifierProvider<BoletasNotifier, BoletasState>(() => BoletasNotifier());
