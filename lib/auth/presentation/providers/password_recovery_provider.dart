import 'package:cssayp_movil/auth/domain/usecases/recuperar_password_use_case.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado para el proceso de recuperación de contraseña
class PasswordRecoveryState {
  final bool isSuccess;

  const PasswordRecoveryState({this.isSuccess = false});

  PasswordRecoveryState copyWith({bool? isSuccess}) {
    return PasswordRecoveryState(isSuccess: isSuccess ?? this.isSuccess);
  }
}

/// Provider dedicado a la recuperación de contraseñas
class PasswordRecoveryNotifier extends AsyncNotifier<PasswordRecoveryState> {
  RecuperarPasswordUseCase? _recuperarUseCase;

  @override
  Future<PasswordRecoveryState> build() async {
    _recuperarUseCase = await ref.read(recuperarPasswordUseCaseProvider.future);
    return const PasswordRecoveryState();
  }

  /// Inicia el proceso de recuperación de contraseña
  Future<void> recuperarPassword(String dniOrNroAfiliado, String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _recuperarUseCase!.execute(dniOrNroAfiliado, email);
      return const PasswordRecoveryState(isSuccess: true);
    });
  }

  /// Reinicia el estado del provider
  void reset() {
    state = const AsyncData(PasswordRecoveryState());
  }
}

/// Provider principal para recuperación de contraseñas
final passwordRecoveryProvider = AsyncNotifierProvider<PasswordRecoveryNotifier, PasswordRecoveryState>(
  () => PasswordRecoveryNotifier(),
);

/// Use case provider para recuperación de contraseñas
final recuperarPasswordUseCaseProvider = FutureProvider<RecuperarPasswordUseCase>(
  (ref) async => RecuperarPasswordUseCase(usuarioRepository: await ref.read(usuarioRepositoryProvider.future)),
);
