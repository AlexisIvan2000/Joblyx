import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joblyx_front/models/market_analysis_model.dart';
import 'package:joblyx_front/services/market_service.dart';

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
      final result = await service.analyzeMarket(
        job: job,
        city: city,
        province: province,
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
