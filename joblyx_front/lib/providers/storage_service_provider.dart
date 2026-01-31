import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/services/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return StorageService(supabase);
});
