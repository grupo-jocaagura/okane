import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:okane/infrastructure/services/fake_service_w_s_database.dart';

void main() {
  late FakeServiceWSDatabase service;
  const String path = 'okane/test';

  final Map<String, dynamic> sampleLedger = <String, dynamic>{
    'nameOfLedger': 'test',
    'incomeLedger': <Map<String, dynamic>>[],
    'expenseLedger': <Map<String, dynamic>>[],
  };

  setUp(() {
    service = FakeServiceWSDatabase();
  });

  tearDown(() {
    service.dispose();
  });

  test('read devuelve error si no hay ledger', () async {
    final Either<ErrorItem, Map<String, dynamic>> result =
        await service.read(path);
    expect(result.isLeft, true);
    expect(
      result.when(
        (ErrorItem err) => err.code,
        (Map<String, dynamic> ok) => '',
      ),
      'NOT_FOUND',
    );
  });

  test('write válido actualiza el ledger y retorna Right', () async {
    final Either<ErrorItem, void> result =
        await service.write(path, sampleLedger);
    expect(result.isRight, true);
  });

  test('read devuelve ledger luego de write', () async {
    await service.write(path, sampleLedger);
    final Either<ErrorItem, Map<String, dynamic>> result =
        await service.read(path);
    expect(result.isRight, true);
    expect(
      result.when(
        (ErrorItem err) => null,
        (Map<String, dynamic> ok) => ok['nameOfLedger'],
      ),
      'test',
    );
  });

  test('onValue emite valores en tiempo real', () async {
    final List<Map<String, dynamic>> emissions = <Map<String, dynamic>>[];

    service
        .onValue(path)
        .listen((Either<ErrorItem, Map<String, dynamic>> event) {
      event.when(
        (ErrorItem _) =>
            defaultErrorItem.copyWith(title: 'no se esperaba error'),
        (Map<String, dynamic> data) => emissions.add(data),
      );
    });

    await service.write(path, sampleLedger);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(emissions, hasLength(1));
    expect(emissions.first['nameOfLedger'], 'test');
  });

  test('write con path inválido retorna Left', () async {
    final Either<ErrorItem, void> result =
        await service.write('otro/camino', sampleLedger);
    expect(result.isLeft, true);
    expect(result.when((ErrorItem err) => err.code, (_) => ''), 'NOT_FOUND');
  });

  test('reset limpia el ledger y emite error en stream', () async {
    await service.write(path, sampleLedger);
    service.reset();

    final Either<ErrorItem, Map<String, dynamic>> result =
        await service.read(path);
    expect(result.isLeft, true);

    final List<ErrorItem> errores = <ErrorItem>[];

    service
        .onValue(path)
        .listen((Either<ErrorItem, Map<String, dynamic>> event) {
      event.when(
        (ErrorItem error) => errores.add(error),
        (_) {},
      );
    });

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(errores, isNotEmpty);
    expect(errores.first.code, 'NOT_FOUND');
  });
}
