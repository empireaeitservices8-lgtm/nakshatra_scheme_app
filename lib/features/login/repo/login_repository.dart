import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/web_api_services.dart';
import '../../../utils/urls.dart';
import '../model/login_model.dart';
import '../model/otp_model.dart';

class LoginRepository {
  final Dio _dio;

  LoginRepository({Dio? dio}) : _dio = dio ?? WebAPIService().dio;

  /// Sends OTP to the provided phone number via /api/scheme/otp/send
  Future<SendOtpResponseModel> sendOtp({
    required String phone,
  }) async {
    final requestBody = SendOtpRequestModel(
      params: SendOtpParams(phone: phone),
    ).toJson();

    debugPrint("===> [LoginRepository] Send OTP Request to $urlSchemeSendOtp: ${jsonEncode(requestBody)}");

    try {
      final response = await _dio.post(
        urlSchemeSendOtp,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("<=== [LoginRepository] Send OTP Response: ${response.data}");

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

      return SendOtpResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [LoginRepository] Send OTP DioException: ${dioError.message}");
      debugPrint("❌ [LoginRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return SendOtpResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to send OTP.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server. Please check your network.";
      }

      return SendOtpResponseModel(
        error: OtpErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [LoginRepository] Unexpected error sending OTP: $e");
      return SendOtpResponseModel(
        error: OtpErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Resends OTP to the provided phone number via /api/scheme/otp/resend
  Future<SendOtpResponseModel> resendOtp({
    required String phone,
  }) async {
    final requestBody = SendOtpRequestModel(
      params: SendOtpParams(phone: phone),
    ).toJson();

    debugPrint("===> [LoginRepository] Resend OTP Request to $urlSchemeResendOtp: ${jsonEncode(requestBody)}");

    try {
      final response = await _dio.post(
        urlSchemeResendOtp,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("<=== [LoginRepository] Resend OTP Response: ${response.data}");

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

      return SendOtpResponseModel.fromJson(responseMap);
    } on DioException catch (dioError) {
      debugPrint("❌ [LoginRepository] Resend OTP DioException: ${dioError.message}");
      debugPrint("❌ [LoginRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return SendOtpResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to resend OTP.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server. Please check your network.";
      }

      return SendOtpResponseModel(
        error: OtpErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [LoginRepository] Unexpected error resending OTP: $e");
      return SendOtpResponseModel(
        error: OtpErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Verifies OTP via /api/scheme/verify-otp
  Future<VerifyOtpResponseModel> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    final requestBody = VerifyOtpRequestModel(
      params: VerifyOtpParams(
        userId: userId,
        otp: otp,
      ),
    ).toJson();

    debugPrint("===> [LoginRepository] Verify OTP Request to $urlSchemeVerifyOtp: ${jsonEncode(requestBody)}");

    try {
      final response = await _dio.post(
        urlSchemeVerifyOtp,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint("<=== [LoginRepository] Verify OTP Response: ${response.data}");

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

      final verifyResponse = VerifyOtpResponseModel.fromJson(responseMap);

      if (verifyResponse.isSuccess) {
        await _saveOtpUserSession(verifyResponse);
      }

      return verifyResponse;
    } on DioException catch (dioError) {
      debugPrint("❌ [LoginRepository] Verify OTP DioException: ${dioError.message}");
      debugPrint("❌ [LoginRepository] Error response: ${dioError.response?.data}");

      if (dioError.response?.data != null && dioError.response?.data is Map) {
        try {
          final errorMap = Map<String, dynamic>.from(dioError.response!.data);
          return VerifyOtpResponseModel.fromJson(errorMap);
        } catch (_) {}
      }

      String userMessage = "Network error: unable to verify OTP.";
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        userMessage = "Connection timed out. Please check your internet connection.";
      } else if (dioError.type == DioExceptionType.connectionError) {
        userMessage = "Unable to connect to server. Please check your network.";
      }

      return VerifyOtpResponseModel(
        error: OtpErrorModel(
          code: dioError.response?.statusCode ?? 500,
          message: userMessage,
        ),
      );
    } catch (e) {
      debugPrint("❌ [LoginRepository] Unexpected error verifying OTP: $e");
      return VerifyOtpResponseModel(
        error: OtpErrorModel(
          code: 500,
          message: e.toString(),
        ),
      );
    }
  }

  /// Persists session and user information locally for OTP login
  Future<void> _saveOtpUserSession(VerifyOtpResponseModel response) async {
    try {
      final result = response.result;
      final userData = result?.data;

      // Use session_id from API, or generate a fallback token from userId
      final sessionId = (result?.sessionId?.isNotEmpty ?? false)
          ? result!.sessionId!
          : (userData?.userId != null
              ? 'otp_session_${userData!.userId}_${DateTime.now().millisecondsSinceEpoch}'
              : null);

      if (sessionId != null && sessionId.isNotEmpty) {
        await SpHelper.saveUserSession(
          sessionId: sessionId,
          userId: userData?.userId,
          name: userData?.name,
          email: userData?.email,
          phone: userData?.phone,
        );
        debugPrint("✅ [LoginRepository] OTP User session & profile persisted via SpHelper (token: ${sessionId.substring(0, sessionId.length.clamp(0, 20))}...)");
      } else {
        debugPrint("⚠️ [LoginRepository] No session_id or userId available to persist session");
      }
    } catch (e) {
      debugPrint("⚠️ [LoginRepository] Error saving OTP user session: $e");
    }
  }

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

      // Use session_id from API, or generate a fallback token from userId
      final sessionId = (result?.sessionId?.isNotEmpty ?? false)
          ? result!.sessionId!
          : (userData?.userId != null
              ? 'login_session_${userData!.userId}_${DateTime.now().millisecondsSinceEpoch}'
              : null);

      if (sessionId != null && sessionId.isNotEmpty) {
        await SpHelper.saveUserSession(
          sessionId: sessionId,
          userId: userData?.userId,
          name: userData?.name,
          email: userData?.email,
        );
        debugPrint("✅ [LoginRepository] User session & profile persisted via SpHelper (token: ${sessionId.substring(0, sessionId.length.clamp(0, 20))}...)");
      } else {
        debugPrint("⚠️ [LoginRepository] No session_id or userId available to persist session");
      }
    } catch (e) {
      debugPrint("⚠️ [LoginRepository] Error saving user session: $e");
    }
  }
}
