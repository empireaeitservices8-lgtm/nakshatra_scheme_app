import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralized API Logger for formatting and printing network requests, responses, and errors.
class ApiLogger {
  static const String _tag = "API_LOG";

  /// Safely formats any object/map/string as a pretty-printed JSON string
  static String _prettyJson(dynamic data) {
    if (data == null) return "null";
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  /// Logs outgoing API Request
  static void request({
    required String url,
    String method = "POST",
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("┌─────────────────────────── [API REQUEST] ───────────────────────────");
    buffer.writeln("│ 🌐 Method : $method");
    buffer.writeln("│ 🔗 URL    : $url");
    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln("│ 🔍 Query  : $queryParameters");
    }
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln("│ 📋 Headers: $headers");
    }
    if (body != null) {
      buffer.writeln("│ 📦 Body   :");
      final formattedBody = _prettyJson(body);
      for (final line in formattedBody.split('\n')) {
        buffer.writeln("│   $line");
      }
    }
    buffer.write("└─────────────────────────────────────────────────────────────────────");

    final logMessage = buffer.toString();
    developer.log(logMessage, name: _tag);
    if (kDebugMode) {
      debugPrint(logMessage);
    }
  }

  /// Logs incoming API Response
  static void response({
    required String url,
    required int? statusCode,
    dynamic data,
    Duration? duration,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("┌─────────────────────────── [API RESPONSE] ──────────────────────────");
    buffer.writeln("│ 📥 Status : $statusCode");
    buffer.writeln("│ 🔗 URL    : $url");
    if (duration != null) {
      buffer.writeln("│ ⏱️ Time   : ${duration.inMilliseconds} ms");
    }
    if (data != null) {
      buffer.writeln("│ 📦 Data   :");
      final formattedData = _prettyJson(data);
      for (final line in formattedData.split('\n')) {
        buffer.writeln("│   $line");
      }
    }
    buffer.write("└─────────────────────────────────────────────────────────────────────");

    final logMessage = buffer.toString();
    developer.log(logMessage, name: _tag);
    if (kDebugMode) {
      debugPrint(logMessage);
    }
  }

  /// Logs API Error or Exception
  static void error({
    required String url,
    int? statusCode,
    dynamic error,
    dynamic responseData,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("┌──────────────────────────── [API ERROR] ────────────────────────────");
    buffer.writeln("│ ❌ Status : ${statusCode ?? 'N/A'}");
    buffer.writeln("│ 🔗 URL    : $url");
    if (error != null) {
      buffer.writeln("│ ⚠️ Error  : $error");
    }
    if (responseData != null) {
      buffer.writeln("│ 📦 Response Data :");
      final formattedData = _prettyJson(responseData);
      for (final line in formattedData.split('\n')) {
        buffer.writeln("│   $line");
      }
    }
    buffer.write("└─────────────────────────────────────────────────────────────────────");

    final logMessage = buffer.toString();
    developer.log(logMessage, name: _tag, error: error, stackTrace: stackTrace);
    if (kDebugMode) {
      debugPrint(logMessage);
    }
  }
}

/// Dio Interceptor that automatically logs all outgoing requests, incoming responses, and network errors.
class ApiLoggingInterceptor extends Interceptor {
  final Map<RequestOptions, DateTime> _requestTimestamps = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimestamps[options] = DateTime.now();

    ApiLogger.request(
      url: options.uri.toString(),
      method: options.method,
      headers: options.headers,
      body: options.data,
      queryParameters: options.queryParameters,
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(response.requestOptions);
    final duration = startTime != null ? DateTime.now().difference(startTime) : null;

    ApiLogger.response(
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      data: response.data,
      duration: duration,
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(err.requestOptions);
    final duration = startTime != null ? DateTime.now().difference(startTime) : null;

    ApiLogger.error(
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      error: "${err.type} - ${err.message}${duration != null ? ' (${duration.inMilliseconds}ms)' : ''}",
      responseData: err.response?.data,
      stackTrace: err.stackTrace,
    );

    super.onError(err, handler);
  }
}
