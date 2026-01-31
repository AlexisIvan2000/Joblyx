import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:joblyx_front/services/storage/storage_exception.dart';

class StorageService {
  final SupabaseClient _supabase;
  StorageService(this._supabase);

  static const int maxFileSizeMB = 15;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  Future<Uint8List?> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 500,
      minHeight: 500,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  Future<String> uploadProfilePicture(String userId, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw StorageFailure('invalid_file_type');
    }

    if (file.lengthSync() > maxFileSizeMB * 1024 * 1024) {
      throw StorageFailure('file_size_exceeded');
    }

    try {
      final compressedBytes = await _compressImage(file);
      if (compressedBytes == null) {
        throw StorageFailure('compression_failed');
      }

      final String path = '$userId/profile.jpg';
      await _supabase.storage.from('avatar').uploadBinary(
            path,
            compressedBytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final String imageUrl = _supabase.storage.from('avatar').getPublicUrl(path);
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } on StorageFailure {
      rethrow;
    } catch (e) {
      throw StorageFailure('upload_failed');
    }
  }
}
