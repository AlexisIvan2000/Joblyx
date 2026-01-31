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
    String? accessToken,
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

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Ajouter le token si disponible (pour quota et historique)
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MarketAnalysisResult.fromMap(data);
      } else if (response.statusCode == 429) {
        throw MarketFailure('quota_exceeded');
      } else {
        throw MarketFailure('api_error');
      }
    } on MarketFailure {
      rethrow;
    } catch (e) {
      throw MarketFailure('network_error');
    }
  }

  Future<Map<String, dynamic>> getQuota({required String accessToken}) async {
    try {
      final uri = Uri.parse('$_baseUrl/market/quota');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
