import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase;
  StorageService(this._supabase);

  Future<String> uploadProfilePicture(String userId, File file) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      const allowed = ['jpg', 'jpeg', 'png'];
      if (!allowed.contains(ext)) {
        throw Exception('Invalid file type');
      }

      if (file.lengthSync() > 60 * 1024 * 1024) {
        throw Exception('File size exceeds limit');
      }
      final String path = '$userId/profile.jpg';
      await _supabase.storage
          .from('avatar')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      final String imageUrl = _supabase.storage
          .from('avatar')
          .getPublicUrl(path);
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
