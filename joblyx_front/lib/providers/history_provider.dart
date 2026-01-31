import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/models/search_history_model.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';
import 'package:joblyx_front/services/history/history_service.dart';

final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<SearchHistoryItem>>(
  () => HistoryNotifier(),
);

class HistoryNotifier extends AsyncNotifier<List<SearchHistoryItem>> {
  @override
  Future<List<SearchHistoryItem>> build() async {
    return _fetchHistory();
  }

  Future<List<SearchHistoryItem>> _fetchHistory() async {
    final supabase = ref.read(supabaseProvider);
    final session = supabase.auth.currentSession;

    if (session == null) {
      return [];
    }

    try {
      final service = ref.read(historyServiceProvider);
      return await service.getHistory(accessToken: session.accessToken);
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHistory());
  }

  Future<bool> deleteSearch(String searchId) async {
    final supabase = ref.read(supabaseProvider);
    final session = supabase.auth.currentSession;

    if (session == null) return false;

    try {
      final service = ref.read(historyServiceProvider);
      final success = await service.deleteSearch(
        accessToken: session.accessToken,
        searchId: searchId,
      );

      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    final supabase = ref.read(supabaseProvider);
    final session = supabase.auth.currentSession;

    if (session == null) return false;

    try {
      final service = ref.read(historyServiceProvider);
      final success = await service.clearHistory(
        accessToken: session.accessToken,
      );

      if (success) {
        state = const AsyncValue.data([]);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
