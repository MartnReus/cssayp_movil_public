import 'package:cssayp_movil/auth/domain/usecases/cambiar_password_use_case.dart';
import 'package:cssayp_movil/shared/exceptions/password_exceptions.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para el proceso de cambio de contraseña
class CambiarPasswordState {
  final bool isSuccess;

  const CambiarPasswordState({this.isSuccess = false});

  CambiarPasswordState copyWith({bool? isSuccess}) {
    return CambiarPasswordState(isSuccess: isSuccess ?? this.isSuccess);
  }
}

/// Provider dedicado al cambio de contraseñas
class CambiarPasswordNotifier extends AsyncNotifier<CambiarPasswordState> {
  late final CambiarPasswordUseCase _cambiarPasswordUseCase;

  @override
  Future<CambiarPasswordState> build() async {
    _cambiarPasswordUseCase = await ref.read(cambiarPasswordUseCaseProvider.future);
    return const CambiarPasswordState();
  }

  Future<void> cambiarPassword(String passwordActual, String passwordNueva) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final responseModel = await _cambiarPasswordUseCase.execute(passwordActual, passwordNueva);
      if (responseModel.estado == false) {
        throw IncorrectPasswordException(responseModel.mensaje);
      } else {
        return const CambiarPasswordState(isSuccess: true);
      }
    });
  }

  /// Reinicia el estado del provider
  void reset() {
    state = const AsyncData(CambiarPasswordState());
  }
}

/// Provider principal para cambio de contraseñas
final cambiarPasswordProvider = AsyncNotifierProvider<CambiarPasswordNotifier, CambiarPasswordState>(
  () => CambiarPasswordNotifier(),
);

/// Use case provider para cambiar contraseña
final cambiarPasswordUseCaseProvider = FutureProvider<CambiarPasswordUseCase>(
  (ref) async => CambiarPasswordUseCase(usuarioRepository: await ref.read(usuarioRepositoryProvider.future)),
);
