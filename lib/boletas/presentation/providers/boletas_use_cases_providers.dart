import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

//--------- Use Cases Providers ----------------

final obtenerHistorialBoletasUseCaseProvider = FutureProvider<ObtenerHistorialBoletasUseCase>(
  (ref) async => ObtenerHistorialBoletasUseCase(
    boletasRepository: await ref.read(boletasRepositoryProvider.future),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  ),
);

final obtenerParametrosBoletaInicioUseCaseProvider = FutureProvider<ObtenerParametrosBoletaInicioUseCase>(
  (ref) async => ObtenerParametrosBoletaInicioUseCase(
    boletasRepository: await ref.read(boletasRepositoryProvider.future),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  ),
);

final generarBoletaInicioUseCaseProvider = FutureProvider<GenerarBoletaInicioUseCase>(
  (ref) async => GenerarBoletaInicioUseCase(
    boletasRepository: await ref.read(boletasRepositoryProvider.future),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  ),
);

final generarBoletaFinalizacionUseCaseProvider = FutureProvider<GenerarBoletaFinalizacionUseCase>(
  (ref) async => GenerarBoletaFinalizacionUseCase(
    boletasRepository: await ref.read(boletasRepositoryProvider.future),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  ),
);

final buscarBoletasInicioPagadasUseCaseProvider = FutureProvider<BuscarBoletasInicioPagadasUseCase>(
  (ref) async => BuscarBoletasInicioPagadasUseCase(
    boletasRepository: await ref.read(boletasRepositoryProvider.future),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  ),
);
