import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeMode', () {
    test('ThemeMode.light existe', () {
      expect(ThemeMode.light, isNotNull);
    });

    test('ThemeMode.dark existe', () {
      expect(ThemeMode.dark, isNotNull);
    });

    test('ThemeMode.system existe', () {
      expect(ThemeMode.system, isNotNull);
    });

    test('les trois modes sont différents', () {
      expect(ThemeMode.light, isNot(ThemeMode.dark));
      expect(ThemeMode.light, isNot(ThemeMode.system));
      expect(ThemeMode.dark, isNot(ThemeMode.system));
    });
  });

  group('Couleurs Teal', () {
    test('couleur primaire Teal existe', () {
      expect(Colors.teal, isNotNull);
    });

    test('variantes de Teal', () {
      expect(Colors.teal.shade100, isNotNull);
      expect(Colors.teal.shade200, isNotNull);
      expect(Colors.teal.shade300, isNotNull);
      expect(Colors.teal.shade400, isNotNull);
      expect(Colors.teal.shade500, isNotNull);
      expect(Colors.teal.shade600, isNotNull);
      expect(Colors.teal.shade700, isNotNull);
      expect(Colors.teal.shade800, isNotNull);
      expect(Colors.teal.shade900, isNotNull);
    });

    test('couleur splash screen #018786', () {
      const splashColor = Color(0xFF018786);
      expect(splashColor, const Color(0xFF018786));
    });
  });

  group('ThemeData', () {
    test('peut créer un thème clair', () {
      final theme = ThemeData.light();
      expect(theme.brightness, Brightness.light);
    });

    test('peut créer un thème sombre', () {
      final theme = ThemeData.dark();
      expect(theme.brightness, Brightness.dark);
    });

    test('peut créer un thème avec colorSchemeSeed', () {
      final theme = ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      );
      expect(theme, isNotNull);
    });

    test('useMaterial3 par défaut', () {
      final theme = ThemeData();
      expect(theme.useMaterial3, true);
    });
  });
}
