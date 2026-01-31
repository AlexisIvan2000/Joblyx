import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/models/market_analysis_model.dart';
import 'package:joblyx_front/providers/supabase_provider.dart';
import 'package:joblyx_front/services/market/market_service.dart';

final marketServiceProvider = Provider<MarketService>((ref) {
  return MarketService();
});

final marketAnalysisProvider = NotifierProvider<MarketAnalysisNotifier,
    AsyncValue<MarketAnalysisResult?>>(() => MarketAnalysisNotifier());

class MarketAnalysisNotifier
    extends Notifier<AsyncValue<MarketAnalysisResult?>> {
  @override
  AsyncValue<MarketAnalysisResult?> build() => const AsyncValue.data(null);

  Future<void> analyze({
    required String job,
    required String city,
    required String province,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(marketServiceProvider);
      final supabase = ref.read(supabaseProvider);
      final session = supabase.auth.currentSession;

      final result = await service.analyzeMarket(
        job: job,
        city: city,
        province: province,
        accessToken: session?.accessToken,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Provider pour le quota utilisateur
final quotaProvider =
    AsyncNotifierProvider<QuotaNotifier, Map<String, dynamic>?>(
  () => QuotaNotifier(),
);

class QuotaNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    return _fetchQuota();
  }

  Future<Map<String, dynamic>?> _fetchQuota() async {
    final supabase = ref.read(supabaseProvider);
    final session = supabase.auth.currentSession;

    if (session == null) return null;

    try {
      final service = ref.read(marketServiceProvider);
      return await service.getQuota(accessToken: session.accessToken);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchQuota());
  }
}
