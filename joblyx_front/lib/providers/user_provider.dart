import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/models/user_model.dart';
import 'package:joblyx_front/providers/auth_state_provider.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final supabase = ref.watch(supabaseProvider);

  // Écoute les changements d'auth pour se rafraîchir quand l'utilisateur change
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) {
      final user = state.session?.user;
      if (user == null) return Stream.value(null);

      return supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', user.id)
          .map((data) => data.isEmpty ? null : UserModel.fromMap(data.first));
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Selective providers to avoid unnecessary rebuilds
final userFirstNameProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(userProvider.select((async) => async.whenData((u) => u?.firstName)));
});

final userProfilePictureProvider = Provider<AsyncValue<String?>>((ref) {
  return ref.watch(userProvider.select((async) => async.whenData((u) => u?.profilePicture)));
});

final userCreatedAtProvider = Provider<AsyncValue<DateTime?>>((ref) {
  return ref.watch(userProvider.select((async) => async.whenData((u) => u?.createdAt)));
});

// Combined provider for home screen (firstName + profilePicture)
final userHomeDataProvider = Provider<AsyncValue<({String? firstName, String? profilePicture})>>((ref) {
  return ref.watch(userProvider.select((async) => async.whenData((u) => (
    firstName: u?.firstName,
    profilePicture: u?.profilePicture,
  ))));
});

// Combined provider for profile picture card (profilePicture + createdAt)
final userPictureCardProvider = Provider<AsyncValue<({String? profilePicture, DateTime? createdAt})>>((ref) {
  return ref.watch(userProvider.select((async) => async.whenData((u) => (
    profilePicture: u?.profilePicture,
    createdAt: u?.createdAt,
  ))));
});

// Provider to check if user is authenticated via OAuth (LinkedIn, Google, etc.)
final isOAuthUserProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (state) {
      final user = state.session?.user;
      if (user == null) return false;

      final identities = user.identities;
      if (identities == null || identities.isEmpty) return false;

      return identities.any((identity) => identity.provider != 'email');
    },
  ) ?? false;
});
