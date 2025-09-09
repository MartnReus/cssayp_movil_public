import 'package:cssayp_movil/auth/data/mappers/cambiar_password_response_mapper.dart';
import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:test/test.dart';

void main() {
  group('CambiarPasswordResponseMapper', () {
    group('fromApiResponse', () {
      test('debe retornar CambiarPasswordSuccessResponse cuando statusCode es 200 y estado es true', () {
        final result = CambiarPasswordResponseMapper.fromApiResponse(200, {
          'estado': true,
          'mensaje': 'Contraseña cambiada exitosamente',
        });

        expect(result, isA<CambiarPasswordSuccessResponse>());
        expect((result as CambiarPasswordSuccessResponse).estado, equals(true));
        expect(result.statusCode, equals(200));
        expect(result.mensaje, equals('Contraseña cambiada exitosamente'));
      });

      test(
        'debe retornar CambiarPasswordSuccessResponse con mensaje por defecto cuando estado es true y mensaje está vacío',
        () {
          final result = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': true, 'mensaje': ''});

          expect(result, isA<CambiarPasswordSuccessResponse>());
          expect(
            (result as CambiarPasswordSuccessResponse).mensaje,
            equals('Se asignó correctamente la nueva contraseña'),
          );
        },
      );

      test('debe retornar CambiarPasswordInvalidCredentialsResponse cuando statusCode es 200 y estado es false', () {
        final result = CambiarPasswordResponseMapper.fromApiResponse(200, {
          'estado': false,
          'mensaje': 'Contraseña actual incorrecta',
        });

        expect(result, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect((result as CambiarPasswordInvalidCredentialsResponse).estado, equals(false));
        expect(result.statusCode, equals(200));
        expect(result.mensaje, equals('Contraseña actual incorrecta'));
      });

      test(
        'debe retornar CambiarPasswordInvalidCredentialsResponse con mensaje por defecto cuando estado es false y mensaje está vacío',
        () {
          final result = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': false, 'mensaje': ''});

          expect(result, isA<CambiarPasswordInvalidCredentialsResponse>());
          expect(
            (result as CambiarPasswordInvalidCredentialsResponse).mensaje,
            equals('La contraseña actual es incorrecta'),
          );
        },
      );

      test('debe retornar CambiarPasswordGenericErrorResponse cuando statusCode no es 200', () {
        final result = CambiarPasswordResponseMapper.fromApiResponse(500, {
          'estado': true,
          'mensaje': 'Error interno del servidor',
        });

        expect(result, isA<CambiarPasswordGenericErrorResponse>());
        expect((result as CambiarPasswordGenericErrorResponse).estado, equals(false));
        expect(result.statusCode, equals(500));
        expect(result.mensaje, equals('Error interno del servidor'));
      });

      test(
        'debe retornar CambiarPasswordGenericErrorResponse con mensaje por defecto cuando statusCode no es 200 y mensaje está vacío',
        () {
          final result = CambiarPasswordResponseMapper.fromApiResponse(400, {'estado': true, 'mensaje': ''});

          expect(result, isA<CambiarPasswordGenericErrorResponse>());
          expect(
            (result as CambiarPasswordGenericErrorResponse).mensaje,
            equals('Error inesperado al cambiar la contraseña'),
          );
        },
      );
    });

    group('parseo de diferentes tipos de estado', () {
      test('debe parsear bool correctamente', () {
        final resultTrue = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': true});
        final resultFalse = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': false});

        expect(resultTrue, isA<CambiarPasswordSuccessResponse>());
        expect((resultTrue as CambiarPasswordSuccessResponse).estado, equals(true));

        expect(resultFalse, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect((resultFalse as CambiarPasswordInvalidCredentialsResponse).estado, equals(false));
      });

      test('debe parsear string "1" y "true" como true, otros como false', () {
        final resultString1 = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "1"});
        final resultStringTrue = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "true"});
        final resultStringTrueUpper = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "TRUE"});
        final resultString0 = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "0"});
        final resultStringFalse = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "false"});
        final resultStringOther = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': "cualquier_cosa"});

        expect(resultString1, isA<CambiarPasswordSuccessResponse>());
        expect(resultStringTrue, isA<CambiarPasswordSuccessResponse>());
        expect(resultStringTrueUpper, isA<CambiarPasswordSuccessResponse>());
        expect(resultString0, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultStringFalse, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultStringOther, isA<CambiarPasswordInvalidCredentialsResponse>());
      });

      test('debe parsear int 1 como true y otros como false', () {
        final resultInt1 = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': 1});
        final resultInt0 = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': 0});
        final resultInt2 = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': 2});
        final resultIntNegative = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': -1});

        expect(resultInt1, isA<CambiarPasswordSuccessResponse>());
        expect(resultInt0, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultInt2, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultIntNegative, isA<CambiarPasswordInvalidCredentialsResponse>());
      });

      test('debe retornar false para tipos no soportados o valores nulos', () {
        final resultNull = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': null});
        final resultList = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': []});
        final resultMap = CambiarPasswordResponseMapper.fromApiResponse(200, {'estado': {}});
        final resultMissing = CambiarPasswordResponseMapper.fromApiResponse(200, {});

        expect(resultNull, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultList, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultMap, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect(resultMissing, isA<CambiarPasswordInvalidCredentialsResponse>());
      });
    });
  });
}
