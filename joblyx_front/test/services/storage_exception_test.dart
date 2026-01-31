import 'package:flutter_test/flutter_test.dart';
import 'package:joblyx_front/services/storage/storage_exception.dart';

void main() {
  group('StorageFailure', () {
    test('crée une exception avec le code fourni', () {
      final exception = StorageFailure('upload_failed');

      expect(exception.code, 'upload_failed');
    });

    test('toString retourne le code', () {
      final exception = StorageFailure('file_size_exceeded');

      expect(exception.toString(), 'file_size_exceeded');
    });

    test('implémente Exception', () {
      final exception = StorageFailure('test_error');

      expect(exception, isA<Exception>());
    });

    test('peut être lancée et attrapée', () {
      expect(
        () => throw StorageFailure('invalid_file_type'),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('codes d\'erreur de stockage', () {
      final codes = [
        'invalid_file_type',
        'file_size_exceeded',
        'compression_failed',
        'upload_failed',
      ];

      for (final code in codes) {
        final exception = StorageFailure(code);
        expect(exception.code, code);
      }
    });
  });
}
