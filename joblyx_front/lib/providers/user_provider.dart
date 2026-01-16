import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/models/user_model.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return Stream.value(null);

  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) =>
       data.isEmpty ? null : UserModel.fromMap(data.first));
});
