import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/urls.dart';
import '../model/join_scheme_model.dart';
import '../model/popular_plans_model.dart';
import '../model/scheme_details_model.dart';

class SchemesRepository {
  final Dio _dio;

  SchemesRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Fetches popular scheme plans from Odoo JSON-RPC API
  Future<PopularPlansResponseModel> getPopularPlans() async {
    final requestBody = PopularPlansRequestModel().toJson();

    debugPrint("===> [SchemesRepository] Request to $urlSchemePopularPlans: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemePopularPlans,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [SchemesRepository] Response status: ${response.statusCode}");
      debugPrint("<=== [SchemesRepository] Response data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      final popularPlansResponse = PopularPlansResponseModel.fromJson(responseMap);
      return popularPlansResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [SchemesRepository] DioException: ${dioError.message}");
      debugPrint("❌ [SchemesRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return PopularPlansResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server. Please verify the server IP/port.";
      }

      return PopularPlansResponseModel(
        error: PopularPlansErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [SchemesRepository] Unexpected error: $e");
      return PopularPlansResponseModel(
        error: PopularPlansErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Fetches scheme details by enrollment_id from Odoo JSON-RPC API
  Future<SchemeDetailsResponseModel> getSchemeDetails({required int enrollmentId}) async {
    final requestBody = SchemeDetailsRequestModel(
      params: SchemeDetailsParams(enrollmentId: enrollmentId),
    ).toJson();

    debugPrint("===> [SchemesRepository] Request to $urlSchemeDetails: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeDetails,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [SchemesRepository] Scheme details status: ${response.statusCode}");
      debugPrint("<=== [SchemesRepository] Scheme details data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      final schemeDetailsResponse = SchemeDetailsResponseModel.fromJson(responseMap);
      return schemeDetailsResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [SchemesRepository] Scheme details DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return SchemeDetailsResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server.";
      }

      return SchemeDetailsResponseModel(
        error: SchemeDetailsErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [SchemesRepository] Unexpected error in getSchemeDetails: $e");
      return SchemeDetailsResponseModel(
        error: SchemeDetailsErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Creates a new scheme enrollment via api/scheme/join
  Future<JoinSchemeResponseModel> joinScheme(JoinSchemeRequestParams params) async {
    final requestBody = JoinSchemeRequestModel(params: params).toJson();

    debugPrint("===> [SchemesRepository] Request to $urlSchemeJoin: ${jsonEncode(requestBody)}");

    try {
      final sessionId = await SpHelper.getSessionId();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionId != null && sessionId.isNotEmpty) 'Cookie': 'session_id=$sessionId',
      };

      final response = await _dio.post(
        urlSchemeJoin,
        data: requestBody,
        options: Options(headers: headers),
      );

      debugPrint("<=== [SchemesRepository] Join scheme status: ${response.statusCode}");
      debugPrint("<=== [SchemesRepository] Join scheme data: ${response.data}");

      Map<String, dynamic> responseMap;
      if (response.data is Map<String, dynamic>) {
        responseMap = response.data;
      } else if (response.data is Map) {
        responseMap = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        responseMap = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception("Invalid response format received from server");
      }

      final joinResponse = JoinSchemeResponseModel.fromJson(responseMap);
      return joinResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [SchemesRepository] Join scheme DioException: ${dioError.message}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return JoinSchemeResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to connect to server.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server.";
      }

      return JoinSchemeResponseModel(
        error: JoinSchemeErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [SchemesRepository] Unexpected error in joinScheme: $e");
      return JoinSchemeResponseModel(
        error: JoinSchemeErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }
}
