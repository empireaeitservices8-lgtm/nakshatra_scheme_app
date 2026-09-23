import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/sp_keys.dart' as sp_keys;
import '../../../utils/urls.dart';
import '../model/register_model.dart';

class RegisterRepository {
  final Dio _dio;

  RegisterRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Executes the Scheme Registration API request with JSON-RPC payload
  Future<RegisterResponseModel> register(RegisterRequestParams params) async {
    final requestBody = RegisterRequestModel(params: params).toJson();

    debugPrint("===> [RegisterRepository] Request to $urlSchemeRegister: ${jsonEncode(requestBody)}");

    try {
      final response = await _dio.post(
        urlSchemeRegister,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("<=== [RegisterRepository] Response status: ${response.statusCode}");
      debugPrint("<=== [RegisterRepository] Response data: ${response.data}");

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

      final registerResponse = RegisterResponseModel.fromJson(responseMap);

      // If registration succeeded, persist session & user profile data to SharedPreferences
      if (registerResponse.isSuccess) {
        await _saveUserSession(registerResponse);
      }

      return registerResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [RegisterRepository] DioException: ${dioError.message}");
      debugPrint("❌ [RegisterRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return RegisterResponseModel.fromJson(errorMap);
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

      return RegisterResponseModel(
        error: RegisterErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [RegisterRepository] Unexpected error: $e");
      return RegisterResponseModel(
        error: RegisterErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Persists session and user information locally via SpHelper
  Future<void> _saveUserSession(RegisterResponseModel response) async {
    try {
      final result = response.result;
      final userData = result?.data;

      if (result?.sessionId?.isNotEmpty ?? false) {
        await SpHelper.saveUserSession(
          sessionId: result!.sessionId!,
          userId: userData?.userId,
          name: userData?.name,
          email: userData?.email,
          phone: userData?.phone,
          partnerId: userData?.partnerId,
          city: userData?.city,
        );
        debugPrint("✅ [RegisterRepository] User session & profile persisted via SpHelper");
      }
    } catch (e) {
      debugPrint("⚠️ [RegisterRepository] Error saving user session: $e");
    }
  }
}
