import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Interfaz para servicios de base de datos en tiempo real vía WebSocket.
///
/// Esta clase define los métodos básicos para comunicación asincrónica
/// sobre un canal WebSocket.
///
/// ### Métodos:
/// - `write`: Enviar datos a una ruta.
/// - `read`: Leer datos de una ruta.
/// - `onValue`: Escuchar cambios en tiempo real en una ruta.
abstract class ServiceWSDatabase {
  /// Envía datos al backend en tiempo real.
  ///
  /// Retorna [Right<void>] si fue exitoso, o [Left<ErrorItem>] si falló.
  Future<Either<ErrorItem, void>> write(String path, Map<String, dynamic> data);

  /// Solicita la última copia de los datos en una ruta.
  ///
  /// Retorna un [Map] si hay datos, o un [ErrorItem] en caso de fallo.
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path);

  /// Devuelve un stream reactivo para escuchar cambios en una ruta.
  ///
  /// Retorna un `Stream<Either<Map<String, dynamic>, ErrorItem>>`.
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path);
}
