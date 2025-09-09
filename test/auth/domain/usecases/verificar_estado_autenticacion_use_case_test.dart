import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/repositories/preferencias_repository.dart';
import 'package:cssayp_movil/auth/domain/usecases/verificar_estado_autenticacion_use_case.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'verificar_estado_autenticacion_use_case_test.mocks.dart';

@GenerateMocks([UsuarioRepository, PreferenciasRepository])
void main() {
  group("Funcion de verificar estado de autenticacion (execute)", () {
    late VerificarEstadoAutenticacionUseCase verificarEstadoUseCase;
    late MockUsuarioRepository mockUsuarioRepository;
    late MockPreferenciasRepository mockPreferenciasRepository;

    setUp(() {
      mockUsuarioRepository = MockUsuarioRepository();
      mockPreferenciasRepository = MockPreferenciasRepository();

      verificarEstadoUseCase = VerificarEstadoAutenticacionUseCase(
        usuarioRepository: mockUsuarioRepository,
        preferenciasRepository: mockPreferenciasRepository,
      );
    });

    test("execute debe retornar AuthStatus.noAutenticado cuando el usuario no esta autenticado", () async {
      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => false);

      final result = await verificarEstadoUseCase.execute();

      expect(result, equals(AuthStatus.noAutenticado));
      verify(mockUsuarioRepository.estaAutenticado()).called(1);
      verifyNever(mockPreferenciasRepository.obtenerPreferenciaBiometria());
    });

    test(
      "execute debe retornar AuthStatus.autenticadoRequiereBiometria cuando el usuario esta autenticado y la biometria esta habilitada",
      () async {
        when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
        when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => true);

        final result = await verificarEstadoUseCase.execute();

        expect(result, equals(AuthStatus.autenticadoRequiereBiometria));
        verify(mockUsuarioRepository.estaAutenticado()).called(1);
        verify(mockPreferenciasRepository.obtenerPreferenciaBiometria()).called(1);
      },
    );

    test(
      "execute debe retornar AuthStatus.autenticadoNoRequiereBiometria cuando el usuario esta autenticado y la biometria esta deshabilitada",
      () async {
        when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
        when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

        final result = await verificarEstadoUseCase.execute();

        expect(result, equals(AuthStatus.autenticadoNoRequiereBiometria));
        verify(mockUsuarioRepository.estaAutenticado()).called(1);
        verify(mockPreferenciasRepository.obtenerPreferenciaBiometria()).called(1);
      },
    );

    test("execute debe lanzar la excepcion original si ocurre un error inesperado en el repository", () async {
      when(mockUsuarioRepository.estaAutenticado()).thenThrow(Exception('Error inesperado'));

      expect(() async => await verificarEstadoUseCase.execute(), throwsA(isA<Exception>()));
      verify(mockUsuarioRepository.estaAutenticado()).called(1);
      verifyNever(mockPreferenciasRepository.obtenerPreferenciaBiometria());
    });
  });
}
