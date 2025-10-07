import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:my_fitness_tracker/utils/app_exceptions.dart';
import 'package:my_fitness_tracker/utils/constants.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, this.defaultHeaders})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Map<String, String>? defaultHeaders;

  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _httpClient
        .get(uri, headers: _mergeHeaders(headers))
        .timeout(AppConstants.defaultTimeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await _httpClient
        .post(
          uri,
          headers: _mergeHeaders(headers),
          body: json.encode(body ?? <String, dynamic>{}),
        )
        .timeout(AppConstants.defaultTimeout);
    return _decodeResponse(response);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return <String, String>{
      ...AppConstants.defaultHeaders,
      ...?defaultHeaders,
      ...?headers,
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isEmpty ? '{}' : response.body;
    final parsed = json.decode(body) as Map<String, dynamic>;
    final success = statusCode >= 200 && statusCode < 300;
    if (!success) {
      throw ApiException(
        parsed['message']?.toString() ?? 'Request failed',
        statusCode: statusCode,
      );
    }
    return parsed;
  }

  void close() {
    _httpClient.close();
  }
}
