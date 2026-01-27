import 'package:flutter_test/flutter_test.dart';
import 'package:joblyx_front/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap crée un UserModel valide', () {
      final map = {
        'id': '123',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'profile_picture': 'https://example.com/avatar.jpg',
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final user = UserModel.fromMap(map);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.profilePicture, 'https://example.com/avatar.jpg');
      expect(user.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('fromMap avec données minimales', () {
      final map = {
        'id': 'abc',
        'email': 'user@test.com',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'profile_picture': '',
        'created_at': '2024-06-01T00:00:00.000Z',
      };

      final user = UserModel.fromMap(map);

      expect(user.id, 'abc');
      expect(user.firstName, 'Jane');
      expect(user.profilePicture, '');
    });

    test('fromMap parse correctement la date ISO 8601', () {
      final map = {
        'id': '1',
        'email': 'test@test.com',
        'first_name': 'Test',
        'last_name': 'User',
        'profile_picture': 'url',
        'created_at': '2024-12-25T14:30:45.123Z',
      };

      final user = UserModel.fromMap(map);

      expect(user.createdAt.year, 2024);
      expect(user.createdAt.month, 12);
      expect(user.createdAt.day, 25);
      expect(user.createdAt.hour, 14);
      expect(user.createdAt.minute, 30);
    });

    test('fromMap avec email contenant des caractères spéciaux', () {
      final map = {
        'id': '999',
        'email': 'user+test@sub.example.com',
        'first_name': 'Test',
        'last_name': 'User',
        'profile_picture': 'https://ui-avatars.com/api/?name=Test+User',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromMap(map);

      expect(user.email, 'user+test@sub.example.com');
    });

    test('fromMap avec noms accentués', () {
      final map = {
        'id': '456',
        'email': 'francois@example.com',
        'first_name': 'François',
        'last_name': 'Côté',
        'profile_picture': 'url',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromMap(map);

      expect(user.firstName, 'François');
      expect(user.lastName, 'Côté');
    });
  });
}
