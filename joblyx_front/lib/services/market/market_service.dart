import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:joblyx_front/models/market_analysis_model.dart';
import 'market_exception.dart';

class MarketService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  Future<MarketAnalysisResult> analyzeMarket({
    required String job,
    required String city,
    required String province,
    int topN = 25,
    bool balanced = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/market/analyze').replace(
        queryParameters: {
          'job': job,
          'city': city,
          'province': province,
          'top_n': topN.toString(),
          'balanced': balanced.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MarketAnalysisResult.fromMap(data);
      } else {
        throw MarketFailure('api_error');
      }
    } on MarketFailure {
      rethrow;
    } catch (e) {
      throw MarketFailure('network_error');
    }
  }
}
