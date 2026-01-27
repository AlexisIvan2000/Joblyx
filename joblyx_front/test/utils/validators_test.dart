import 'package:flutter_test/flutter_test.dart';

// Fonctions de validation extraites pour tests
class Validators {
  static final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'invalid_email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required';
    }
    if (value.length < 6) {
      return 'password_too_short';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'name_required';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'confirm_password_required';
    }
    if (value != password) {
      return 'passwords_do_not_match';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'otp_required';
    }
    if (value.length != 6) {
      return 'otp_invalid_length';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'otp_must_be_numeric';
    }
    return null;
  }
}

void main() {
  group('Validators.validateEmail', () {
    test('retourne null pour email valide', () {
      expect(Validators.validateEmail('test@example.com'), null);
    });

    test('retourne erreur pour email vide', () {
      expect(Validators.validateEmail(''), 'email_required');
    });

    test('retourne erreur pour email null', () {
      expect(Validators.validateEmail(null), 'email_required');
    });

    test('retourne erreur pour email invalide', () {
      expect(Validators.validateEmail('invalid'), 'invalid_email');
    });

    test('accepte email avec sous-domaine', () {
      expect(Validators.validateEmail('user@mail.example.com'), null);
    });
  });

  group('Validators.validatePassword', () {
    test('retourne null pour password valide', () {
      expect(Validators.validatePassword('123456'), null);
    });

    test('retourne erreur pour password vide', () {
      expect(Validators.validatePassword(''), 'password_required');
    });

    test('retourne erreur pour password null', () {
      expect(Validators.validatePassword(null), 'password_required');
    });

    test('retourne erreur pour password trop court', () {
      expect(Validators.validatePassword('12345'), 'password_too_short');
    });

    test('accepte password long', () {
      expect(Validators.validatePassword('monMotDePasseSecurise123!'), null);
    });
  });

  group('Validators.validateName', () {
    test('retourne null pour nom valide', () {
      expect(Validators.validateName('John'), null);
    });

    test('retourne erreur pour nom vide', () {
      expect(Validators.validateName(''), 'name_required');
    });

    test('retourne erreur pour nom null', () {
      expect(Validators.validateName(null), 'name_required');
    });

    test('retourne erreur pour espaces seulement', () {
      expect(Validators.validateName('   '), 'name_required');
    });

    test('accepte nom avec accent', () {
      expect(Validators.validateName('François'), null);
    });

    test('accepte nom avec tiret', () {
      expect(Validators.validateName('Jean-Pierre'), null);
    });
  });

  group('Validators.validateConfirmPassword', () {
    test('retourne null si passwords correspondent', () {
      expect(Validators.validateConfirmPassword('password123', 'password123'), null);
    });

    test('retourne erreur si vide', () {
      expect(Validators.validateConfirmPassword('', 'password123'), 'confirm_password_required');
    });

    test('retourne erreur si ne correspondent pas', () {
      expect(Validators.validateConfirmPassword('different', 'password123'), 'passwords_do_not_match');
    });
  });

  group('Validators.validateOtp', () {
    test('retourne null pour OTP valide', () {
      expect(Validators.validateOtp('123456'), null);
    });

    test('retourne erreur pour OTP vide', () {
      expect(Validators.validateOtp(''), 'otp_required');
    });

    test('retourne erreur pour OTP trop court', () {
      expect(Validators.validateOtp('12345'), 'otp_invalid_length');
    });

    test('retourne erreur pour OTP trop long', () {
      expect(Validators.validateOtp('1234567'), 'otp_invalid_length');
    });

    test('retourne erreur pour OTP non numérique', () {
      expect(Validators.validateOtp('12345a'), 'otp_must_be_numeric');
    });

    test('accepte OTP avec zéros', () {
      expect(Validators.validateOtp('000000'), null);
    });
  });
}
