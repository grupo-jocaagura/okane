import 'package:flutter_test/flutter_test.dart';
import 'package:okane/domain/error_item.dart';

void main() {
  group('ErrorItem Tests', () {
    test('Debe crear una instancia de ErrorItem correctamente', () {
      const ErrorItem error = ErrorItem(
        title: 'Error de validación',
        code: 'VALIDATION_ERROR',
        description: 'El campo nombre es obligatorio.',
      );

      expect(error.title, 'Error de validación');
      expect(error.code, 'VALIDATION_ERROR');
      expect(error.description, 'El campo nombre es obligatorio.');
      expect(error.meta, isEmpty);
    });

    test('Debe manejar correctamente un ErrorItem con meta data', () {
      const ErrorItem error = ErrorItem(
        title: 'Error en API',
        code: 'API_TIMEOUT',
        description: 'La solicitud ha tardado demasiado en responder.',
        meta: <String, dynamic>{'timeout': 30, 'endpoint': '/users'},
      );

      expect(error.meta, isNotEmpty);
      expect(error.meta['timeout'], 30);
      expect(error.meta['endpoint'], '/users');
    });

    test('toString() debe retornar el formato esperado sin meta data', () {
      const ErrorItem error = ErrorItem(
        title: 'Error de autenticación',
        code: 'AUTH_ERROR',
        description: 'Credenciales incorrectas.',
      );

      expect(
        error.toString(),
        'Error de autenticación (AUTH_ERROR): Credenciales incorrectas.',
      );
    });

    test('toString() debe retornar el formato esperado con meta data', () {
      const ErrorItem error = ErrorItem(
        title: 'Error en base de datos',
        code: 'DB_ERROR',
        description: 'No se pudo conectar a la base de datos.',
        meta: <String, dynamic>{'retry': true, 'host': 'localhost'},
      );

      expect(
        error.toString(),
        'Error en base de datos (DB_ERROR): No se pudo conectar a la base de datos. | Meta: {retry: true, host: localhost}',
      );
    });

    test('Dos ErrorItem con los mismos valores deben ser iguales', () {
      const ErrorItem error1 = ErrorItem(
        title: 'Error de conexión',
        code: 'CONNECTION_ERROR',
        description: 'No se pudo establecer conexión con el servidor.',
      );

      const ErrorItem error2 = ErrorItem(
        title: 'Error de conexión',
        code: 'CONNECTION_ERROR',
        description: 'No se pudo establecer conexión con el servidor.',
      );

      expect(error1, equals(error2));
    });

    test('Dos ErrorItem con valores diferentes no deben ser iguales', () {
      const ErrorItem error1 = ErrorItem(
        title: 'Error de conexión',
        code: 'CONNECTION_ERROR',
        description: 'No se pudo establecer conexión con el servidor.',
      );

      const ErrorItem error2 = ErrorItem(
        title: 'Error HTTP',
        code: 'HTTP_500',
        description: 'Error interno del servidor.',
      );

      expect(error1, isNot(equals(error2)));
    });

    test('El hashCode debe ser consistente para el mismo objeto', () {
      const ErrorItem error1 = ErrorItem(
        title: 'Error de sesión',
        code: 'SESSION_TIMEOUT',
        description: 'La sesión ha expirado.',
      );

      const ErrorItem error2 = ErrorItem(
        title: 'Error de sesión',
        code: 'SESSION_TIMEOUT',
        description: 'La sesión ha expirado.',
      );

      expect(error1.hashCode, equals(error2.hashCode));
    });
  });
}
