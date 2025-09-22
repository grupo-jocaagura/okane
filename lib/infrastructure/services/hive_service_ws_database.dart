import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

/// Servicio WS persistente con Hive para Okane.
/// - Contrato WS-like (`write/read/onValue`) con stream reactivo.
/// - Usa `BlocGeneral<Either<ErrorItem, Map<String, dynamic>>>`.
/// - Debounce en `write` usando `Debouncer.call()`.
/// - `write` devuelve `Either<ErrorItem, Unit>`.
/// - Inicializa Hive en un **subdirectorio fijo** (sin migración).
/// - **Forza una única key** (ignora el path entrante) para evitar mismatches.
class HiveServiceWSDatabase implements ServiceWSDatabase {
  HiveServiceWSDatabase({
    String boxName = 'okane_db',
    Debouncer? debouncer,
    ErrorMapper? errorMapper,
    String? dataSubDir,
    bool verbose = false,
  }) : _boxName = boxName,
       _debouncer = debouncer ?? Debouncer(milliseconds: 250),
       _mapper = errorMapper ?? const DefaultErrorMapper(),
       _subDir = dataSubDir ?? 'OkaneData',
       _verbose = verbose {
    // Estado inicial neutro (evita confundir a la UI con NOT_FOUND antes de leer/escribir).
    _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
      ErrorItem(
        title: 'Stream frío',
        code: 'COLD_STREAM',
        description: 'Aún no se ha leído ni escrito ningún valor.',
        meta: <String, dynamic>{'boxName': _boxName, 'subDir': _subDir},
      ),
    );
  }

  // ---- Config ----
  final String _boxName;
  final String _subDir;
  final Debouncer _debouncer;
  final ErrorMapper _mapper;
  final bool _verbose;

  // Única key interna usada para guardar/leer SIEMPRE.
  String get _ledgerKey => LedgerWsGateway.ledgerPath;

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

  // =========================
  //  Helpers de logs/errores
  // =========================

  void _log(String msg, [Map<String, dynamic>? meta]) {
    if (!_verbose) {
      return;
    }
    debugPrint(
      '[HiveWS] $msg :: ${<String, dynamic>{'box': _boxName, 'subDir': _subDir, ...?meta}}',
    );
  }

  static ErrorItem _errHiveInit(
    Object error,
    StackTrace st, {
    required String subDir,
    required String boxName,
  }) {
    return ErrorItem(
      title: 'No se pudo inicializar almacenamiento',
      code: 'ERR_HIVE_INIT',
      description:
          'Fallo al inicializar Hive o abrir el box. Ver meta para detalles.',
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{
        'subDir': subDir,
        'boxName': boxName,
        'error': error.toString(),
        'trace': st.toString(),
      },
    );
  }

  static ErrorItem _errBoxClosed({
    required String subDir,
    required String boxName,
  }) {
    return ErrorItem(
      title: 'Box no disponible',
      code: 'ERR_BOX_CLOSED',
      description:
          'El box no está abierto tras la inicialización. No es posible continuar.',
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{'subDir': subDir, 'boxName': boxName},
    );
  }

  static ErrorItem _errNotFound(
    String key, {
    required String boxName,
    required String subDir,
  }) {
    return ErrorItem(
      title: 'Dato no encontrado',
      code: 'NOT_FOUND',
      description:
          'No existe registro para "$key" en el box "$boxName" (subDir: "$subDir").',
      errorLevel: ErrorLevelEnum.warning,
      meta: <String, dynamic>{'key': key, 'boxName': boxName, 'subDir': subDir},
    );
  }

  static ErrorItem _errPayload(String key) {
    return ErrorItem(
      title: 'Payload inválido',
      code: 'ERR_PAYLOAD',
      description:
          'Faltan campos mínimos del ledger (nameOfLedger, incomeLedger, expenseLedger).',
      errorLevel: ErrorLevelEnum.warning,
      meta: <String, dynamic>{'key': key},
    );
  }

  static ErrorItem _errWritePut(
    Object error,
    StackTrace st, {
    required String key,
    required String boxName,
    required String subDir,
  }) {
    return ErrorItem(
      title: 'No se pudo guardar el ledger',
      code: 'ERR_WRITE_PUT',
      description: 'Fallo al persistir el documento en Hive.',
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{
        'key': key,
        'boxName': boxName,
        'subDir': subDir,
        'error': error.toString(),
        'trace': st.toString(),
      },
    );
  }

  static ErrorItem _errFormat(
    String key, {
    required String boxName,
    required String subDir,
  }) {
    return ErrorItem(
      title: 'Formato inválido',
      code: 'ERR_FORMAT',
      description: 'El valor guardado no es un Map<String, dynamic>.',
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{'key': key, 'boxName': boxName, 'subDir': subDir},
    );
  }

  // =========================
  //  Init / Utils
  // =========================

  Future<void> _ensureInit() async {
    _initFuture ??= () async {
      try {
        _log('init start');
        await Hive.initFlutter(_subDir); // subcarpeta fija
        _box = await Hive.openBox<dynamic>(_boxName);
        _log('box opened', <String, dynamic>{'isOpen': _box?.isOpen});
      } catch (e, st) {
        throw _StorageInitException(
          _errHiveInit(e, st, subDir: _subDir, boxName: _boxName),
        );
      }
    }();
    return _initFuture!;
  }

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
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String path, // ignorado: forzamos key única
    Map<String, dynamic> data,
  ) async {
    try {
      // Init de storage
      try {
        await _ensureInit();
      } on _StorageInitException catch (ex) {
        _log('write init error', {'error': ex.error});
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(ex.error);
        return Left<ErrorItem, Map<String, dynamic>>(ex.error);
      }

      // Box abierto?
      if (!(_box?.isOpen ?? false)) {
        final ErrorItem err = _errBoxClosed(subDir: _subDir, boxName: _boxName);
        _log('write box closed', {'error': err});
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
        return Left<ErrorItem, Map<String, dynamic>>(err);
      }

      // Validación mínima del payload
      final bool valid =
          data.isNotEmpty &&
          data.containsKey(LedgerEnum.nameOfLedger.name) &&
          data.containsKey(LedgerEnum.incomeLedger.name) &&
          data.containsKey(LedgerEnum.expenseLedger.name);

      if (!valid) {
        final ErrorItem err = _errPayload(_ledgerKey);
        _log('write payload invalid', {
          'error': err,
          'keys': data.keys.toList(),
        });
        return Left<ErrorItem, Map<String, dynamic>>(err);
      }

      // Debounced write — esperamos a que el put ocurra
      final Completer<Unit> completer = Completer<Unit>();
      final String key = _ledgerKey;

      _log('write request (schedule debounce)', {'in': path, 'key': key});

      _debouncer(() async {
        try {
          _log('write debounce fired', {'key': key});
          await _box!.put(key, data);
          await _box!.flush(); // 👈 asegura persistencia antes de leer
          _log('write ok', {'key': key, 'hasKey': _box!.containsKey(key)});
          _streamBloc.value = Right<ErrorItem, Map<String, dynamic>>(
            Map<String, dynamic>.from(data),
          );
          if (!completer.isCompleted) completer.complete(unit);
        } catch (e, st) {
          final ErrorItem err = _errWritePut(
            e,
            st,
            key: key,
            boxName: _boxName,
            subDir: _subDir,
          );
          _log('write error on put', {'error': err});
          _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
          if (!completer.isCompleted) {
            completer.completeError(err);
          }
        }
      });

      await completer.future;
      return _streamBloc.value;
    } catch (e, st) {
      final ErrorItem err = _mapper.fromException(
        e,
        st,
        location: 'HiveServiceWSDatabase.write',
      );
      _log('write unexpected error', {'error': err});
      _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
      return Left<ErrorItem, Map<String, dynamic>>(err);
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path) async {
    try {
      // Init de storage
      try {
        await _ensureInit();
      } on _StorageInitException catch (ex) {
        return Left<ErrorItem, Map<String, dynamic>>(ex.error);
      }

      // Box abierto?
      if (!(_box?.isOpen ?? false)) {
        return Left<ErrorItem, Map<String, dynamic>>(
          _errBoxClosed(subDir: _subDir, boxName: _boxName),
        );
      }

      final String key = _ledgerKey;
      _log('read request', <String, dynamic>{
        'in': path,
        'key': key,
        'hasKey': _box!.containsKey(key),
      });

      // Existencia de la key
      if (!_box!.containsKey(key)) {
        _log('read not found', <String, dynamic>{'key': key});
        return Left<ErrorItem, Map<String, dynamic>>(
          _errNotFound(key, boxName: _boxName, subDir: _subDir),
        );
      }

      // Lectura segura de Map
      final Map<String, dynamic>? map = _safeMap(_box!.get(key));
      if (map == null) {
        return Left<ErrorItem, Map<String, dynamic>>(
          _errFormat(key, boxName: _boxName, subDir: _subDir),
        );
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(map);

      // Boot emit para oyentes tardíos
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
    _bootEmit(); // dispara una lectura y emite lo que haya guardado
    return _streamBloc.stream;
  }

  Future<void> _bootEmit() async {
    try {
      await _ensureInit();

      if (!(_box?.isOpen ?? false)) {
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
          _errBoxClosed(subDir: _subDir, boxName: _boxName),
        );
        return;
      }

      final String key = _ledgerKey;
      final bool hasKey = _box!.containsKey(key);
      _log('boot emit', <String, dynamic>{'key': key, 'hasKey': hasKey});

      if (hasKey) {
        final Map<String, dynamic>? m = _safeMap(_box!.get(key));
        if (m == null) {
          _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
            _errFormat(key, boxName: _boxName, subDir: _subDir),
          );
        } else {
          _streamBloc.value = Right<ErrorItem, Map<String, dynamic>>(
            Map<String, dynamic>.from(m),
          );
        }
      } else {
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
          _errNotFound(key, boxName: _boxName, subDir: _subDir),
        );
      }
    } catch (e, st) {
      _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
        _mapper.fromException(
          e,
          st,
          location: 'HiveServiceWSDatabase.onValue.bootEmit',
        ),
      );
    }
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

/// Excepción interna para propagar un ErrorItem desde _ensureInit().
class _StorageInitException implements Exception {
  _StorageInitException(this.error);
  final ErrorItem error;

  @override
  String toString() => 'StorageInitException($error)';
}
