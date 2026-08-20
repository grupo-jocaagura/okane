import 'package:flutter_test/flutter_test.dart';
import 'package:okane/app/env.dart';
import 'package:okane/app/okane_environment.dart';

void main() {
  group('resolveOkaneEnvironment', () {
    test('resolves dev', () {
      expect(resolveOkaneEnvironment('dev'), AppEnvironment.dev);
    });

    test('resolves qa', () {
      expect(resolveOkaneEnvironment('qa'), AppEnvironment.qa);
    });

    test('resolves prod', () {
      expect(resolveOkaneEnvironment('prod'), AppEnvironment.prod);
    });

    test('normalizes case and surrounding whitespace', () {
      expect(resolveOkaneEnvironment('  DEV  '), AppEnvironment.dev);
    });

    test('fails when value is empty', () {
      expect(() => resolveOkaneEnvironment(''), throwsA(isA<StateError>()));
    });

    test('fails when value is unknown', () {
      expect(
        () => resolveOkaneEnvironment('staging'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
