import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../domain/entities/services/service_w_s_database.dart';
import '../../domain/gateway/ledger_ws_gateway.dart';

class HiveServiceWSDatabase implements ServiceWSDatabase {
  HiveServiceWSDatabase({
    String boxName = 'demo_okane',
    String? dataSubDir,
    bool verbose = true,
  }) : _boxName = boxName,
       _subDir = dataSubDir ?? 'OkaneData',
       _verbose = verbose {
    // arranca “frío”
    _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(
      ErrorItem(
        title: 'Stream frío',
        code: 'COLD_STREAM',
        description: 'Aún no se ha leído ni escrito ningún valor.',
        meta: <String, dynamic>{'boxName': _boxName, 'subDir': _subDir},
      ),
    );
  }

  final String _boxName;
  final String _subDir;
  final bool _verbose;

  String get _key => LedgerWsGateway.ledgerPath;

  Box<dynamic>? _box;
  Future<void>? _initFuture;

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

  void _log(String m, [Map<String, dynamic>? meta]) {
    if (!_verbose) {
      return;
    }
    debugPrint(
      '[HiveWS] $m :: ${<String, dynamic>{'box': _boxName, 'subDir': _subDir, ...?meta}}',
    );
  }

  Future<void> _ensureInit() async {
    _initFuture ??= () async {
      _log('init start', <String, dynamic>{
        'platform': Platform.operatingSystem,
      });
      if (Platform.isAndroid || Platform.isIOS) {
        await Hive.initFlutter(); // usa app documents
      } else {
        await Hive.initFlutter(_subDir); // desktop/web-like subdir
      }
      _box = await Hive.openBox<dynamic>(_boxName);
      _log('box opened', <String, dynamic>{
        'isOpen': _box?.isOpen,
        'boxPath': _box?.path,
        'keysCount': _box?.length,
      });
    }();
    return _initFuture!;
  }

  Map<String, dynamic> _copyJson(Map<String, dynamic> data) =>
      Map<String, dynamic>.from(data);

  Map<String, dynamic>? _safeMap(dynamic v) {
    if (v is Map) {
      return Map<String, dynamic>.from(
        v.map((dynamic k, dynamic v) => MapEntry<String, dynamic>('$k', v)),
      );
    }
    return null;
  }

  bool _isValidLedger(Map<String, dynamic> doc) {
    return doc.isNotEmpty &&
        doc.containsKey(LedgerEnum.nameOfLedger.name) &&
        doc.containsKey(LedgerEnum.incomeLedger.name) &&
        doc.containsKey(LedgerEnum.expenseLedger.name) &&
        (doc[LedgerEnum.incomeLedger.name] is List) &&
        (doc[LedgerEnum.expenseLedger.name] is List);
  }

  ErrorItem _err(
    String code,
    String title,
    String desc, [
    Map<String, dynamic>? meta,
  ]) => ErrorItem(
    title: title,
    code: code,
    description: desc,
    errorLevel: ErrorLevelEnum.warning,
    meta: meta ?? const <String, dynamic>{},
  );

  Future<Either<ErrorItem, Map<String, dynamic>>> _snapshot() async {
    try {
      await _ensureInit();
      if (!(_box?.isOpen ?? false)) {
        return Left<ErrorItem, Map<String, dynamic>>(
          _err(
            'ERR_BOX_CLOSED',
            'Box no disponible',
            'No es posible continuar',
            <String, dynamic>{'subDir': _subDir, 'boxName': _boxName},
          ),
        );
      }
      if (_box!.containsKey(_key)) {
        final Map<String, dynamic>? m = _safeMap(_box!.get(_key));
        if (m == null || !_isValidLedger(m)) {
          return Left<ErrorItem, Map<String, dynamic>>(
            _err(
              'ERR_FORMAT',
              'Formato inválido',
              'El valor guardado no es un Map<String, dynamic>.',
              <String, dynamic>{'key': _key},
            ),
          );
        }
        return Right<ErrorItem, Map<String, dynamic>>(_copyJson(m));
      }
      // seed si no existe
      final Map<String, dynamic> seeded = defaultMovement.toJson();
      await _box!.put(_key, seeded);
      await _box!.flush();
      return Right<ErrorItem, Map<String, dynamic>>(_copyJson(seeded));
    } catch (e, st) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _err(
          'ERR_SNAPSHOT',
          'Fallo snapshot',
          'Excepción al construir el snapshot',
          <String, dynamic>{'error': e.toString(), 'trace': st.toString()},
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> read(String path) async {
    final Either<ErrorItem, Map<String, dynamic>> snap = await _snapshot();
    _streamBloc.value = snap; // sincroniza para oyentes tardíos
    _log('read', <String, dynamic>{
      'in': path,
      'result': snap.isRight ? 'RIGHT' : 'LEFT',
    });
    return snap;
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      await _ensureInit();
      if (!(_box?.isOpen ?? false)) {
        final ErrorItem err = _err(
          'ERR_BOX_CLOSED',
          'Box no disponible',
          'No es posible continuar',
          <String, dynamic>{'subDir': _subDir, 'boxName': _boxName},
        );
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
        return Left<ErrorItem, Map<String, dynamic>>(err);
      }
      if (!_isValidLedger(data)) {
        final ErrorItem err = _err(
          'ERR_PAYLOAD',
          'Payload inválido',
          'Faltan campos mínimos del ledger',
          <String, dynamic>{'keys': data.keys.toList()},
        );
        _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
        return Left<ErrorItem, Map<String, dynamic>>(err);
      }

      await _box!.put(_key, data);
      await _box!.flush();
      final Map<String, dynamic> copy = _copyJson(data);
      _streamBloc.value = Right<ErrorItem, Map<String, dynamic>>(copy);
      _log('write ok', <String, dynamic>{'key': _key});
      return Right<ErrorItem, Map<String, dynamic>>(copy);
    } catch (e, st) {
      final ErrorItem err = _err(
        'ERR_WRITE_PUT',
        'No se pudo guardar el ledger',
        'Fallo al persistir el documento',
        <String, dynamic>{'error': e.toString(), 'trace': st.toString()},
      );
      _streamBloc.value = Left<ErrorItem, Map<String, dynamic>>(err);
      return Left<ErrorItem, Map<String, dynamic>>(err);
    }
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> onValue(String path) async* {
    // emite snapshot inmediato
    final Either<ErrorItem, Map<String, dynamic>> snap = await _snapshot();
    _streamBloc.value = snap;
    yield snap;

    // continúa con stream reactivo
    yield* _streamBloc.stream;
  }

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
