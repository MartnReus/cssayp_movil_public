import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/usecases/login_use_case.dart';
import 'package:cssayp_movil/auth/domain/usecases/verificar_estado_autenticacion_use_case.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de autenticación que incluye el usuario y el estado
class AuthState {
  final AuthStatus status;
  final UsuarioEntity? usuario;

  const AuthState({required this.status, this.usuario});

  AuthState copyWith({AuthStatus? status, UsuarioEntity? usuario}) {
    return AuthState(status: status ?? this.status, usuario: usuario ?? this.usuario);
  }
}

/// Provider principal de autenticación
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final VerificarEstadoAutenticacionUseCase _verificarEstadoUseCase;
  late final LoginUseCase _loginUseCase;
  late final UsuarioRepository _usuarioRepository;

  @override
  Future<AuthState> build() async {
    _verificarEstadoUseCase = await ref.read(verificarEstadoAutenticacionUseCaseProvider.future);
    _loginUseCase = await ref.read(loginUseCaseProvider.future);
    _usuarioRepository = await ref.read(usuarioRepositoryProvider.future);

    return _verificarEstadoInicial();
  }

  Future<AuthState> _verificarEstadoInicial() async {
    try {
      final status = await _verificarEstadoUseCase.execute();

      UsuarioEntity? usuario;
      if (status != AuthStatus.noAutenticado) {
        usuario = await _usuarioRepository.obtenerUsuarioActual();
      }

      return AuthState(status: status, usuario: usuario);
    } catch (e) {
      return const AuthState(status: AuthStatus.noAutenticado);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _loginUseCase.execute(username, password);

      return await _verificarEstadoInicial();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _usuarioRepository.cerrarSesion();
      return const AuthState(status: AuthStatus.noAutenticado, usuario: null);
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _verificarEstadoInicial();
    });
  }

  Future<bool> getBiometriaHabilitada() async {
    final preferenciasRepo = await ref.read(preferenciasRepositoryProvider.future);
    return preferenciasRepo.obtenerPreferenciaBiometria();
  }

  Future<void> actualizarPreferenciaBiometria(bool habilitada) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final preferenciasRepo = await ref.read(preferenciasRepositoryProvider.future);
      await preferenciasRepo.guardarPreferenciaBiometria(habilitada);

      return await _verificarEstadoInicial();
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

//--------- Use cases ----------------
final verificarEstadoAutenticacionUseCaseProvider = FutureProvider<VerificarEstadoAutenticacionUseCase>(
  (ref) async => VerificarEstadoAutenticacionUseCase(
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
    preferenciasRepository: await ref.read(preferenciasRepositoryProvider.future),
  ),
);

final loginUseCaseProvider = FutureProvider<LoginUseCase>(
  (ref) async => LoginUseCase(usuarioRepository: await ref.read(usuarioRepositoryProvider.future)),
);
//--------------------------------
