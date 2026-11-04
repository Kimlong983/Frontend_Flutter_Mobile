import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/constant_uri.dart';
import '../../data/local/token_store_local.dart';
import '../../routes/app_route_name.dart';
import 'api_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

typedef _RequestFn = Future<http.Response> Function(Map<String, String> headers);

class ApiServiceImpl implements ApiService {
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  /// Shared in-flight refresh so parallel 401s trigger a single refresh call.
  Future<bool>? _refreshing;

  @override
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParams, bool requiresAuth = true}) {
    var uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        for (final e in queryParams.entries)
          if (e.value != null) e.key: e.value.toString(),
      });
    }
    return _send((headers) => _client.get(uri, headers: headers), requiresAuth: requiresAuth);
  }

  @override
  Future<dynamic> post(String url, {dynamic body, bool requiresAuth = true}) {
    return _send(
      (headers) => _client.post(Uri.parse(url), headers: headers, body: _encode(body)),
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<dynamic> put(String url, {dynamic body, bool requiresAuth = true}) {
    return _send(
      (headers) => _client.put(Uri.parse(url), headers: headers, body: _encode(body)),
      requiresAuth: requiresAuth,
    );
  }

  @override
  Future<dynamic> delete(String url, {bool requiresAuth = true}) {
    return _send((headers) => _client.delete(Uri.parse(url), headers: headers), requiresAuth: requiresAuth);
  }

  String? _encode(dynamic body) => body == null ? null : (body is String ? body : jsonEncode(body));

  Map<String, String> _headers(bool requiresAuth) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = TokenStoreLocal.getAccessToken();
    if (requiresAuth && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Sends the request; on 401 refreshes the access token once and retries.
  Future<dynamic> _send(_RequestFn request, {required bool requiresAuth}) async {
    try {
      var response = await request(_headers(requiresAuth)).timeout(_timeout);

      if (response.statusCode == 401 && requiresAuth) {
        if (await _refreshAccessToken()) {
          response = await request(_headers(requiresAuth)).timeout(_timeout);
        }
        if (response.statusCode == 401) {
          _endSession();
          throw ApiException("Session expired. Please log in again.", 401);
        }
      }

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException("Unable to connect to ${TokenStoreLocal.getBaseUrl()}. Check the server and your connection.");
    } on TimeoutException {
      throw ApiException("The server took too long to respond. Please try again.");
    } on http.ClientException catch (e) {
      throw ApiException("Network error: ${e.message}");
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    dynamic json;
    if (body.isNotEmpty) {
      try {
        json = jsonDecode(body);
      } catch (_) {
        json = body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }
    throw ApiException(_extractError(json, response.statusCode), response.statusCode);
  }

  /// Pulls a readable message out of a Spring-style error body.
  String _extractError(dynamic json, int statusCode) {
    if (json is Map) {
      final errors = json['errors'];
      if (errors is Map && errors.isNotEmpty) {
        return errors.entries.map((e) => "${e.key}: ${e.value}").join("\n");
      }
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e is Map ? (e['defaultMessage'] ?? e['message'] ?? e) : e).join("\n");
      }
      final message = json['message'] ?? json['error'];
      if (message != null && message.toString().isNotEmpty) return message.toString();
    } else if (json is String && json.isNotEmpty && json.length < 200) {
      return json;
    }

    switch (statusCode) {
      case 400:
        return "Invalid request. Please check your input.";
      case 403:
        return "You don't have permission to do this.";
      case 404:
        return "The requested record was not found.";
      case 409:
        return "This record conflicts with an existing one.";
      default:
        return statusCode >= 500 ? "Server error ($statusCode). Please try again later." : "Request failed ($statusCode).";
    }
  }

  Future<bool> _refreshAccessToken() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = TokenStoreLocal.getRefreshToken();
    if (refreshToken.isEmpty) return false;

    try {
      final response = await _client
          .post(
            Uri.parse(ConstantUri.refreshToken),
            headers: _headers(false),
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      final newAccess = data['accessToken'];
      if (newAccess == null) return false;

      TokenStoreLocal.setAccessToken(newAccess.toString());
      if (data['refreshToken'] != null) {
        TokenStoreLocal.setRefreshToken(data['refreshToken'].toString());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _endSession() {
    TokenStoreLocal.clear();
    if (Get.currentRoute != AppRouteName.login) {
      Get.offAllNamed(AppRouteName.login);
    }
  }
}
