import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:joblyx_front/models/search_history_model.dart';
import 'history_exception.dart';

class HistoryService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  Future<List<SearchHistoryItem>> getHistory({
    required String accessToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/history');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final historyList = data['history'] as List;
        return historyList
            .map((item) => SearchHistoryItem.fromMap(item))
            .toList();
      } else if (response.statusCode == 401) {
        throw HistoryFailure('unauthorized');
      } else {
        throw HistoryFailure('api_error');
      }
    } on HistoryFailure {
      rethrow;
    } catch (e) {
      throw HistoryFailure('network_error');
    }
  }

  Future<SearchHistoryItem?> getSearchById({
    required String accessToken,
    required String searchId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/history/$searchId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchHistoryItem.fromMap(data);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw HistoryFailure('unauthorized');
      } else {
        throw HistoryFailure('api_error');
      }
    } on HistoryFailure {
      rethrow;
    } catch (e) {
      throw HistoryFailure('network_error');
    }
  }

  Future<bool> deleteSearch({
    required String accessToken,
    required String searchId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/history/$searchId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearHistory({required String accessToken}) async {
    try {
      final uri = Uri.parse('$_baseUrl/history');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
