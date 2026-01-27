import 'package:flutter_test/flutter_test.dart';
import 'package:joblyx_front/services/auth_exception.dart';

void main() {
  group('AuthFailure', () {
    test('crée une exception avec le code fourni', () {
      final exception = AuthFailure('invalid_credentials');

      expect(exception.code, 'invalid_credentials');
    });

    test('toString retourne le code', () {
      final exception = AuthFailure('user_not_found');

      expect(exception.toString(), 'user_not_found');
    });

    test('implémente Exception', () {
      final exception = AuthFailure('test_error');

      expect(exception, isA<Exception>());
    });

    test('peut être lancée et attrapée', () {
      expect(
        () => throw AuthFailure('weak_password'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('codes d\'erreur courants', () {
      final codes = [
        'weak_password',
        'user_already_exists',
        'invalid_credentials',
        'email_not_confirmed',
        'otp_expired',
        'unknown_error',
      ];

      for (final code in codes) {
        final exception = AuthFailure(code);
        expect(exception.code, code);
      }
    });

    test('exception avec code vide', () {
      final exception = AuthFailure('');

      expect(exception.code, '');
      expect(exception.toString(), '');
    });
  });
}
