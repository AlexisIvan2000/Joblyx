import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validation Email', () {
    // Regex pour validation email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    test('email valide simple', () {
      expect(emailRegex.hasMatch('test@example.com'), true);
    });

    test('email valide avec sous-domaine', () {
      expect(emailRegex.hasMatch('user@mail.example.com'), true);
    });

    test('email invalide sans @', () {
      expect(emailRegex.hasMatch('testexample.com'), false);
    });

    test('email invalide sans domaine', () {
      expect(emailRegex.hasMatch('test@'), false);
    });

    test('email invalide vide', () {
      expect(emailRegex.hasMatch(''), false);
    });

    test('email avec tiret', () {
      expect(emailRegex.hasMatch('user-name@example.com'), true);
    });

    test('email avec point dans nom', () {
      expect(emailRegex.hasMatch('user.name@example.com'), true);
    });

    test('email avec underscore', () {
      expect(emailRegex.hasMatch('user_name@example.com'), true);
    });
  });

  group('Validation Password', () {
    bool isPasswordValid(String password) {
      return password.length >= 6;
    }

    test('password valide 6 caractères', () {
      expect(isPasswordValid('123456'), true);
    });

    test('password valide long', () {
      expect(isPasswordValid('monMotDePasseTresLong123!'), true);
    });

    test('password invalide trop court', () {
      expect(isPasswordValid('12345'), false);
    });

    test('password invalide vide', () {
      expect(isPasswordValid(''), false);
    });

    test('password avec espaces compte', () {
      expect(isPasswordValid('ab cd ef'), true);
    });
  });

  group('Validation Nom', () {
    bool isNameValid(String name) {
      return name.trim().isNotEmpty;
    }

    test('nom valide simple', () {
      expect(isNameValid('John'), true);
    });

    test('nom valide avec accent', () {
      expect(isNameValid('François'), true);
    });

    test('nom invalide vide', () {
      expect(isNameValid(''), false);
    });

    test('nom invalide espaces seulement', () {
      expect(isNameValid('   '), false);
    });

    test('nom avec tiret', () {
      expect(isNameValid('Jean-Pierre'), true);
    });
  });
}
