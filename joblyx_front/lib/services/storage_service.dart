import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase;
  StorageService(this._supabase);

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
    try {
      final ext = file.path.split('.').last.toLowerCase();
      const allowed = ['jpg', 'jpeg', 'png'];
      if (!allowed.contains(ext)) {
        throw Exception('Invalid file type');
      }

      if (file.lengthSync() > 10 * 1024 * 1024) {
        throw Exception('File size exceeds limit');
      }

      final compressedBytes = await _compressImage(file);
      if (compressedBytes == null) {
        throw Exception('Failed to compress image');
      }

      final String path = '$userId/profile.jpg';
      await _supabase.storage.from('avatar').uploadBinary(
            path,
            compressedBytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final String imageUrl = _supabase.storage.from('avatar').getPublicUrl(path);
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
