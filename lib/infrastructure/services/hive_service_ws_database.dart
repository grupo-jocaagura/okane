import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Servicio WS persistente con Hive para Okane.
///
/// - Contrato WS-like (`write/read/onValue`) con stream reactivo.
/// - Usa `BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>`.
/// - Aplica `Debouncer` a `write` usando tu implementación (call()).
/// - Devuelve `Either<ErrorItem, Unit>` en `write`.
class HiveServiceWSDatabase implements ServiceWSDatabase {
  HiveServiceWSDatabase({
    String boxName = 'okane_db',
    Debouncer? debouncer,
    ErrorMapper? errorMapper,
  }) : _boxName = boxName,
       _debouncer = debouncer ?? Debouncer(milliseconds: 250),
       _mapper = errorMapper ?? const DefaultErrorMapper() {
    // Estado inicial: NOT_FOUND para mantener compatibilidad de arranque con el Fake.
    _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
      _notFound(LedgerWsGateway.ledgerPath),
    );
  }

  // ---- Config ----
  final String _boxName;
  final Debouncer _debouncer;
  final ErrorMapper _mapper;

  // ---- Estado reactivo ----
  final BlocGeneral<Either<ErrorItem, Map<String, dynamic>>> _streamBloc =
      BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>(
        Left<ErrorItem, Map<String, dynamic>>(
          const ErrorItem(
            title: 'Boot',
            code: 'BOOT',
            description: 'Stream not initialized yet',
          ),
        ),
      );

  // ---- Hive ----
  Box<dynamic>? _box;
  Future<void>? _initFuture;

  static ErrorItem _notFound(String path) => ErrorItem(
    title: 'Dato no encontrado',
    description: 'No existe ledger en $path',
    code: 'NOT_FOUND',
  );

  Future<void> _ensureInit() async {
    _initFuture ??= () async {
      await Hive.initFlutter(); // Android / Windows OK
      _box = await Hive.openBox<dynamic>(_boxName);
    }();
    return _initFuture!;
  }

  bool _isLedgerPath(String path) =>
      path.startsWith(LedgerWsGateway.ledgerPath);

  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((Object? k, Object? v) => MapEntry<String, dynamic>('$k', v)),
      );
    }
    return null;
  }

  // ---------------------------
  // ServiceWSDatabase contract
  // ---------------------------

  @override
  Future<Either<ErrorItem, Unit>> write(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      if (!_isLedgerPath(path)) {
        final ErrorItem nf = _notFound(path);
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(nf);
        return Left<ErrorItem, Unit>(nf);
      }

      await _ensureInit();

      // Validación mínima del payload.
      final bool valid =
          data.isNotEmpty &&
          data.containsKey(LedgerEnum.nameOfLedger.name) &&
          data.containsKey(LedgerEnum.incomeLedger.name) &&
          data.containsKey(LedgerEnum.expenseLedger.name);

      if (!valid) {
        return Left<ErrorItem, Unit>(
          ErrorItem(
            title: 'Payload inválido',
            code: 'ERR_PAYLOAD',
            description: 'Faltan campos mínimos del ledger',
            errorLevel: ErrorLevelEnum.warning,
            meta: <String, dynamic>{'path': path},
          ),
        );
      }

      // Necesitamos que `write()` NO retorne hasta que el debounced-write se ejecute.
      final Completer<Unit> completer = Completer<Unit>();

      _debouncer(() async {
        try {
          await _box!.put(path, data);
          // Emitir al stream el estado actualizado.
          _streamBloc.value = Right<ErrorItem, Map<String, dynamic>>(
            Map<String, dynamic>.from(data),
          );
          if (!completer.isCompleted) {
            completer.complete(unit);
          }
        } catch (e, st) {
          final ErrorItem err = _mapper.fromException(
            e,
            st,
            location: 'HiveServiceWSDatabase.write.debounced',
          );
          _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
          if (!completer.isCompleted) {
            completer.completeError(err);
          }
        }
      });

      // Espera a que se cumpla el debounce y se realice el put().
      final Unit _ = await completer.future;
      return Right<ErrorItem, Unit>(unit);
    } catch (e, st) {
      final ErrorItem err = _mapper.fromException(
        e,
        st,
        location: 'HiveServiceWSDatabase.write',
      );
      _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
      return Left<ErrorItem, Unit>(err);
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path) async {
    try {
      if (!_isLedgerPath(path)) {
        return Left<ErrorItem, Map<String, dynamic>>(_notFound(path));
      }

      await _ensureInit();

      if (!_box!.containsKey(path)) {
        return Left<ErrorItem, Map<String, dynamic>>(_notFound(path));
      }

      final Map<String, dynamic>? map = _safeMap(_box!.get(path));
      if (map == null) {
        return Left<ErrorItem, Map<String, dynamic>>(
          ErrorItem(
            title: 'Formato inválido',
            code: 'ERR_FORMAT',
            description: 'El valor guardado no es un Map',
            errorLevel: ErrorLevelEnum.severe,
            meta: <String, dynamic>{'path': path},
          ),
        );
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(map);

      // Boot emit para sincronizar oyentes que lleguen tarde.
      _streamBloc.value = Right<ErrorItem, Map<String, dynamic>>(json);

      return Right<ErrorItem, Map<String, dynamic>>(json);
    } catch (e, st) {
      final ErrorItem err = _mapper.fromException(
        e,
        st,
        location: 'HiveServiceWSDatabase.read',
      );
      return Left<ErrorItem, Map<String, dynamic>>(err);
    }
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path) {
    // Mantiene la semántica del Fake: stream existente y emite el último valor.
    // Para primer valor consistente, el caller puede invocar `read(path)` antes o después de suscribirse.
    return _streamBloc.stream;
  }

  // ---------------------------
  // Ciclo de vida (opcional)
  // ---------------------------

  Future<void> dispose() async {
    try {
      if (_box?.isOpen ?? false) {
        await _box!.flush();
        await _box!.close();
      }
    } finally {
      _streamBloc.dispose();
    }
  }
}
