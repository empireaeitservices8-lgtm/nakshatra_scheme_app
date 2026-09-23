import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/sp_keys.dart' as sp_keys;
import '../../../utils/urls.dart';
import '../model/login_model.dart';

class LoginRepository {
  final Dio _dio;

  LoginRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Executes the Scheme Login API request with JSON-RPC payload
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final requestBody = LoginRequestModel(
      params: LoginRequestParams(
        username: username,
        password: password,
      ),
    ).toJson();

    debugPrint("===> [LoginRepository] Request to $urlSchemeLogin: ${jsonEncode(requestBody)}");

    try {
      final response = await _dio.post(
        urlSchemeLogin,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("<=== [LoginRepository] Response status: ${response.statusCode}");
      debugPrint("<=== [LoginRepository] Response data: ${response.data}");

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

      final loginResponse = LoginResponseModel.fromJson(responseMap);

      // If login succeeded, persist session and user profile data to SharedPreferences
      if (loginResponse.isSuccess) {
        await _saveUserSession(loginResponse);
      }

      return loginResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [LoginRepository] DioException: ${dioError.message}");
      debugPrint("❌ [LoginRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return LoginResponseModel.fromJson(errorMap);
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

      return LoginResponseModel(
        error: LoginErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [LoginRepository] Unexpected error: $e");
      return LoginResponseModel(
        error: LoginErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Persists session and user information locally via SpHelper
  Future<void> _saveUserSession(LoginResponseModel response) async {
    try {
      final result = response.result;
      final userData = result?.data;

      if (result?.sessionId?.isNotEmpty ?? false) {
        await SpHelper.saveUserSession(
          sessionId: result!.sessionId!,
          userId: userData?.userId,
          name: userData?.name,
          email: userData?.email,
        );
        debugPrint("✅ [LoginRepository] User session & profile persisted via SpHelper");
      }
    } catch (e) {
      debugPrint("⚠️ [LoginRepository] Error saving user session: $e");
    }
  }
}
