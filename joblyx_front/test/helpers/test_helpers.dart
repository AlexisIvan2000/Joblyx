import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Widget wrapper pour les tests avec ScreenUtil
Widget createTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

// Widget wrapper avec thème personnalisé
Widget createTestableWidgetWithTheme(Widget child, {ThemeData? theme}) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    ),
  );
}

// Données mock pour les tests
class MockData {
  static Map<String, dynamic> get validUserMap => {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'first_name': 'Test',
        'last_name': 'User',
        'profile_picture': 'https://example.com/avatar.jpg',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

  static Map<String, dynamic> get userWithFrenchName => {
        'id': 'french-user-id',
        'email': 'francois@example.com',
        'first_name': 'François',
        'last_name': 'Côté',
        'profile_picture': 'https://ui-avatars.com/api/?name=François+Côté',
        'created_at': '2024-06-15T14:30:00.000Z',
      };

  static List<String> get validEmails => [
        'test@example.com',
        'user@mail.example.com',
        'john.doe@company.org',
        'user-name@test.co',
      ];

  static List<String> get invalidEmails => [
        '',
        'invalid',
        '@example.com',
        'user@',
        'user@.com',
      ];

  static List<String> get validPasswords => [
        '123456',
        'password123',
        'MySecureP@ss!',
        'abcdefghij',
      ];

  static List<String> get invalidPasswords => [
        '',
        '12345',
        'abc',
      ];
}
