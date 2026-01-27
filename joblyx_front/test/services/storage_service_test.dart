import 'package:flutter_test/flutter_test.dart';
import 'package:joblyx_front/services/storage_service.dart';

void main() {
  group('StorageService', () {
    group('constantes', () {
      test('maxFileSizeMB est 15', () {
        expect(StorageService.maxFileSizeMB, 15);
      });

      test('extensions autorisées sont jpg, jpeg, png', () {
        expect(StorageService.allowedExtensions, ['jpg', 'jpeg', 'png']);
      });

      test('jpg est autorisé', () {
        expect(StorageService.allowedExtensions.contains('jpg'), true);
      });

      test('jpeg est autorisé', () {
        expect(StorageService.allowedExtensions.contains('jpeg'), true);
      });

      test('png est autorisé', () {
        expect(StorageService.allowedExtensions.contains('png'), true);
      });

      test('gif n\'est pas autorisé', () {
        expect(StorageService.allowedExtensions.contains('gif'), false);
      });

      test('webp n\'est pas autorisé', () {
        expect(StorageService.allowedExtensions.contains('webp'), false);
      });
    });

    group('validation extension', () {
      test('extension valide en minuscules', () {
        const ext = 'jpg';
        expect(StorageService.allowedExtensions.contains(ext), true);
      });

      test('liste des extensions a 3 éléments', () {
        expect(StorageService.allowedExtensions.length, 3);
      });
    });
  });
}
