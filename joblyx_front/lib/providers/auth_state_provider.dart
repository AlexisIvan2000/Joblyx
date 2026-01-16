import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
},);